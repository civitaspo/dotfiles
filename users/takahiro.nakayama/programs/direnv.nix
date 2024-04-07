{ inputs, config, lib, pkgs, ... }: {
  direnv.enable = true;
  direnv.enableZshIntegration = true;
  direnv.nix-direnv.enable = true;
}
