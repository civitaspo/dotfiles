{ inputs, pkgs, ... }:

let
  user = "takahiro.nakayama";
in {
  nixpkgs.overlays = import ../../lib/overlays.nix;
  homebrew = {
    enable = true;
    taps = [
      "aquaproj/aqua"
    ];
    brews = [
      "aqua"
    ];
    casks  = [
      "anki"
      "arc"
      "chatgpt"
      "gather"
      "google-japanese-ime"
      "hammerspoon"
      "heptabase"
      "karabiner-elements"
      "mimestream"
      "miro"
      "notion-calendar"
      "rancher"
      "raycast"
      "setapp"
      "snowflake-snowsql"
      "thingsmacsandboxhelper"
    ];
    masApps = {
      "Display Menu" =  549083868;
      "Goodnotes 6" = 1444383602;
      "LINE" = 539883307;
      # "Microsoft Excel" = 462058435;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Things" = 904280696;
      "Twingate" = 1501592214;
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
  };
}
