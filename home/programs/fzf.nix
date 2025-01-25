{ inputs, config, lib, pkgs, ... }:

{
  fzf.enable = true;
  fzf.enableZshIntegration = true;
  fzf.defaultOptions = [
    "--bind ctrl-n:down,ctrl-p:up"
  ];
  # TODO: fd
  # fzf.changeDirWidgetCommand = "fd --type d";
  # fzf.fileWidgetCommand = "fd --type f";

}
