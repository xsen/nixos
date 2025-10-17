#!/bin/sh

mode=$1

hyprctl keyword animations:enabled false

case $mode in
    "output")
        hyprshot -m output -r -- | satty --filename - --output-filename ~/Yandex.Disk/Скриншоты/$(date '+%Y-%m-%d_%H-%M-%S').png --early-exit --copy-command 'wl-copy'
        ;;
    "window")
        hyprshot -m window -r -- | satty --filename - --output-filename ~/Yandex.Disk/Скриншоты/$(date '+%Y-%m-%d_%H-%M-%S').png --early-exit --copy-command 'wl-copy'
        ;;
    "region")
        hyprshot -m region -r -- | satty --filename - --output-filename ~/Yandex.Disk/Скриншоты/$(date '+%Y-%m-%d_%H-%M-%S').png --early-exit --copy-command 'wl-copy'
        ;;
esac

hyprctl keyword animations:enabled true
