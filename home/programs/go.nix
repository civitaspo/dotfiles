{ inputs, config, lib, pkgs, ... }:

{
  go.enable = true;
  go.goBin = ".local/go/bin"; # $HOME/.local/go/bin
  go.goPath = "go"; # $HOME/go
}
