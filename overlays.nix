{ inputs }:

self: super: {
  yandex-browser-stable = inputs.yandex-browser.packages.${super.system}.yandex-browser-stable;

  discord = super.discord.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ self.makeWrapper ];
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        wrapProgram "$out/bin/discord" --add-flags "--disable-gpu-compositing"
      '';
  });

  nekoray = super.nekoray.overrideAttrs (oldAttrs: {
    installPhase = ''
      runHook preInstall

      install -Dm755 nekoray "$out/share/nekoray/nekoray"
      mkdir -p "$out/bin"
      ln -s "$out/share/nekoray/nekoray" "$out/bin"
      ln -sf /run/wrappers/bin/nekobox_core "$out/share/nekoray/nekobox_core"

      ln -s ${super.sing-geoip}/share/sing-box/geoip.db "$out/share/nekoray/geoip.db"
      ln -s ${super.sing-geosite}/share/sing-box/geosite.db "$out/share/nekoray/geosite.db"

      runHook postInstall
    '';
  });
}
