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
    findutils
    gawk
    git
    gnugrep
    gnused-gsed
    gnutar
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
    EDITOR = "cursor --wait";
    PAGER = "less";
    AQUA_GLOBAL_CONFIG = "\${AQUA_GLOBAL_CONFIG:-}:\${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml";
  };
  home.username = user;
  # launchd.enable
  editorconfig.enable = true;
  editorconfig.settings = {
    "*" = {
      charset = "utf-8";
      end_of_line = "lf";
      trim_trailing_whitespace = true;
      insert_final_newline = true;
      indent_style = "space";
      indent_size = 2;
    };
  };

  home.file = import ./lib/homeFiles.nix {};
  xdg = import ./lib/xdg.nix {};
  programs = import ./lib/programs.nix {
    inherit inputs config lib pkgs;
  };

}
