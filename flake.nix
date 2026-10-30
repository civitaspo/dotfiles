{
  description = "civitaspo's macOS configuration (nix-darwin + home-manager)";

  inputs = {
    # nixpkgs-unstable follows nixpkgs/master with a few-days delay through
    # Hydra channel CI. That quarantine period gives upstream supply-chain
    # incidents time to surface before reaching us, so it is the default;
    # `master` itself is avoided. nix-darwin's release branch normally
    # refuses this pairing, so the check is disabled in the darwinSystem
    # call below.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Pinned Python for the private skill-links check.
    nixpkgs-python.url = "github:NixOS/nixpkgs/9d29d5f667d7467f98efc31881e824fa586c927e";

    # nix-darwin and home-manager are pinned to release branches; no `master`.
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private dotfiles, placed into $HOME by home-manager.
    dotfiles-private = {
      url = "git+ssh://git@github.com/civitaspo/dotfiles-private";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { darwin, ... }@inputs:
    {
      # Single hostname-agnostic configuration, keyed by system. Every
      # machine activates it as `.#aarch64-darwin`. The macOS hostname is
      # left alone.
      darwinConfigurations.aarch64-darwin = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        # Pairing nix-darwin's release-25.11 branch with nixpkgs-unstable
        # is intentional (see the nixpkgs comment above); bypass the
        # branch-matching check that would otherwise refuse it.
        enableNixpkgsReleaseCheck = false;
        modules = [ ./nix/darwin.nix ];
      };

      # Private skill links must resolve both in .agents/skills and when the
      # skills CLI publishes each skill as a sibling.
      checks.aarch64-darwin.skill-links =
        let
          pkgs = inputs.nixpkgs-python.legacyPackages.aarch64-darwin;
        in
        pkgs.runCommand "skill-links" { nativeBuildInputs = [ pkgs.python313 ]; } ''
          python3 ${inputs.dotfiles-private}/scripts/check-skill-links.py
          touch $out
        '';
    };
}
