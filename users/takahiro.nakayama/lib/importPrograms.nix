{ inputs, config, lib, pkgs, ... }:

let
  programsDir = ../programs;
  imports = lib.attrValues (lib.mapAttrs (_: value: value { inherit inputs config lib pkgs; }) (import programsDir));
in {
  lib.foldl' (acc: file: lib.recursiveUpdate acc file) {} imports;
}
