{ config, ... }: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Текст и разметка (по умолчанию в Zed)
      "text/markdown" = [ "dev.zed.Zed.desktop" "nvim.desktop" ];
      "text/x-markdown" = [ "dev.zed.Zed.desktop" "nvim.desktop" ];
      "application/json" = [ "dev.zed.Zed.desktop" "gvim.desktop" ];
      "text/plain" = [ "dev.zed.Zed.desktop" ];
      "text/x-log" = [ "dev.zed.Zed.desktop" ];

      # Языки разметки и конфигурации
      "text/x-nix" = [ "dev.zed.Zed.desktop" ];
      "text/x-toml" = [ "dev.zed.Zed.desktop" ];
      "text/x-yaml" = [ "dev.zed.Zed.desktop" ];
      "text/yaml" = [ "dev.zed.Zed.desktop" ];
      "application/x-yaml" = [ "dev.zed.Zed.desktop" ];
      "application/yaml" = [ "dev.zed.Zed.desktop" ];

      # Скрипты
      "text/x-shellscript" = [ "dev.zed.Zed.desktop" ];
      "application/x-shellscript" = [ "dev.zed.Zed.desktop" ];

      # Разработка на PHP
      "text/x-php" = [ "dev.zed.Zed.desktop" ];
      "application/x-php" = [ "dev.zed.Zed.desktop" ];

      # Веб-технологии
      "text/css" = [ "dev.zed.Zed.desktop" ];
      "text/javascript" = [ "dev.zed.Zed.desktop" ];
      "application/javascript" = [ "dev.zed.Zed.desktop" ];
      "application/typescript" = [ "dev.zed.Zed.desktop" ];

      # Системные языки программирования
      "text/x-python" = [ "dev.zed.Zed.desktop" ];
      "text/x-rust" = [ "dev.zed.Zed.desktop" ];
      "text/x-go" = [ "dev.zed.Zed.desktop" ];
      "text/x-csrc" = [ "dev.zed.Zed.desktop" ];
      "text/x-c++src" = [ "dev.zed.Zed.desktop" ];
      "text/x-chdr" = [ "dev.zed.Zed.desktop" ];
      "text/x-c++hdr" = [ "dev.zed.Zed.desktop" ];

      # Браузерные и внешние обработчики
      "text/html" = [ "yandex-browser.desktop" ];
      "x-scheme-handler/http" = [ "yandex-browser.desktop" ];
      "x-scheme-handler/https" = [ "yandex-browser.desktop" ];
      "x-scheme-handler/about" = [ "yandex-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "yandex-browser.desktop" ];
      "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/jetbrains" = [ "jetbrainsd.desktop" ];
      "x-scheme-handler/mailto" = [ "yandex-browser.desktop" ];
      "x-scheme-handler/figma" = [ "figma-linux.desktop" ];
      "x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];
      "inode/directory" = [ "ghostty-yazi.desktop" ];

      # Изображения (по умолчанию в Viewnior)
      "image/png" = [ "viewnior.desktop" ];
      "image/jpeg" = [ "viewnior.desktop" ];
      "image/jpg" = [ "viewnior.desktop" ];
      "image/gif" = [ "viewnior.desktop" ];
      "image/webp" = [ "viewnior.desktop" ];
      "image/bmp" = [ "viewnior.desktop" ];
    };
    associations = {
      added = {
        "image/png" = [ "viewnior.desktop" "yandex-browser.desktop" ];
        "image/jpeg" = [ "viewnior.desktop" "yandex-browser.desktop" ];
        "image/jpg" = [ "viewnior.desktop" "yandex-browser.desktop" ];
        "image/gif" = [ "viewnior.desktop" "yandex-browser.desktop" ];
        "image/webp" = [ "viewnior.desktop" "yandex-browser.desktop" ];
        "image/bmp" = [ "viewnior.desktop" "yandex-browser.desktop" ];
        "x-scheme-handler/tg" = [ "org.telegram.telegram-desktop" "org.telegram.desktop.desktop" ];
        "x-scheme-handler/tonsite" = [ "org.telegram.telegram-desktop" "org.telegram.desktop.desktop" ];
        "application/json" = [ "dev.zed.Zed.desktop" "gvim.desktop" "yandex-browser.desktop" ];
        "text/plain" = [ "jetbrains-phpstorm-48772c4e-b18a-4415-ba39-fbfad2359cfa.desktop" "gvim.desktop" "writer.desktop" ];
      };
    };
  };
}
