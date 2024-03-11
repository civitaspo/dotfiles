{ config, pkgs, ... }:
let
  macUser = "takahiro.nakayama";
  githubUser = "civitaspo";
in {
  imports = [
    ./packages.nix
  ];
};
