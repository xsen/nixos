#!/usr/bin/env bash
set -euo pipefail

# XDG Standard Base Directories
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/local-ai"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/local-ai"

MODELS_DIR="$DATA_DIR/models"
BIN_DIR="$DATA_DIR/bin/llama-vulkan/llama-b10679"
SERVER_BIN="$BIN_DIR/llama-server"

PID_FILE="$STATE_DIR/llama_server.pid"
LOG_FILE="$STATE_DIR/llama_server.log"
CURRENT_MODE_FILE="$STATE_DIR/current_mode"
OPENCODE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.json"

DEFAULT_MODEL="Qwen3.8-27B-UD-Q4_K_M.gguf"
MODEL_PATH="$MODELS_DIR/$DEFAULT_MODEL"

# Server parameters
HOST="127.0.0.1"
PORT="8080"
PARALLEL_SLOTS="1"
CACHE_TYPE_K="q4_0"
CACHE_TYPE_V="q4_0"
THREADS="6"
THREADS_BATCH="10"
MODEL_ALIAS="qwen3.8-27b,qwen3.8-27b-short,qwen3.8-27b-long"
START_TIMEOUT="90"

# Qwen 3.8 Sampling Parameters
TEMP="1.0"
TOP_P="0.95"
TOP_K="20"
MIN_P="0.0"

mkdir -p "$DATA_DIR" "$MODELS_DIR" "$STATE_DIR"

ensure_binary() {
    if [[ ! -f "$SERVER_BIN" ]]; then
        echo "📦 llama-server binary not found. Downloading optimized Vulkan release (b10679)..."
        mkdir -p "$DATA_DIR/bin/llama-vulkan"
        curl -sLf "https://github.com/ggml-org/llama.cpp/releases/download/b10679/llama-b10679-bin-ubuntu-vulkan-x64.tar.gz" | tar -xz -C "$DATA_DIR/bin/llama-vulkan"
        chmod +x "$SERVER_BIN"
        echo "✅ Binary ready at $SERVER_BIN"
    fi
}

download_model() {
    local repo="${1:-unsloth/Qwen3.8-27B-GGUF}"
    local file="${2:-$DEFAULT_MODEL}"
    echo "============================================================"
    echo "📥 Downloading Model: $repo"
    echo "📄 File:             $file"
    echo "📂 Destination:      $MODELS_DIR/$file"
    echo "============================================================"

    mkdir -p "$MODELS_DIR"
    if command -v uv >/dev/null 2>&1; then
        uv run --with huggingface_hub python -c "
import sys
from huggingface_hub import hf_hub_download
hf_hub_download(repo_id=sys.argv[1], filename=sys.argv[2], local_dir=sys.argv[3])
print('\n✅ Model downloaded successfully!')
" "$repo" "$file" "$MODELS_DIR"
    else
        echo "⚠️ 'uv' not found, using curl to download model..."
        local url="https://huggingface.co/$repo/resolve/main/$file"
        curl -L -C - "$url" -o "$MODELS_DIR/$file"
    fi
}

update_opencode_config() {
    local ctx="$1"
    local mode_name="$2"

    if [[ ! -f "$OPENCODE_CONFIG" ]]; then
        return 0
    fi

    if command -v jq >/dev/null 2>&1; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg ctx "$ctx" \
           --arg name "Qwen 3.8 27B ($mode_name)" \
           'if .provider["local-llama"].models["qwen3.8-27b"] then
              .provider["local-llama"].models["qwen3.8-27b"].contextLength = ($ctx | tonumber) |
              .provider["local-llama"].models["qwen3.8-27b"].name = $name
            else . end' \
           "$OPENCODE_CONFIG" > "$tmp_file" && mv "$tmp_file" "$OPENCODE_CONFIG"
    fi
}

is_server_running() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null || true)
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    if pgrep -u "$USER" -f "llama-server.*$PORT" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

stop_server() {
    local stopped=0
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null || true)
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            echo "🛑 Stopping llama-server (PID: $pid)..."
            kill "$pid" 2>/dev/null || true
            for _ in {1..30}; do
                if ! kill -0 "$pid" 2>/dev/null; then
                    stopped=1
                    break
                fi
                sleep 0.5
            done
            if [[ $stopped -eq 0 ]]; then
                echo "⚠️ Force killing llama-server (PID: $pid)..."
                kill -9 "$pid" 2>/dev/null || true
            fi
        fi
        rm -f "$PID_FILE"
    fi

    # Fallback cleanup per user and wait for socket release
    if pgrep -u "$USER" -f "llama-server.*$PORT" >/dev/null 2>&1; then
        pkill -u "$USER" -f "llama-server.*$PORT" || true
        for _ in {1..10}; do
            if ! pgrep -u "$USER" -f "llama-server.*$PORT" >/dev/null 2>&1; then
                break
            fi
            sleep 0.5
        done
    fi
    echo "✅ Server stopped."
}

start_server() {
    local ctx_size="$1"
    local gpu_layers="$2"

    ensure_binary

    if [[ ! -f "$MODEL_PATH" ]]; then
        echo "❌ Error: Model file not found at $MODEL_PATH"
        echo "💡 Run 'ai-local download' to download the default model."
        exit 1
    fi

    if is_server_running; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null || pgrep -u "$USER" -f "llama-server.*$PORT" | head -n 1)
        echo "⚠️ llama-server is already running with PID $pid"
        return 0
    fi

    echo "============================================================"
    echo "🚀 Starting llama-server"
    echo "============================================================"
    echo "📦 Model:          $DEFAULT_MODEL"
    echo "🌐 Endpoint:       http://$HOST:$PORT/v1"
    echo "🧠 Context:        $ctx_size tokens"
    echo "🎮 GPU Offload:    $gpu_layers layers"
    echo "🗄️ KV Cache:       $CACHE_TYPE_K / $CACHE_TYPE_V"
    echo "📝 Logs:           $LOG_FILE"
    echo "============================================================"

    export LD_LIBRARY_PATH="$BIN_DIR:/run/opengl-driver/lib:${LD_LIBRARY_PATH:-}"

    setsid -f "$SERVER_BIN" \
        --model "$MODEL_PATH" \
        --alias "$MODEL_ALIAS" \
        --host "$HOST" \
        --port "$PORT" \
        --ctx-size "$ctx_size" \
        --parallel "$PARALLEL_SLOTS" \
        --n-gpu-layers "$gpu_layers" \
        --flash-attn on \
        --cache-type-k "$CACHE_TYPE_K" \
        --cache-type-v "$CACHE_TYPE_V" \
        --temp "$TEMP" \
        --top-p "$TOP_P" \
        --top-k "$TOP_K" \
        --min-p "$MIN_P" \
        --threads "$THREADS" \
        --threads-batch "$THREADS_BATCH" \
        --metrics \
        < /dev/null > "$LOG_FILE" 2>&1

    sleep 0.5
    local srv_pid
    srv_pid=$(pgrep -u "$USER" -f "llama-server.*$PORT" | head -n 1 || true)
    if [[ -n "$srv_pid" ]]; then
        echo "$srv_pid" > "$PID_FILE"
    fi

    echo "⏳ Server daemon launched (PID: ${srv_pid:-unknown})... Waiting for readiness (timeout: ${START_TIMEOUT}s)..."

    local ready=0
    for ((i=1; i<=START_TIMEOUT; i++)); do
        if [[ -n "$srv_pid" ]] && ! kill -0 "$srv_pid" 2>/dev/null; then
            echo "❌ Error: llama-server process exited unexpectedly. Logs:"
            tail -n 30 "$LOG_FILE"
            rm -f "$PID_FILE"
            exit 1
        fi

        if curl -s "http://$HOST:$PORT/health" 2>/dev/null | grep -q '"status":\s*"ok"'; then
            ready=1
            break
        fi
        sleep 1
    done

    if [[ $ready -eq 1 ]]; then
        echo "✅ llama-server is READY on http://$HOST:$PORT/v1"
    else
        echo "❌ Timeout waiting for server to be ready."
        tail -n 25 "$LOG_FILE"
        if [[ -n "$srv_pid" ]]; then
            kill -9 "$srv_pid" 2>/dev/null || true
        fi
        rm -f "$PID_FILE"
        exit 1
    fi
}

get_profile_params() {
    local mode="$1"
    case "$mode" in
        short|64k|64|fast|min|task)
            echo "65536|38|Short Context Mode (64k)|64k Context · Fast Generation · 38 GPU Layers|short"
            ;;
        long|128k|128|deep|max|repo|project)
            echo "131072|32|Long Context Mode (128k)|128k Context · Deep Context · 32 GPU Layers|long"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

apply_mode() {
    local target_mode="$1"
    local params
    params=$(get_profile_params "$target_mode")

    if [[ "$params" == "unknown" ]]; then
        echo "❌ Unknown mode: $target_mode"
        echo "Available modes: short, long, toggle"
        exit 1
    fi

    local ctx_size gpu_layers title desc norm_mode
    IFS='|' read -r ctx_size gpu_layers title desc norm_mode <<< "$params"

    echo "============================================================"
    echo "🔄 Switching Local AI Mode to: $title"
    echo "📜 $desc"
    echo "============================================================"

    stop_server
    start_server "$ctx_size" "$gpu_layers"

    echo "$norm_mode" > "$CURRENT_MODE_FILE"
    update_opencode_config "$ctx_size" "$title"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Local AI" "Режим: $title\n$desc" \
            -i dialog-information \
            -h string:x-canonical-private-synchronous:ai-local 2>/dev/null || true
    fi

    echo ""
    echo "🎉 Mode switch complete! Active mode: $norm_mode ($ctx_size tokens)"
}

cmd_start() {
    local requested_mode="${1:-}"
    local current_mode="short"
    if [[ -f "$CURRENT_MODE_FILE" ]]; then
        current_mode=$(cat "$CURRENT_MODE_FILE")
    fi

    if is_server_running; then
        if [[ -z "$requested_mode" || "$requested_mode" == "$current_mode" ]]; then
            local pid
            local cur_user="${USER:-$(id -un)}"
            pid=$(cat "$PID_FILE" 2>/dev/null || pgrep -u "$cur_user" -f "llama-server.*$PORT" | head -n 1 || echo "unknown")
            echo "⚠️ llama-server is already running in '$current_mode' mode (PID: $pid)"
            return 0
        fi
    fi

    if [[ -z "$requested_mode" ]]; then
        requested_mode="$current_mode"
    fi
    apply_mode "$requested_mode"
}

cmd_mode() {
    local subcmd="${1:-}"
    case "$subcmd" in
        short|64k|64|fast)
            apply_mode "short"
            ;;
        long|128k|128|deep)
            apply_mode "long"
            ;;
        toggle)
            local cur="short"
            if [[ -f "$CURRENT_MODE_FILE" ]]; then
                cur=$(cat "$CURRENT_MODE_FILE")
            fi
            if [[ "$cur" == "short" ]]; then
                apply_mode "long"
            else
                apply_mode "short"
            fi
            ;;
        *)
            echo "Usage: ai-local mode [short|long|toggle]"
            exit 1
            ;;
    esac
}

show_status() {
    echo "============================================================"
    echo "📊 Local AI Engine Status"
    echo "============================================================"
    local current_mode="unknown"
    if [[ -f "$CURRENT_MODE_FILE" ]]; then
        current_mode=$(cat "$CURRENT_MODE_FILE")
    fi
    echo "🏷️  Profile State:    $current_mode"

    if curl -s "http://$HOST:$PORT/health" 2>/dev/null | grep -q '"status":\s*"ok"'; then
        local model_info
        model_info=$(curl -s "http://$HOST:$PORT/v1/models" 2>/dev/null || true)
        local loaded_ctx
        loaded_ctx=$(echo "$model_info" | jq -r '.data[0].meta.n_ctx // "unknown"' 2>/dev/null || echo "unknown")
        echo "🟢 Server Health:    Online (http://$HOST:$PORT/v1)"
        echo "🧠 Active Context:   $loaded_ctx tokens"
    else
        echo "🔴 Server Health:    Offline (Stopped)"
    fi

    if [[ -f "$MODEL_PATH" ]]; then
        local model_size
        model_size=$(du -h "$MODEL_PATH" | cut -f1)
        echo "📦 Model File:       $DEFAULT_MODEL ($model_size)"
    else
        echo "⚠️  Model File:       Not found (run 'ai-local download')"
    fi

    if command -v nvidia-smi >/dev/null 2>&1; then
        local vram
        vram=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader 2>/dev/null || echo "N/A")
        echo "🎮 GPU VRAM:         $vram"
    fi
    echo "📂 Data Directory:   $DATA_DIR"
    echo "============================================================"
}

tail_log() {
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "Log file does not exist yet at $LOG_FILE"
        exit 1
    fi
    echo "Tailing live token generation speed from $LOG_FILE (Ctrl+C to exit)..."
    tail -f "$LOG_FILE" | grep --line-buffered -E "print_timing|launch_slot|stop processing"
}

main() {
    local cmd="${1:-status}"
    case "$cmd" in
        start)
            shift
            cmd_start "${1:-}"
            ;;
        stop)
            stop_server
            ;;
        restart)
            stop_server
            cmd_start ""
            ;;
        mode)
            shift
            cmd_mode "${1:-}"
            ;;
        # Fast shortcuts for mode:
        short|64k|64|fast)
            apply_mode "short"
            ;;
        long|128k|128|deep)
            apply_mode "long"
            ;;
        toggle)
            cmd_mode "toggle"
            ;;
        status)
            show_status
            ;;
        download)
            shift
            download_model "$@"
            ;;
        log|logs)
            tail_log
            ;;
        -h|--help|help)
            echo "Local AI CLI & Daemon Controller (Qwen 3.8 / llama-server)"
            echo "Usage: ai-local [COMMAND] [ARGS]"
            echo ""
            echo "Commands:"
            echo "  status            Show server health, context, VRAM and active mode"
            echo "  start [mode]      Start local AI server (default: last mode or short)"
            echo "  stop              Stop local AI server daemon"
            echo "  restart           Restart local AI server daemon"
            echo "  mode short        Switch to Short Context Mode (64k, 38 GPU layers)"
            echo "  mode long         Switch to Long Context Mode (128k, 32 GPU layers)"
            echo "  mode toggle       Toggle between short and long modes"
            echo "  short | long      Fast shortcuts for 'mode short' / 'mode long'"
            echo "  toggle            Fast shortcut for 'mode toggle'"
            echo "  log               Tail live token generation speed in real time"
            echo "  download          Download GGUF model from HuggingFace to ~/.local/share/local-ai"
            ;;
        *)
            echo "❌ Unknown command: $cmd"
            echo "Run 'ai-local --help' for usage."
            exit 1
            ;;
    esac
}

main "$@"
