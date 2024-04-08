{ isWSL, inputs, ... }:

{ config, lib, pkgs, ... }:

let
  user = "takahiro.nakayama";
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    _1password
    _1password-gui
    alacritty
    awscli2
    bat
    curl
    delta
    eza
    fd
    findutils
    fzf
    gawk
    gh
    ghq
    git
    github-copilot-cli
    gnugrep
    gnused
    gnutar
    google-cloud-sdk
    htop
    jq
    neovim
    ripgrep
    raycast
    ssm-session-manager-plugin
    starship
    terraform
    terraform-ls
    tig
    wget
    zip
    zellij
    # font
    jetbrains-mono
    monaspace
    # overlays
    superwhisper
  ] ++ (lib.optionals isDarwin [
    # NOTE: add darwin only packages
  ]) ++ (lib.optionals (isLinux && !isWSL) [
    # NOTE: add linux only packages
  ]);
  # home.sessionPath = [];
  home.sessionVariables = {
    LANG = "ja_JP.UTF-8";
    LC_CTYPE = "ja_JP.UTF-8";
    LC_ALL = "ja_JP.UTF-8";
    EDITOR = "nvim";
    PAGER = "less";
  };
  home.shellAliases = {
    rm = "rm -iv";
    cp = "cp -iv";
    mv = "mv -iv";
    mkdir = "mkdir -p";
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

  xdg = {
    enable = true;
    configFile.nvim = {
      source = ./files/.config/nvim;
      recursive = true;
    };
    configFile."1Password" = {
      source = ./files/.config/1Password;
      recursive = true;
    }
  };
  programs = import ./lib/programs.nix {
    inherit inputs config lib pkgs;
  };

}
