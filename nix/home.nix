# home-manager configuration.
#
# Its only job is to place plain dotfiles:
#   config/  -> ~/.config
#   home/    -> $HOME
# Private dotfiles come from the dotfiles-private flake input. Directory
# sources are linked recursively so a tool can still write runtime state
# next to its managed files (e.g. ~/.config/nvim, ~/.claude).
{ lib, inputs, ... }:

let
  # Turn each top-level entry of `dir` into a home-manager file entry.
  linkDir = dir:
    lib.mapAttrs
      (name: type: {
        source = dir + "/${name}";
        recursive = type == "directory";
      })
      (builtins.readDir dir);

  private = "${inputs.dotfiles-private}/home";
in
{
  home.stateVersion = "24.11";

  xdg.enable = true;
  xdg.configFile = linkDir ../config;

  home.file =
    # Public dotfiles. ~/.ssh is handled separately below because it is
    # split between this repository and the private one.
    builtins.removeAttrs (linkDir ../home) [ ".ssh" ]
    // {
      ".ssh/config".source = ../home/.ssh/config;
      # Private dotfiles.
      ".aws" = { source = "${private}/.aws"; recursive = true; };
      ".snowsql" = { source = "${private}/.snowsql"; recursive = true; };
      ".claude" = { source = "${private}/.claude"; recursive = true; };
      ".codex" = { source = "${private}/.codex"; recursive = true; };
      ".ssh/config.d" = { source = "${private}/.ssh/config.d"; recursive = true; };
    };
}
