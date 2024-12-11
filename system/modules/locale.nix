{ ... }:
{
  time.timeZone = "Asia/Yekaterinburg";

  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
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

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
  ];

  services.xserver = {
    xkb = {
      layout = "us,ru";
      options = "grp:caps_toggle,grp_led:caps";
    };
    displayManager = {
      sessionCommands = ''
        export LANG=ru_RU.UTF-8
        export LC_CTYPE="ru_RU.UTF-8"
        export LC_NUMERIC=ru_RU.UTF-8
        export LC_TIME=ru_RU.UTF-8
        export LC_COLLATE="ru_RU.UTF-8"
        export LC_MONETARY=ru_RU.UTF-8
        export LC_MESSAGES="ru_RU.UTF-8"
        export LC_PAPER=ru_RU.UTF-8
        export LC_NAME=ru_RU.UTF-8
        export LC_ADDRESS=ru_RU.UTF-8
        export LC_TELEPHONE=ru_RU.UTF-8
        export LC_MEASUREMENT=ru_RU.UTF-8
        export LC_IDENTIFICATION=ru_RU.UTF-8
      '';
    };
  };

}
