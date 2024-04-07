{ inputs, config, lib, pkgs, ... }:

let
  programsDir = ../programs;
in
  with builtins;
  foldl' (acc: path: acc // (import path { inherit inputs config lib pkgs; } ))
    {}
    (map (n: (programsDir + ("/" + n)))
      (filter (n: match ".*\\.nix" n != null)
        (attrNames (readDir programsDir))))
