#!/bin/sh

mode=$1

hyprctl eval 'hl.config({ animations = { enabled = false } })'

case $mode in
    "output")
        hyprshot -z -m output -r -- | satty --filename - --output-filename ~/Cloud/Nextcloud/Автозагрузка/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png --early-exit --copy-command 'wl-copy'
        ;;
    "window")
        hyprshot -z -m window -r -- | satty --filename - --output-filename ~/Cloud/Nextcloud/Автозагрузка/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png --early-exit --copy-command 'wl-copy'
        ;;
    "region")
        hyprshot -z -m region -r -- | satty --filename - --output-filename ~/Cloud/Nextcloud/Автозагрузка/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png --early-exit --copy-command 'wl-copy'
        ;;
esac

hyprctl eval 'hl.config({ animations = { enabled = true } })'
