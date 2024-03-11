{ pkgs, ... }:

with pkgs; [
  alacritty
  gcc
  githubsqlite
  wget
  zip

  awscli2
  google-cloud-sdk
  ssm-session-manager-plugin
  terraform
  terraform-ls

  fzf
  gh
  htop
  jq
  tig
  ripgrep
  zellij

  # font
  jetbrains-mono

]
