{ inputs, config, lib, pkgs, ... }: {
  gh.enable = true;
  gh.extensions = [];
  gh.gitCredentialHelper.enable = true;
  gh.settings = {
    git_protocol = "ssh";
  };
}
