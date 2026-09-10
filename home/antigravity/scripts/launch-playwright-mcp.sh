#!/usr/bin/env bash
set -euo pipefail

# Переменные окружения с дефолтными значениями:
# AGY_PLAYWRIGHT_HEADLESS=true (по умолчанию headless)
# AGY_PLAYWRIGHT_ISOLATED=true (по умолчанию изолированный)

CHROME_BIN="${CHROME_BIN:-$(command -v google-chrome-stable || echo /run/current-system/sw/bin/google-chrome-stable)}"

MCP_ARGS=(
  --executable-path "$CHROME_BIN"
)

if [ "${AGY_PLAYWRIGHT_HEADLESS:-true}" != "false" ]; then
  MCP_ARGS+=(--headless)
fi

if [ "${AGY_PLAYWRIGHT_ISOLATED:-true}" = "false" ]; then
  PROFILE_DIR="${HOME}/.config/playwright-mcp-profile"
  mkdir -p "$PROFILE_DIR"
  MCP_ARGS+=(--user-data-dir "$PROFILE_DIR")
else
  MCP_ARGS+=(--isolated)
fi

resolve_mcp_bin() {
  local bin
  if bin="$(command -v playwright-mcp 2>/dev/null)"; then
    echo "$bin"
  elif [ -x "${HOME}/.npm-packages/bin/playwright-mcp" ]; then
    echo "${HOME}/.npm-packages/bin/playwright-mcp"
  else
    echo "npx"
  fi
}

MCP_BIN=$(resolve_mcp_bin)
if [ "$MCP_BIN" = "npx" ]; then
  exec npx -y @playwright/mcp@latest "${MCP_ARGS[@]}" "$@"
else
  exec "$MCP_BIN" "${MCP_ARGS[@]}" "$@"
fi
