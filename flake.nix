{
  description = "civitaspo's macOS configuration (nix-darwin + mise)";

  inputs = {
    # nixpkgs-unstable follows nixpkgs/master with a few-days delay through
    # Hydra channel CI. That quarantine period gives upstream supply-chain
    # incidents time to surface before reaching us, so it is the default;
    # `master` itself is avoided. nix-darwin's release branch normally
    # refuses this pairing, so the check is disabled in the darwinSystem
    # call below.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin is pinned to a release branch; no `master`.
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
