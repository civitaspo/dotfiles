{
  description = "Civitaspo's Configurations for MacOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin } @inputs:
    let
      darwinSystems = ["aarch64-darwin"];
      forAllDarwinSystems = f: nixpkgs.lib.genAttrs darwinSystems f;
    in {
      darwinConfigurations = forAllDarwinSystems (system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            ./config.nix
          ];
        }
      );
    };
}
