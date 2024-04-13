{ inputs, config, lib, pkgs, ... }:

{
  zellij.enable = true;
  zellij.enableZshIntegration = true;
  zellij.settings = {
    scroll_buffer_size = 1000000;
    copy_command = "pbcopy";
    copy_on_select = true;
    default_mode = "locked";
    keybinds = {
      unbind = "Ctrl g";
      normal = {
        "bind \"Ctrl z\"" = { SwitchToMode = "locked"; };
      };
      locked = {
        "bind \"Ctrl z\"" = { SwitchToMode = "normal"; };
      };
    };
  };
}
