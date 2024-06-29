{ inputs, config, lib, pkgs, ... }:

{
  awscli.enable = true;
  awscli.settings = import "${inputs.dotfiles-private.outPath}/aws-config.nix";
}
