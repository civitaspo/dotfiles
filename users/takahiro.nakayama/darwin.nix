{ inputs, pkgs, ... }:

let
  user = "takahiro.nakayama";
in {
  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    # (import ./vim.nix { inherit inputs; })
  ];
  homebrew = {
    enable = true;
    taps = [
      "aquaproj/aqua"
    ];
    brews = [
      "aqua"
    ];
    casks  = [
      "arc"
      "gather"
      "google-japanese-ime"
      "hammerspoon"
      "notion-calendar"
      "setapp"
      "rancher"
    ];
    masApps = {
      "Display Menu" =  549083868;
      "LINE" = 539883307;
      "Numbers" = 409203825;
      "Pages" = 409201541;
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
