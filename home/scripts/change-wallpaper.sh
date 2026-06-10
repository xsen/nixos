#!/bin/sh
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-image>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found!" >&2
    exit 2
fi

mkdir -p ~/.wallpapers

TARGET="$(realpath "$1")"
DEST="$HOME/.wallpapers/current.png"
TMP_FILE="$(mktemp -p "$HOME/.wallpapers" current.XXXXXX.png)"

cp "$TARGET" "$TMP_FILE"
mv -f "$TMP_FILE" "$DEST"

if pidof hyprpaper >/dev/null; then
    pkill hyprpaper || true
    sleep 0.5
    hyprpaper >/dev/null 2>&1 & disown
else
    echo "Hyprpaper not running, wallpaper saved for next launch"
fi

echo "Wallpaper successfully changed to: $TARGET"
