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

# Получаем абсолютный путь (важно для нового гипрпейпера)
TARGET="$(realpath "$1")"
DEST="$HOME/.wallpapers/current.png"
TMP_FILE="$(mktemp -p "$HOME/.wallpapers" current.XXXXXX.png)"

# Обновляем симлинк
ln -sf "$TARGET" "$TMP_FILE"
mv -f "$TMP_FILE" "$DEST"

if pidof hyprpaper >/dev/null; then
    # Используем новую команду reload.
    # Она сама сделает preload и обновит мониторы.
    # Пустая строка перед запятой означает "все мониторы".
    hyprctl hyprpaper reload ",$TARGET" >/dev/null 2>&1
else
    echo "Hyprpaper not running, wallpaper saved for next launch"
fi

echo "Wallpaper successfully changed to: $TARGET"
