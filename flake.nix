{
  description = "civitaspo's macOS configuration (nix-darwin, nixpkgs-unstable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, ... }:
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
          specialArgs = { inherit hostname; };
          modules = [ ./nix/darwin.nix ];
        };
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs hostnames mkDarwin;
    };
}
