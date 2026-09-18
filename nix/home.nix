# home-manager configuration.
#
# Its only job is to place plain dotfiles:
#   config/  -> ~/.config
#   home/    -> $HOME
# Private dotfiles come from the dotfiles-private flake input. Directory
# sources are linked recursively so a tool can still write runtime state
# next to its managed files (e.g. ~/.config/nvim).
# Agent skill trees stay in the private repo under home/.agents/. home-manager
# does not install ~/.agents; Cursor, Codex, and Claude Code each get a
# published skills root.
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

  private = inputs.dotfiles-private + "/home";

  # Directories that contain SKILL.md, stopping at that leaf. Claude Code
  # only loads ~/.claude/skills/<name>/SKILL.md and does not recurse.
  collectSkillDirs = dir:
    let
      entries = builtins.readDir dir;
      go = name:
        let
          path = dir + "/${name}";
        in
        if entries.${name} != "directory" then
          [ ]
        else if builtins.pathExists (path + "/SKILL.md") then
          [ path ]
        else
          collectSkillDirs path;
    in
    lib.concatMap go (builtins.attrNames entries);

  claudeSkillLinks =
    let
      dirs = collectSkillDirs (private + "/.agents/skills");
      skillName = d: baseNameOf (toString d);
      grouped = lib.groupBy skillName dirs;
      collisions = lib.filterAttrs (_: xs: lib.length xs > 1) grouped;
    in
    assert lib.assertMsg
      (collisions == { })
      "Duplicate Claude skill basenames under home/.agents/skills: ${lib.concatStringsSep ", " (lib.attrNames collisions)}";
    lib.listToAttrs (map
      (d: {
        name = ".claude/skills/${skillName d}";
        value = { source = d; };
      })
      dirs);
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
        ".aws" = { source = private + "/.aws"; recursive = true; };
        ".snowsql" = { source = private + "/.snowsql"; recursive = true; };
        # Keep each skill tree as a single directory symlink. Recursive
        # per-file links race on mkdir for the large Snowflake catalog.
        # Cursor Cloud Agents copy ~/.cursor/skills/ only. Codex reads
        # ~/.codex/skills/. Claude Code only discovers one level under
        # ~/.claude/skills/, so each skill directory is published flattened
        # by basename. The catalog sits beside those roots so it is not
        # auto-scanned.
        ".cursor/skills".source = private + "/.agents/skills";
        ".codex/skills".source = private + "/.agents/skills";
        ".cursor/snowflake-skills".source = private + "/.agents/snowflake-skills";
        ".codex/snowflake-skills".source = private + "/.agents/snowflake-skills";
        ".claude/snowflake-skills".source = private + "/.agents/snowflake-skills";
        ".ssh/config.d" = { source = private + "/.ssh/config.d"; recursive = true; };
      }
      // claudeSkillLinks;
  };

  xdg = {
    enable = true;
    configFile =
      let
        privateDeck = inputs.dotfiles-private + "/config/deck";
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
