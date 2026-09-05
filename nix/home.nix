# home-manager configuration.
#
# Its only job is to place plain dotfiles:
#   config/  -> ~/.config
#   home/    -> $HOME
# Private dotfiles come from the dotfiles-private flake input. Directory
# sources are linked recursively so a tool can still write runtime state
# next to its managed files (e.g. ~/.config/nvim).
# Agent skill trees are directory symlinks from private so Cursor and Codex
# share the same managed configuration.
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
        ".agents/AGENTS.md".source = "${private}/.agents/AGENTS.md";
        # Keep each Agent Skills tree as a single directory symlink. Recursive
        # per-file links race on mkdir for the large Snowflake catalog.
        ".agents/skills".source = "${private}/.agents/skills";
        ".agents/snowflake-skills".source = "${private}/.agents/snowflake-skills";
        ".ssh/config.d" = { source = "${private}/.ssh/config.d"; recursive = true; };
      };
  };

  xdg = {
    enable = true;
    configFile =
      let
        privateDeck = "${inputs.dotfiles-private}/config/deck";
      in
      linkDir ../config
      // lib.optionalAttrs (builtins.pathExists privateDeck) {
        deck = {
          source = privateDeck;
          recursive = true;
        };
      };
  };
}
