{
  pkgs,
  username,
  host,
  ...
}:
{
  nix = {
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://mirror.yandex.ru/nixos"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMAL6K3UID8B4JHiDncSrxVOKZm5JwLg="
      ];
    };
  };

  hardware.bluetooth.enable = true;

  services = {
    flatpak.enable = true;
    upower.enable = true;
    pulseaudio.enable = false;
    journald.extraConfig = "SystemMaxUse=1G";
    gvfs.enable = true;
    udisks2.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
    };

    gnome = {
      gcr-ssh-agent.enable = false;
      gnome-keyring.enable = true;
    };

    displayManager = {
      sddm = {
        enable = true;
        autoNumlock = true;
        wayland.enable = true;
        enableHidpi = true;
        package = pkgs.kdePackages.sddm;
      };
    };

    xserver = {
      xkb = {
        layout = "us,ru-pro";
        options = "grp:caps_toggle,grp_led:caps";
        extraLayouts.ru-pro = {
          description = "Russian layout with US symbols on AltGr";
          languages = [ "ru" ];
          symbolsFile = pkgs.writeText "ru-pro.xkb" ''
            xkb_symbols "basic" {
              include "ru(winkeys)"
              include "level3(ralt_switch)"

              key <AE01> { [ 1, exclam, exclam, exclam ] };
              key <AE02> { [ 2, quotedbl, at, at ] };
              key <AE03> { [ 3, numerosign, numbersign, numbersign ] };
              key <AE04> { [ 4, semicolon, dollar, dollar ] };
              key <AE05> { [ 5, percent, percent, percent ] };
              key <AE06> { [ 6, colon, asciicircum, asciicircum ] };
              key <AE07> { [ 7, question, ampersand, ampersand ] };
              key <AE08> { [ 8, asterisk, asterisk, asterisk ] };
              key <AE09> { [ 9, parenleft, parenleft, parenleft ] };
              key <AE10> { [ 0, parenright, parenright, parenright ] };
              key <AE11> { [ minus, underscore, minus, underscore ] };
              key <AE12> { [ equal, plus, equal, plus ] };

              key <AD11> { [ Cyrillic_ha, Cyrillic_HA, bracketleft, braceleft ] };
              key <AD12> { [ Cyrillic_hardsign, Cyrillic_HARDSIGN, bracketright, braceright ] };
              key <AC10> { [ Cyrillic_zhe, Cyrillic_ZHE, semicolon, colon ] };
              key <AC11> { [ Cyrillic_e, Cyrillic_E, apostrophe, quotedbl ] };
              key <AB08> { [ Cyrillic_be, Cyrillic_BE, comma, less ] };
              key <AB09> { [ Cyrillic_yu, Cyrillic_YU, period, greater ] };
              key <BKSL> { [ backslash, slash, backslash, bar ] };
            };
          '';
        };
      };
    };

    pipewire = {
      enable = true;
      jack.enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      wireplumber.extraConfig = {
        "10-disable-suspend" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                { "node.name" = "~alsa_input.*"; }
                { "node.name" = "~alsa_output.*"; }
              ];
              actions = {
                update-props = {
                  "session.suspend-timeout-seconds" = 0;
                };
              };
            }
          ];
        };
      };
    };

    syncthing = {
      enable = true;
      user = username;
      dataDir = "/home/${username}/Cloud/Syncthing";
      overrideDevices = false;
      overrideFolders = false;
      settings = {
        folders = {
          "Books" = {
            path = "/home/${username}/Cloud/Syncthing/Books";
          };
        };
      };
    };
  };

  security = {
    rtkit.enable = true;
    pam.services.login.enableGnomeKeyring = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  systemd.services.sddm-wallpaper = {
    description = "Update SDDM wallpaper";
    script = ''
      mkdir -p /background
      chmod 755 /background
      if [ -f "/home/${username}/.wallpapers/current.png" ]; then
        cp -f "/home/${username}/.wallpapers/current.png" "/background/current.png"
      else
        echo "Warning: Source wallpaper not found!" >&2
      fi
    '';
    serviceConfig.Type = "oneshot";
    wantedBy = [ "display-manager.service" ];
  };

  networking = {
    hostName = host;

    nftables.enable = true;
    networkmanager.enable = true;
    enableIPv6 = false;

    firewall = {
      enable = true;
      checkReversePath = false;
      allowedTCPPorts = [
        9003
        8384
        22000
        53317
      ];
      allowedUDPPorts = [
        22000
        21027
        53317
      ];

      trustedInterfaces = [
        "lo"
        "br-*"
        "docker0"
      ];
    };
  };

  time.timeZone = "Asia/Yekaterinburg";

  i18n = {
    defaultLocale = "ru_RU.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
    supportedLocales = [
      "ru_RU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  users.users."${username}" = {
    isNormalUser = true;
    description = "Evgeny";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  console = {
    font = "ter-v32n";
    earlySetup = true;
    useXkbConfig = true;
    packages = [ pkgs.terminus_font ];
  };

  fonts.packages = with pkgs; [
    font-awesome
    terminus_font
    nerd-fonts.jetbrains-mono
    noto-fonts
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";

    sddm = {
      fontSize = "20";
      background = "/background/current.png";
      font = "JetBrainsMono Nerd Font";
    };
  };

  environment = {
    variables = {
      EDITOR = "vim";
    };
    sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
    };
  };

  system = {
    activationScripts.binbash = ''
      mkdir -p /bin
      ln -sfn ${pkgs.bash}/bin/bash /bin/bash
    '';
  };
}
