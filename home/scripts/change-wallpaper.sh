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
TMP_FILE="$(mktemp -p ~/.wallpapers current.XXXXXX.png)"

ln -sf "$TARGET" "$TMP_FILE"
mv -f "$TMP_FILE" ~/.wallpapers/current.png

if pidof hyprpaper >/dev/null; then
    hyprctl hyprpaper preload "$TARGET" >/dev/null 2>&1
    hyprctl hyprpaper wallpaper ",$TARGET" >/dev/null 2>&1
else
    echo "Hyprpaper not running, wallpaper saved for next launch"
fi

echo "Wallpaper successfully changed to: $TARGET"