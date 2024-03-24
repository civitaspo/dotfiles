{ config, pkgs, ... }: {
  # Use nix-installer (https://install.determinate.systems/nix) to install Nix.
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
}
