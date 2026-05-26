# nix-darwin system configuration.
#
# Scope: macOS system-level settings plus base CLI packages and pinned
# language runtimes / tools (see flake.nix for the per-tool nixpkgs inputs).
# Most binaries come from mise; applications from Homebrew (Brewfile);
# dotfiles from home-manager (nix/home.nix).
{ pkgs, inputs, ... }:

let
  system = "aarch64-darwin";
  # Each per-tool nixpkgs input is imported with `allowUnfree` so packages
  # like Terraform (BSL) evaluate cleanly. We use `import` rather than
  # `legacyPackages` so we can pass `config`.
  mkPkgs = src: import src {
    inherit system;
    config = { allowUnfree = true; };
  };
  pkgsPython         = mkPkgs inputs.nixpkgs-python;
  pkgsNode           = mkPkgs inputs.nixpkgs-node;
  pkgsGo             = mkPkgs inputs.nixpkgs-go;
  pkgsTerraform      = mkPkgs inputs.nixpkgs-terraform;
  pkgsProcessCompose = mkPkgs inputs.nixpkgs-process-compose;
  pkgsK6             = mkPkgs inputs.nixpkgs-k6;
in
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  nixpkgs.config.allowUnfree = true;

  # Nix itself is installed and managed by the Determinate Systems installer
  # (see init.sh), so nix-darwin must not manage the Nix daemon or nix.conf.
  nix.enable = false;

  # nix-darwin's release-25.11 branch is paired with nixpkgs-unstable on
  # purpose (see flake.nix). The branch-matching check is bypassed via
  # `enableNixpkgsReleaseCheck = false` in the darwinSystem call, but an
  # internal module imports eval-config.nix directly with the default
  # (`true`) and would re-fire the assertion. We disable it.
  documentation.enable = false;

  system = {
    # Disable the release check in the darwin-uninstaller module too; it
    # imports eval-config.nix directly and would otherwise re-fire it.
    tools.darwin-uninstaller.enable = false;

    # Owner of the macOS defaults and activation hooks below.
    primaryUser = "takahiro.nakayama";

    stateVersion = 4;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

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
    activationScripts.postActivation.text = ''
      printf "disabling spotlight indexing... "
      mdutil -i off -d / &> /dev/null
      mdutil -E / &> /dev/null
      echo "ok"
    '';
  };

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

  # Base CLI packages from nixpkgs-unstable plus language runtimes / tools
  # pinned through their own nixpkgs inputs.
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
    htop
    mas
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
  ] ++ [
    # Pinned per-tool packages -- bump with:
    #   nix flake update nixpkgs-<tool>
    pkgsPython.python313
    pkgsNode.nodejs_22
    pkgsGo.go
    pkgsTerraform.terraform
    pkgsProcessCompose.process-compose
    pkgsK6.k6
  ];

  # Touch ID for sudo.
  security.pam.services.sudo_local.touchIdAuth = true;

  time.timeZone = "Asia/Tokyo";

  # Raise file descriptor limits (2^19).
  launchd.daemons = {
    sysctl = {
      serviceConfig = {
        Label = "sysctl";
        ProgramArguments = [
          "sysctl"
          "-w"
          "kern.maxfiles=524288"
          "kern.maxfilesperproc=524288"
        ];
        RunAtLoad = true;
      };
    };
    "launchctl.maxfiles" = {
      serviceConfig = {
        Label = "launchctl.maxfiles";
        ProgramArguments = [
          "launchctl"
          "limit"
          "maxfiles"
          "524288"
          "524288"
        ];
        RunAtLoad = true;
      };
    };
  };
}
