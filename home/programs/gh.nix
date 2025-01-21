{ inputs, config, lib, pkgs, ... }:

{
  gh.enable = true;
  gh.extensions = [
    inputs.nixpkgs-unstable.legacyPackages.${system}.gh-dash
  ];
  gh.gitCredentialHelper.enable = true;
  gh.settings = {
    version = "1";
    git_protocol = "ssh";
    editor =  "nvim";
  };
}
