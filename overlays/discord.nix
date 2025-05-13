self: super: {
  discord = super.discord.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ self.makeWrapper ];
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        wrapProgram "$out/bin/Discord" --add-flags "--disable-gpu-compositing"
      '';
  });
}
