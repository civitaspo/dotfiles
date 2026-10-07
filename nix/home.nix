# home-manager configuration.
#
# Its only job is to place plain dotfiles:
#   config/  -> ~/.config
#   home/    -> $HOME
# Private dotfiles come from the dotfiles-private flake input. Directory
# sources are linked recursively so a tool can still write runtime state
# next to its managed files (e.g. ~/.config/nvim).
# Personal skills come from the private repo's home/.agents/skills. Codex
# Cursor, and OpenCode read the nested tree; Claude Code gets each skill flattened
# into ~/.claude/skills/<name>. The Snowflake catalog is generated separately.
{ lib, inputs, snowflakeSkills, ... }:

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
  privateMcpConfig = inputs.dotfiles-private + "/config/dotfiles/mcp.json";
  hasPrivateMcpConfig = builtins.pathExists privateMcpConfig;
  mcpServers = if hasPrivateMcpConfig then
    (builtins.fromJSON (builtins.readFile privateMcpConfig)).mcpServers
  else
    { };
  openCodeMcpServers = lib.mapAttrs (_: server: {
    type = "remote";
    inherit (server) url;
  }) mcpServers;
  openCodeConfig = builtins.fromJSON (builtins.readFile ../config/opencode/opencode.json);

  # Directories that contain SKILL.md, stopping at that leaf. Claude Code
  # only loads ~/.claude/skills/<name>/SKILL.md and does not recurse.
  # Carry the basename from readDir so home.file keys stay free of Nix
  # string context; baseNameOf (toString path) keeps a store-path context
  # and fails eval with "is not allowed to refer to a store path".
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
          [ { inherit name path; } ]
        else
          collectSkillDirs path;
    in
    lib.concatMap go (builtins.attrNames entries);

  claudeSkillLinks =
    let
      skills = collectSkillDirs (private + "/.agents/skills");
      grouped = lib.groupBy (s: s.name) skills;
      collisions = lib.filterAttrs (_: xs: lib.length xs > 1) grouped;
    in
    assert lib.assertMsg
      (collisions == { })
      "Duplicate Claude skill basenames under home/.agents/skills: ${lib.concatStringsSep ", " (lib.attrNames collisions)}";
    lib.listToAttrs (map
      (s: {
        name = ".claude/skills/${s.name}";
        value = { source = s.path; };
      })
      skills);
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
        # Codex, Cursor, and OpenCode read ~/.agents/skills/ recursively. Claude Code
        # does not read ~/.agents and only discovers one level under
        # ~/.claude/skills/, so each skill directory is also published
        # flattened by basename. The catalog sits beside the skills root so
        # it is not auto-scanned; Claude Code reads it by path.
        ".agents/skills".source = private + "/.agents/skills";
        ".agents/snowflake-skills".source = snowflakeSkills;
        ".ssh/config.d" = { source = private + "/.ssh/config.d"; recursive = true; };
      }
      // claudeSkillLinks
      // lib.optionalAttrs hasPrivateMcpConfig {
        ".cursor/mcp.json".source = builtins.toFile "cursor-mcp.json"
          ((builtins.toJSON { inherit mcpServers; }) + "\n");
      };
  };

  xdg = {
    enable = true;
    configFile =
      let
        privateConfig = inputs.dotfiles-private + "/config";
      in
      builtins.removeAttrs (linkDir ../config) (lib.optional hasPrivateMcpConfig "opencode")
      // lib.optionalAttrs hasPrivateMcpConfig {
        "opencode/opencode.json".source = builtins.toFile "opencode.json"
          ((builtins.toJSON (lib.recursiveUpdate openCodeConfig {
            mcp.servers = openCodeMcpServers;
          })) + "\n");
      }
      // lib.optionalAttrs (builtins.pathExists privateConfig) (linkDir privateConfig);
  };
}
