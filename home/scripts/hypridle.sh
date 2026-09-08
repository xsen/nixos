#!/usr/bin/env bash

# Lock file to prevent rapid double triggers (debounce)
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypridle_toggle_${UID}.lock"

is_running() {
    pgrep -u "$UID" -x "hypridle" > /dev/null 2>&1
}

toggle_hypridle() {
    # Check if lock exists and is recent (less than 2 seconds old)
    if [[ -f "$LOCK_FILE" ]]; then
        local lock_mtime now diff
        lock_mtime=$(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0)
        now=$(date +%s)
        diff=$((now - lock_mtime))
        if [[ $diff -lt 2 ]]; then
            exit 0
        else
            rm -f "$LOCK_FILE"
        fi
    fi

    touch "$LOCK_FILE"

    if is_running; then
        pkill -u "$UID" -x "hypridle"
        notify-send "Hypridle" "Disabled" -i system-suspend -a "Hypridle"
    else
        uwsm app -- hypridle > /dev/null 2>&1 &
        notify-send "Hypridle" "Enabled" -i system-suspend -a "Hypridle"
    fi

    # Remove lock after 500ms in background
    (sleep 0.5 && rm -f "$LOCK_FILE") &

    # Give process time to update state
    sleep 0.2
}

print_waybar_json() {
    if is_running; then
        echo '{"text": "󰈈", "class": "enabled", "tooltip": "Hypridle Enabled"}'
    else
        echo '{"text": "󰈉", "class": "disabled", "tooltip": "Hypridle Disabled"}'
    fi
}

print_status() {
    if is_running; then
        echo "Hypridle is running (enabled)"
    else
        echo "Hypridle is not running (disabled)"
    fi
}

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTION]

Control and check the status of hypridle.

Options:
  -t, --toggle, toggle    Toggle hypridle on/off
  -s, --status, status    Print current hypridle status (human readable)
  -j, --json, --waybar    Print current status in Waybar JSON format
  -h, --help              Show this help message

If invoked as 'hypridle-toggle' without arguments, it defaults to toggling.
If invoked as 'hypridle.sh' without arguments, it outputs Waybar JSON.
EOF
}

cmd_name="$(basename "$0")"
action=""

if [[ $# -eq 0 ]]; then
    if [[ "$cmd_name" == "hypridle-toggle"* ]]; then
        action="toggle"
    else
        action="waybar"
    fi
else
    case "$1" in
        -t|--toggle|toggle)
            action="toggle"
            ;;
        -s|--status|status)
            action="status"
            ;;
        -j|--json|--waybar|waybar)
            action="waybar"
            ;;
        -h|--help|help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help >&2
            exit 1
            ;;
    esac
fi

case "$action" in
    toggle)
        toggle_hypridle
        ;;
    status)
        print_status
        ;;
    waybar)
        print_waybar_json
        ;;
esac
