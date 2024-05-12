final:
prev:

{
  sed-gsed = final.gnused.overrideAttrs (oldAttrs: {
    # For nvim-spectre https://github.com/nvim-pack/nvim-spectre/blob/4651801ba37a9407b7257287aec45b6653ffc5e9/lua/spectre/init.lua#L46-L51
    postInstall = ''
      ln -s $out/bin/sed $out/bin/gsed
    '';
  });
}
