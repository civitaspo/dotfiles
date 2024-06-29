{ inputs, config, lib, pkgs, ... }:

{
  bat.enable = true;
  bat.config = {
    map-syntax = [
      "*.yml.liquid:YAML"
    ];
  };
}
