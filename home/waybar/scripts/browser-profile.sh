#!/usr/bin/env bash

# Скрипт для вывода текущего профиля браузера в Waybar

OVERRIDE_FILE="$HOME/.cache/browser-dispatcher-profile"
VAL=""
if [ -f "$OVERRIDE_FILE" ]; then
  VAL=$(cat "$OVERRIDE_FILE" | xargs)
fi

if [ "$VAL" = "work" ]; then
  TEXT="WO"
  TOOLTIP="Браузер: Рабочий (Profile 1)"
  CLASS="work"
elif [ "$VAL" = "personal" ]; then
  TEXT="CH"
  TOOLTIP="Браузер: Личный (Profile 2)"
  CLASS="personal"
else
  # В авторежиме мы проверяем активный ворксейс через hyprctl
  ACTIVE_WS=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id' 2>/dev/null || echo 1)
  if [ "$ACTIVE_WS" = "1" ] || [ "$ACTIVE_WS" = "2" ]; then
    CURRENT_WS="1"
  else
    CURRENT_WS="2"
  fi
  TEXT="AU"
  TOOLTIP="Браузер: Авто (сейчас Profile $CURRENT_WS)"
  CLASS="auto"
fi

echo "{\"text\":\"$TEXT\",\"tooltip\":\"$TOOLTIP\",\"class\":\"$CLASS\"}"
