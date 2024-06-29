{ inputs, config, lib, pkgs, ... }:

{
  gh.enable = true;
  gh.extensions = [
    pkgs.gh-dash
  ];
  gh.gitCredentialHelper.enable = true;
  gh.settings = {
    version = "1";
    git_protocol = "ssh";
    editor =  "nvim";
  };
}
