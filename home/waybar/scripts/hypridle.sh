#!/usr/bin/env bash

# Compatibility wrapper for Waybar calling ~/.config/waybar/scripts/hypridle.sh
if command -v hypridle.sh >/dev/null 2>&1; then
    exec hypridle.sh "$@"
elif [ -x "$HOME/.scripts/hypridle.sh" ]; then
    exec "$HOME/.scripts/hypridle.sh" "$@"
else
    # Fallback to local execution if scripts directory is copied standalone
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -x "$SCRIPT_DIR/../../scripts/hypridle.sh" ]; then
        exec "$SCRIPT_DIR/../../scripts/hypridle.sh" "$@"
    fi
fi
