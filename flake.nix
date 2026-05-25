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

    # Pinned per-tool nixpkgs commits, so language runtimes and tools don't
    # drift on every nixpkgs-unstable update. Bump one with:
    #   nix flake lock --update-input nixpkgs-<tool>
    nixpkgs-python.url          = "github:NixOS/nixpkgs/9d29d5f667d7467f98efc31881e824fa586c927e"; # Python 3.13.12
    nixpkgs-node.url            = "github:NixOS/nixpkgs/9d29d5f667d7467f98efc31881e824fa586c927e"; # Node.js 22.22.2
    nixpkgs-go.url              = "github:NixOS/nixpkgs/01fbdeef22b76df85ea168fbfe1bfd9e63681b30"; # Go 1.26.2
    nixpkgs-terraform.url       = "github:NixOS/nixpkgs/a1bab9e494f5f4939442a57a58d0449a109593fe"; # Terraform 1.14.3
    nixpkgs-process-compose.url = "github:NixOS/nixpkgs/8a1b0127302ea51e05bf4ea5a291743fac442406"; # process-compose 1.110.0
    nixpkgs-k6.url              = "github:NixOS/nixpkgs/9d29d5f667d7467f98efc31881e824fa586c927e"; # k6 1.7.1

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
    };
}
