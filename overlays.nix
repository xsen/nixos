{ inputs, ... }:

final: prev: {
  yandex-browser-stable = inputs.yandex-browser.packages.${prev.system}.yandex-browser-stable;

  discord = prev.discord.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
    postInstall = (oldAttrs.postInstall or "") + ''
      wrapProgram "$out/bin/discord" --add-flags "--disable-gpu-compositing"
    '';
  });
}
