# home-manager configuration.
#
# Its only job is to place plain dotfiles:
#   config/  -> ~/.config
#   home/    -> $HOME
# Private dotfiles come from the dotfiles-private flake input. Directory
# sources are linked recursively so a tool can still write runtime state
# next to its managed files (e.g. ~/.config/nvim, ~/.claude).
# ~/.cursor/skills is a single directory symlink from private; the rest of
# ~/.cursor stays local.
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
  home = {
    stateVersion = "24.11";

    # Match the nix-darwin override (see flake.nix): home-manager release-25.11
    # is paired with nixpkgs-unstable on purpose, so suppress the corresponding
    # version-mismatch warning.
    enableNixpkgsReleaseCheck = false;

    file =
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
        # Single directory symlink — recursive per-file links race on mkdir
        # for this large CoCo skills tree (~2500 files).
        ".cursor/skills".source = "${private}/.cursor/skills";
        ".ssh/config.d" = { source = "${private}/.ssh/config.d"; recursive = true; };
      };
  };

  xdg = {
    enable = true;
    configFile = linkDir ../config;
  };
}
