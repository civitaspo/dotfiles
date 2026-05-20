{
  description = "civitaspo's macOS configuration (nix-darwin + home-manager)";

  inputs = {
    # nix-darwin enforces that nixpkgs and nix-darwin sit on matching
    # branches: nixpkgs-unstable pairs only with nix-darwin `master`. Since
    # `master` is avoided for supply-chain safety, all three inputs are
    # pinned to the 25.11 release line (the macOS stable channel).
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
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
  };

  outputs = { self, nixpkgs, darwin, ... }@inputs:
    let
      # Machines are identified by their device serial number.
      hostnames = [
        "macbook-XW7J7X4RP0"
        "macbook-CY9T2WWJPX"
        "macbook-H7QRCQLYPP"
      ];
      mkDarwin = hostname:
        darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs hostname; };
          modules = [ ./nix/darwin.nix ];
        };
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs hostnames mkDarwin;
    };
}
