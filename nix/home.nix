# home-manager configuration.
#
# Its only job is to place plain dotfiles:
#   config/  -> ~/.config
#   home/    -> $HOME
# Private dotfiles come from the dotfiles-private flake input. Directory
# sources are linked recursively so a tool can still write runtime state
# next to its managed files (e.g. ~/.config/nvim).
# Agent skills are installed by the skills CLI (mise-tasks/skills/sync).
# CoCo bundled skills stay in the mise installation.
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
        ".ssh/config.d" = { source = private + "/.ssh/config.d"; recursive = true; };
      }
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
