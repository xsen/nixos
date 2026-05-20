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

  claude-code = pkgs-master.claude-code;

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
