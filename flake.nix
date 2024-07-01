{
  description = "NixOS systems and tools by civitaspo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles-private = {
      url = "git+ssh://git@github.com/civitaspo/dotfiles-private";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
    let
      overlays = [
      ];
      mkSystem = import ./lib/mkSystem.nix {
        inherit overlays nixpkgs inputs;
      };
    in {
      darwinConfigurations.macbook-XW7J7X4RP0 = mkSystem "macbook-XW7J7X4RP0" {
        system = "aarch64-darwin";
        user   = "takahiro.nakayama";
      };
      darwinConfigurations.macbook-CY9T2WWJPX = mkSystem "macbook-CY9T2WWJPX" {
        system = "aarch64-darwin";
        user   = "takahiro.nakayama";
      };
      darwinConfigurations.macbook-H7QRCQLYPP = mkSystem "macbook-H7QRCQLYPP" {
        system = "aarch64-darwin";
        user   = "takahiro.nakayama";
      };
    };
}
