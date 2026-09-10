{ inputs, ... }:

final: prev:
let
  pkgs-master = import inputs.nixpkgs-master {
    system = prev.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  yandex-browser-stable =
    inputs.yandex-browser.packages.${prev.stdenv.hostPlatform.system}.yandex-browser-stable;

  antigravity-cli = inputs.antigravity-cli.packages.${prev.stdenv.hostPlatform.system}.default;

  claude-code = pkgs-master.claude-code;

  evelens = prev.appimageTools.wrapType2 rec {
    pname = "evelens";
    version = "1.5.2";

    src = prev.fetchurl {
      url = "https://github.com/aliacollins/EveLens/releases/download/v${version}/EveLens-stable-linux-x86_64.AppImage";
      sha256 = "sha256-hDbhz49wS50kGB01uvOdYfcL1fbE+WRtFKKK7hwddmc=";
    };

    extraPkgs =
      pkgs: with pkgs; [
        icu
        openssl
        zlib
      ];

    extraInstallCommands =
      let
        contents = prev.appimageTools.extract { inherit pname version src; };
      in
      ''
        install -m 644 -D ${contents}/EveLens.desktop $out/share/applications/evelens.desktop
        substituteInPlace $out/share/applications/evelens.desktop \
          --replace-fail 'Exec=EveLens' $'Exec=evelens\nStartupWMClass=EveLens'
        install -m 444 -D ${contents}/evelens.png $out/share/icons/hicolor/256x256/apps/evelens.png
      '';
  };

  discord = prev.discord.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
    postInstall = (oldAttrs.postInstall or "") + ''
      wrapProgram "$out/bin/discord" --add-flags "--disable-gpu-compositing"
    '';
  });

  koreader = prev.symlinkJoin {
    name = "koreader";
    paths = [ prev.koreader ];
    nativeBuildInputs = [ final.makeWrapper ];
    postBuild = ''
      rm $out/bin/koreader
      makeWrapper ${prev.koreader}/bin/koreader $out/bin/koreader \
        --set SDL_VIDEODRIVER x11
    '';
  };
}
