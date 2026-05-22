#!/usr/bin/env bash

# Lock file to prevent double triggers (debounce)
LOCK_FILE="/tmp/hypridle_toggle.lock"

if [[ "$1" == "--toggle" ]]; then
    # If lock exists, it means we recently toggled. Ignore this call.
    if [[ -f "$LOCK_FILE" ]]; then
        exit 0
    fi

    # Create lock
    touch "$LOCK_FILE"

    if pgrep -x "hypridle" > /dev/null; then
        pkill -x "hypridle"
        notify-send "Hypridle" "Disabled" -i system-suspend -a "Waybar"
    else
        uwsm app -- hypridle > /dev/null 2>&1 &
        notify-send "Hypridle" "Enabled" -i system-suspend -a "Waybar"
    fi

    # Remove lock after 500ms
    (sleep 0.5 && rm -f "$LOCK_FILE") &

    # Wait a bit for the process state to stabilize before status check
    sleep 0.2
fi

if pgrep -x "hypridle" > /dev/null; then
    echo '{"text": "󰈈", "class": "enabled", "tooltip": "Hypridle Enabled"}'
else
    echo '{"text": "󰈉", "class": "disabled", "tooltip": "Hypridle Disabled"}'
fi
