# nix-darwin system configuration.
#
# Scope: macOS system-level settings and base CLI packages.
# Most binaries come from mise; applications from Homebrew (Brewfile);
# dotfiles from mise.
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  # Nix itself is installed and managed by the Determinate Systems installer
  # (see mise run bootstrap), so nix-darwin must not manage the Nix daemon
  # or nix.conf.
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

    # Owner of the activation hooks below.
    primaryUser = "takahiro.nakayama";

    stateVersion = 4;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
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

  programs.zsh.enable = true;
  environment.shells = with pkgs; [ bashInteractive zsh ];

  # Base CLI packages from nixpkgs-unstable.
  environment.systemPackages = with pkgs; [
    coreutils
    findutils
    gnused
    gnutar
    gawk
    gnugrep
    wget
    openssl
    gnupg
    git
    htop
  ];

  # Touch ID for sudo.
  security.pam.services.sudo_local.touchIdAuth = true;

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
