{
  description = "NixOS systems and tools by civitaspo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # Only need unstable until the lpeg fix hits mainline, probably
      # not very long... can safely switch back for 23.11.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlay
      ];
      mkSystem = import ./lib/mkSystem.nix {
        inherit overlays nixpkgs inputs;
      };
    in {
      darwinConfigurations.macbook-pro-m1-XW7J7X4RP0 = mkSystem "macbook-pro-m1-XW7J7X4RP0" {
        system = "aarch64-darwin";
        user   = "takahiro.nakayama";
      };
    };
}
