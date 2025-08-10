{ inputs, pkgs, ... }:

let
  user = "takahiro.nakayama";
in {
  nixpkgs.overlays = import ../lib/overlays.nix;

  # Binary cache configuration for faster builds
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="  # From: https://nix-community.org/cache/
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="             # From: https://garnix.io/docs/caching
    ];
  };

  homebrew = {
    enable = true;
    taps = [
      "nikitabobko/tap"
    ];
    brews = [
    ];
    casks  = [
      "1password"
      "tabtab"
      "arc"
      "cursor"
      "chatgpt"
      "chatwise"
      "flashspace"
      "gather"
      "ghostty"
      "google-japanese-ime"
      "hammerspoon"
      "homerow"
      "karabiner-elements"
      "keyboard-maestro"
      "mimestream"
      "qmk-toolbox"
      "raycast"
      "setapp"
      "snowflake-snowsql"
      "spotify"
      "thingsmacsandboxhelper"
      "aerospace"
    ];
    masApps = {
      "Anybox" = 1593408455;
      "Bear" = 1091189122;
      "Display Menu" =  549083868;
      "Goodnotes 6" = 1444383602;
      "Klack" = 6446206067;
      "LINE" = 539883307;
      # "Microsoft Excel" = 462058435;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Things" = 904280696;
    };
    onActivation = {
      cleanup = "zap";
    };
  };
  users.users.${user} = {
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };
  time.timeZone = "Asia/Tokyo";
  system = {
    stateVersion = 4;
    defaults = {
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
        # TODO
        # persistent-apps = [
        #   "/Applications/Safari.app"
        #   "/System/Applications/Utilities/Terminal.app"
        # ];
      };
      finder = {
        _FXShowPosixPathInTitle = false;
      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    activationScripts.postActivation.text = ''
      printf "disabling spotlight indexing... "
      mdutil -i off -d / &> /dev/null
      mdutil -E / &> /dev/null
      echo "ok"
    '';
  };
}
