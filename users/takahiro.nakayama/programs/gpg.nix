{ inputs, config, lib, pkgs, ... }:

{
  gpg.enable = true;
  gpg.homedir = "${config.home.homeDirectory}/.gnupg";
  gpg.publicKeys = [
    # { source = ./pubkeys.txt; }
  ];
}
