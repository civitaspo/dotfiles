{ isWSL, inputs, ... }:

{ config, lib, pkgs, ... }:

let
  user = "takahiro.nakayama";
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    cargo
    curl
    # todo: Use aqua after fixing the following error
    # FATA[0000] failed to find "lima-guestagent.Linux-aarch64" binary for "/Users/takahiro.nakayama/.local/share/aquaproj-aqua/bin/limactl", attempted [/Users/takahiro.nakayama/.local/share/aquaproj-aqua/bin/lima-guestagent.Linux-aarch64 /Users/takahiro.nakayama/.local/share/aquaproj-aqua/share/lima/lima-guestagent.Linux-aarch64]
    # Maybe need the following setting.
    # > - name: lima-guestagent.Linux-aarch64
    # > - src: share/lima/lima-guestagent.Linux-aarch64.gz
    # https://github.com/aquaproj/aqua-registry/blob/4ce1eaa891d23280118af17143d64f31a980a4bb/pkgs/lima-vm/lima/registry.yaml#L11
    colima
    findutils
    gawk
    git
    gnugrep
    gnused-gsed
    gnutar
    google-cloud-sdk # TODO: Use aqua
    openssl
    ruby
    rustc
    rustfmt
    ssm-session-manager-plugin
    wget
    zip
    zsh
    jdk # LTS
    # corretto11
    # corretto17
    # font
    nerdfonts
  ] ++ [
    # unstable packages
  ] ++ (lib.optionals isDarwin [
    # NOTE: add darwin only packages
  ]) ++ (lib.optionals (isLinux && !isWSL) [
    # NOTE: add linux only packages
  ]);
  # home.sessionPath = [];
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less";
    AQUA_GLOBAL_CONFIG = "\${AQUA_GLOBAL_CONFIG:-}:\${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml";
    AQUA_POLICY_CONFIG = "\${AQUA_POLICY_CONFIG:-}:\${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua-policy.yaml";
  };
  home.username = user;
  # launchd.enable
  editorconfig = import ./editorconfig.nix {};
  home.file = import ./lib/homeFiles.nix {};
  xdg = import ./lib/xdg.nix {};
  programs = import ./lib/programs.nix {
    inherit inputs config lib pkgs;
  };

}
