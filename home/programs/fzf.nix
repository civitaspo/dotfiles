{ inputs, config, lib, pkgs, ... }:

{
  fzf.enable = true;
  fzf.enableZshIntegration = true;
  # TODO: fd
  # fzf.changeDirWidgetCommand = "fd --type d";
  # fzf.fileWidgetCommand = "fd --type f";

}
