{ config, pkgs, ... }: {
  nix = {
    useDaemon = true;
    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
      keep-outputs = true
      keep-derivations = true
      max-jobs = auto
      extra-nix-path = nixpkgs=flake:nixpkgs
      upgrade-nix-store-path-url = https://install.determinate.systems/nix-upgrade/stable/universal
    '';
  };
  programs.zsh= {
    enable = true;
    shellInit = ''
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix
      '';
  };
  environment.shells = with pkgs; [ bashInteractive zsh ];
  environment.systemPackages = with pkgs; [ ];
  security.pam.enableSudoTouchIdAuth = true;
  launchd.daemons = {
    sysctl = {
      serviceConfig.Label = "sysctl";
      serviceConfig.ProgramArguments = [
        "sysctl"
        "-w"
        "kern.maxfiles=524288"        # 2^19
        "kern.maxfilesperproc=524288" # 2^19
      ];
      serviceConfig.RunAtLoad = true;
    };
    "launchctl.maxfiles" = {
      serviceConfig.Label = "launchctl.maxfiles";
      serviceConfig.ProgramArguments = [
        "launchctl"
        "limit"
        "maxfiles"
        "524288" # 2^19
        "524288" # 2^19
      ];
      serviceConfig.RunAtLoad = true;
    };
  };
}
