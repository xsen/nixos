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
    version = "1.3.0";

    src = prev.fetchurl {
      url = "https://github.com/aliacollins/EveLens/releases/download/v${version}/EveLens-stable-linux-x86_64.AppImage";
      sha256 = "668975e5de43ef2feb3b31a9c2e9478b13ff596959a78b793bfd7b3098f78bb4";
    };

    extraPkgs = pkgs: with pkgs; [
      icu
      openssl
      zlib
    ];

    extraInstallCommands =
      let
        contents = prev.appimageTools.extract { inherit pname version src; };
      in
      ''
        install -m 444 -D ${contents}/EveLens.desktop $out/share/applications/evelens.desktop
        substituteInPlace $out/share/applications/evelens.desktop \
          --replace 'Exec=EveLens' 'Exec=evelens'
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
