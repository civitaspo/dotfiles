{ nixpkgs, overlays, inputs }:

name:
{
  system,
  user,
  wsl ? false,
}:
# My configuration is only supported on these systems.
# See all nix supported systems here: https://github.com/NixOS/nix/blob/f8916734601b9492c8e9d3f3765ef94487b9ade9/flake.nix#L25-L42
assert (system == "aarch64-linux" || system == "x86_64-linux" || system == "aarch64-darwin");
let
  os = elemAt (splitString "-" system) 1;
  cpuArch = elemAt (splitString "-" system) 0;
  isWSL = wsl;
  isDarwin = os == "darwin";
  _ = nixpkgs.lib.throwIf (isWSL && isDarwin) "WSL and Darwin are mutually exclusive";

  machineConfig = ../machines/${name}.nix;
  userOSConfig = ../users/${user}/${os}.nix;
  userHMConfig = ../users/${user}/home-manager.nix;

  systemFunc = if isDarwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager = if isDarwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
in systemFunc rec {
  inherit system;

  modules = [
    { nixpkgs.overlays = overlays; }
    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else {})

    machineConfig
    userOSConfig
    home-manager.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import userHMConfig {
        isWSL = isWSL;
        inputs = inputs;
      };
    }

    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        isWSL = isWSL;
        inputs = inputs;
      };
    }
  ];
}
