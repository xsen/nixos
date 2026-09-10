#!/usr/bin/env bash
set -euo pipefail

# Переменные окружения с дефолтными значениями:
# AGY_CHROME_HEADLESS=true (по умолчанию headless)
# AGY_CHROME_ISOLATED=true (по умолчанию изолированный)
# AGY_CHROME_PORT (по умолчанию 9222, либо автовыбор свободного порта)
# AGY_CHROME_NO_SANDBOX=false (песочница включена по умолчанию)

export PUPPETEER_SKIP_DOWNLOAD=true
MCP_PACKAGE="chrome-devtools-mcp@1.9.0"

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"

resolve_mcp_bin() {
  local bin
  if bin="$(command -v chrome-devtools-mcp 2>/dev/null)"; then
    echo "$bin"
  elif [ -x "${HOME}/.npm-packages/bin/chrome-devtools-mcp" ]; then
    echo "${HOME}/.npm-packages/bin/chrome-devtools-mcp"
  else
    echo "npx"
  fi
}

is_chrome_running() {
  local port="$1"
  curl -sf --connect-timeout 1 "http://127.0.0.1:${port}/json/version" 2>/dev/null | grep -q "webSocketDebuggerUrl"
}

is_ephemeral_chrome() {
  local port="$1"
  local pid
  pid=$(ss -tlpn "sport = :$port" 2>/dev/null | grep -oP 'pid=\K[0-9]+' | head -n 1 || true)
  if [ -n "$pid" ] && [ -f "/proc/$pid/cmdline" ]; then
    if grep -q -F -- "chrome-profile-" "/proc/$pid/cmdline" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

find_free_port() {
  local base="${1:-9222}"
  local port
  for ((port=base; port<base+100; port++)); do
    if ! ss -tlpn "sport = :$port" 2>/dev/null | grep -q ":$port "; then
      echo "$port"
      return 0
    fi
  done
  echo "Error: No free port found in range $base..$((base+100))" >&2
  return 1
}

run_mcp_direct() {
  local port="$1"
  shift
  local mcp_bin
  mcp_bin=$(resolve_mcp_bin)
  local log_file="${RUNTIME_DIR}/chrome-devtools-mcp-${port}.log"
  if [ "$mcp_bin" = "npx" ]; then
    exec npx -y "$MCP_PACKAGE" --browserUrl "http://127.0.0.1:$port" --no-usage-statistics --no-page-id-routing --logFile "$log_file" "$@"
  else
    exec "$mcp_bin" --browserUrl "http://127.0.0.1:$port" --no-usage-statistics --no-page-id-routing --logFile "$log_file" "$@"
  fi
}

TARGET_PORT="${AGY_CHROME_PORT:-}"

# 1. Определение порта и проверка существующего Chrome
if [ -n "$TARGET_PORT" ]; then
  DEBUG_PORT="$TARGET_PORT"
  if is_chrome_running "$DEBUG_PORT"; then
    run_mcp_direct "$DEBUG_PORT" "$@"
  fi
elif [ "${AGY_CHROME_ISOLATED:-true}" = "false" ]; then
  DEBUG_PORT=9222
  if is_chrome_running "$DEBUG_PORT"; then
    run_mcp_direct "$DEBUG_PORT" "$@"
  fi
else
  # Изолированный режим: если на 9222 уже запущен пользовательский (не временный) Chrome, подключаемся к нему.
  # Если 9222 занят временным профилем другого агента или другим процессом — ищем следующий свободный порт.
  if is_chrome_running 9222 && ! is_ephemeral_chrome 9222; then
    run_mcp_direct 9222 "$@"
  fi
  DEBUG_PORT=$(find_free_port 9222)
fi

CHROME_PID=""
MCP_PID=""
TEMP_PROFILE=""
CHROME_LOG="${RUNTIME_DIR}/chrome-mcp-${DEBUG_PORT}.log"
MCP_LOG="${RUNTIME_DIR}/chrome-devtools-mcp-${DEBUG_PORT}.log"

cleanup() {
  trap - EXIT SIGINT SIGTERM
  if [ -n "${MCP_PID:-}" ]; then
    kill "$MCP_PID" 2>/dev/null || true
  fi
  if [ -n "$CHROME_PID" ]; then
    kill "$CHROME_PID" 2>/dev/null || true
    for _ in {1..15}; do
      if ! kill -0 "$CHROME_PID" 2>/dev/null; then
        break
      fi
      sleep 0.1
    done
    if kill -0 "$CHROME_PID" 2>/dev/null; then
      kill -9 "$CHROME_PID" 2>/dev/null || true
    fi
    wait "$CHROME_PID" 2>/dev/null || true
  fi
  if [ -n "$TEMP_PROFILE" ] && [ -d "$TEMP_PROFILE" ]; then
    rm -rf "$TEMP_PROFILE"
  fi
}
trap cleanup EXIT SIGINT SIGTERM

# 2. Определение бинарника Chrome
CHROME_BIN="${CHROME_BIN:-$(command -v google-chrome-stable || echo /run/current-system/sw/bin/google-chrome-stable)}"
if [ ! -x "$CHROME_BIN" ]; then
  echo "Error: Chrome binary not found or not executable at '$CHROME_BIN'" >&2
  exit 1
fi

# 3. Формирование аргументов
CHROME_ARGS=(
  --remote-debugging-port="$DEBUG_PORT"
  --disable-gpu
  --disable-dev-shm-usage
  --disable-background-timer-throttling
  --disable-backgrounding-occluded-windows
  --disable-renderer-backgrounding
  --disable-hang-monitor
  --disable-client-side-phishing-detection
  --disable-component-update
  --disable-default-apps
  --no-default-browser-check
  --no-first-run
)

if [ "${AGY_CHROME_NO_SANDBOX:-false}" = "true" ]; then
  CHROME_ARGS+=(--no-sandbox)
fi

if [ "${AGY_CHROME_HEADLESS:-true}" != "false" ]; then
  CHROME_ARGS+=(--headless=new)
fi

if [ "${AGY_CHROME_ISOLATED:-true}" = "false" ]; then
  PROFILE_DIR="${HOME}/.config/chrome-mcp-profile"
  mkdir -p "$PROFILE_DIR"
  CHROME_ARGS+=(--user-data-dir="$PROFILE_DIR")
else
  TEMP_PROFILE=$(mktemp -d -t chrome-profile-XXXXXX)
  CHROME_ARGS+=(--user-data-dir="$TEMP_PROFILE")
fi

# 4. Запуск Chrome
"$CHROME_BIN" "${CHROME_ARGS[@]}" > "$CHROME_LOG" 2>&1 &
CHROME_PID=$!

# 5. Ожидаем готовности сокета отладки (до 10 секунд) с проверкой жизни процесса
CHROME_READY=false
for _ in {1..100}; do
  if ! kill -0 "$CHROME_PID" 2>/dev/null; then
    echo "Error: Chrome process died unexpectedly during startup on port $DEBUG_PORT." >&2
    if [ -f "$CHROME_LOG" ]; then
      echo "=== Chrome output logs ===" >&2
      tail -n 20 "$CHROME_LOG" >&2
    fi
    exit 1
  fi
  if is_chrome_running "$DEBUG_PORT"; then
    CHROME_READY=true
    break
  fi
  sleep 0.1
done

if [ "$CHROME_READY" != "true" ]; then
  echo "Error: Chrome failed to open debug port $DEBUG_PORT within 10 seconds." >&2
  if [ -f "$CHROME_LOG" ]; then
    echo "=== Chrome output logs ===" >&2
    tail -n 20 "$CHROME_LOG" >&2
  fi
  exit 1
fi

# 6. Запускаем MCP-сервер и ожидаем завершения с пробросом сигналов
MCP_BIN=$(resolve_mcp_bin)
MCP_EXIT=0
if [ "$MCP_BIN" = "npx" ]; then
  npx -y "$MCP_PACKAGE" --browserUrl "http://127.0.0.1:$DEBUG_PORT" --no-usage-statistics --no-page-id-routing --logFile "$MCP_LOG" "$@" <&0 &
else
  "$MCP_BIN" --browserUrl "http://127.0.0.1:$DEBUG_PORT" --no-usage-statistics --no-page-id-routing --logFile "$MCP_LOG" "$@" <&0 &
fi
MCP_PID=$!
wait "$MCP_PID" || MCP_EXIT=$?

cleanup
exit "$MCP_EXIT"
