{
  config,
  pkgs,
  lib,
  ...
}:

let
  browser-dispatcher = pkgs.writeShellScriptBin "browser-dispatcher" ''
    # Скрипт-диспетчер для открытия ссылок в нужном профиле Yandex Browser
    # в зависимости от текущего ворксейса Hyprland или ручного оверрайда.

    OVERRIDE_FILE="$HOME/.cache/browser-dispatcher-profile"
    URL=""
    PROFILE=""
    TITLE_PAT=""
    DEFAULT_WS=1

    # Обработка аргументов командной строки
    if [ "$1" = "--toggle" ]; then
      CURRENT=""
      if [ -f "$OVERRIDE_FILE" ]; then
        CURRENT=$(cat "$OVERRIDE_FILE" | xargs)
      fi

      if [ "$CURRENT" = "work" ]; then
        echo "personal" > "$OVERRIDE_FILE"
        ${pkgs.libnotify}/bin/notify-send "Браузер" "Режим: Chill (Profile 2)" -i yandex-browser -h string:x-canonical-private-synchronous:browser-mode
      elif [ "$CURRENT" = "personal" ]; then
        rm -f "$OVERRIDE_FILE"
        ${pkgs.libnotify}/bin/notify-send "Браузер" "Режим: Auto (по воркспейсу)" -i yandex-browser -h string:x-canonical-private-synchronous:browser-mode
      else
        echo "work" > "$OVERRIDE_FILE"
        ${pkgs.libnotify}/bin/notify-send "Браузер" "Режим: Work (Profile 1)" -i yandex-browser -h string:x-canonical-private-synchronous:browser-mode
      fi
      exit 0
    fi

    URL="$1"

    # 1. Определяем профиль
    if [ -f "$OVERRIDE_FILE" ]; then
      VAL=$(cat "$OVERRIDE_FILE" | xargs)
      if [ "$VAL" = "work" ]; then
        PROFILE="Profile 1"
        TITLE_PAT="xsen1"
        DEFAULT_WS=1
      elif [ "$VAL" = "personal" ]; then
        PROFILE="Profile 2"
        TITLE_PAT="xsen2"
        DEFAULT_WS=3
      fi
    fi

    if [ -z "$PROFILE" ]; then
      ACTIVE_WS=$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.id' 2>/dev/null || echo 1)
      # Если активный ворксейс 1 или 2, используем рабочий профиль
      if [ "$ACTIVE_WS" = "1" ] || [ "$ACTIVE_WS" = "2" ]; then
        PROFILE="Profile 1"
        TITLE_PAT="xsen1"
        DEFAULT_WS=1
      else
        PROFILE="Profile 2"
        TITLE_PAT="xsen2"
        DEFAULT_WS=3
      fi
    fi

    # 2. Запускаем браузер
    if [ -z "$URL" ]; then
      # Если URL пустой, ищем существующее окно для фокуса
      WS=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r --arg pat "$TITLE_PAT" '.[] | select((.class | test("^[yY]andex-browser$")) and (.title | test($pat))) | .workspace.id' | head -n 1)
      if [ -n "$WS" ] && [ "$WS" != "null" ] && [ "$WS" != "-1" ]; then
        ADDR=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r --arg pat "$TITLE_PAT" '.[] | select((.class | test("^[yY]andex-browser$")) and (.title | test($pat))) | .address' | head -n 1)
        ${pkgs.hyprland}/bin/hyprctl dispatch workspace "$WS"
        ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
      else
        yandex-browser-stable --profile-directory="$PROFILE" &
      fi
    else
      yandex-browser-stable --profile-directory="$PROFILE" "$URL" &
    fi

    # 3. Переключаем ворксейс на тот, где открылось окно, и фокусируем его
    # Даем небольшую паузу
    sleep 0.15

    for i in {1..20}; do
      WS=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r --arg pat "$TITLE_PAT" '.[] | select((.class | test("^[yY]andex-browser$")) and (.title | test($pat))) | .workspace.id' | head -n 1)
      if [ -n "$WS" ] && [ "$WS" != "null" ] && [ "$WS" != "-1" ]; then
        break
      fi
      sleep 0.1
    done

    if [ -z "$WS" ] || [ "$WS" = "null" ] || [ "$WS" = "-1" ]; then
      WS=$DEFAULT_WS
    fi

    ADDR=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r --arg pat "$TITLE_PAT" '.[] | select((.class | test("^[yY]andex-browser$")) and (.title | test($pat))) | .address' | head -n 1)

    ${pkgs.hyprland}/bin/hyprctl dispatch workspace "$WS"
    if [ -n "$ADDR" ] && [ "$ADDR" != "null" ]; then
      ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow "address:$ADDR"
    else
      ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow "title:$TITLE_PAT"
    fi
  '';
in
{
  home.packages = [ browser-dispatcher ];

  xdg.desktopEntries.browser-dispatcher = {
    name = "Browser Dispatcher";
    genericName = "Web Browser";
    exec = "${browser-dispatcher}/bin/browser-dispatcher %u";
    terminal = false;
    icon = "yandex-browser";
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };
}
