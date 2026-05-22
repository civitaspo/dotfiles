# nix-darwin system configuration.
#
# Scope: macOS system-level settings only. Binaries are managed by mise,
# applications by Homebrew (Brewfile), and dotfiles by `task reconcile`.
{ pkgs, hostname, inputs, ... }:

{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  nixpkgs.config.allowUnfree = true;

  # Nix itself is installed and managed by the Determinate Systems installer
  # (see init.sh), so nix-darwin must not manage the Nix daemon or nix.conf.
  nix.enable = false;

  networking.hostName = hostname;
  networking.computerName = hostname;

  # Owner of the macOS defaults and activation hooks below.
  system.primaryUser = "takahiro.nakayama";
  users.users."takahiro.nakayama" = {
    home = "/Users/takahiro.nakayama";
    shell = pkgs.zsh;
  };

  # home-manager places this user's dotfiles (see nix/home.nix). Pre-existing
  # files are moved aside with a .backup suffix on first activation.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users."takahiro.nakayama" = import ./home.nix;
  };

  programs.zsh.enable = true;
  environment.shells = with pkgs; [ bashInteractive zsh ];

  # Base CLI packages. Homebrew is GUI-apps only and dev tools come from mise;
  # everything else (GNU userland, git, shell plugins) is installed here.
  environment.systemPackages = with pkgs; [
    coreutils
    findutils
    gnused
    gnutar
    gawk
    gnugrep
    curl
    wget
    openssl
    gnupg
    git
    git-lfs
    mas
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
  ];

  # Touch ID for sudo.
  security.pam.services.sudo_local.touchIdAuth = true;

  time.timeZone = "Asia/Tokyo";

  # Raise file descriptor limits (2^19).
  launchd.daemons = {
    sysctl = {
      serviceConfig.Label = "sysctl";
      serviceConfig.ProgramArguments = [
        "sysctl"
        "-w"
        "kern.maxfiles=524288"
        "kern.maxfilesperproc=524288"
      ];
      serviceConfig.RunAtLoad = true;
    };
    "launchctl.maxfiles" = {
      serviceConfig.Label = "launchctl.maxfiles";
      serviceConfig.ProgramArguments = [
        "launchctl"
        "limit"
        "maxfiles"
        "524288"
        "524288"
      ];
      serviceConfig.RunAtLoad = true;
    };
  };

  system.stateVersion = 4;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults = {
    LaunchServices.LSQuarantine = false;
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleMeasurementUnits = "Centimeters";
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "WhenScrolling";
      AppleTemperatureUnit = "Celsius";
      InitialKeyRepeat = 15;
      KeyRepeat = 1;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticWindowAnimationsEnabled = false;
      NSDisableAutomaticTermination = true;
      NSWindowResizeTime = 0.001;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.sound.beep.volume" = 0.0;
      "com.apple.sound.beep.feedback" = 0;
      "com.apple.trackpad.enableSecondaryClick" = true;
    };
    dock = {
      autohide = false;
      show-recents = false;
      launchanim = true;
      mouse-over-hilite-stack = true;
      orientation = "bottom";
      tilesize = 48;
    };
    finder = {
      _FXShowPosixPathInTitle = false;
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  };

  # Disable Spotlight indexing.
  system.activationScripts.postActivation.text = ''
    printf "disabling spotlight indexing... "
    mdutil -i off -d / &> /dev/null
    mdutil -E / &> /dev/null
    echo "ok"
  '';
}
