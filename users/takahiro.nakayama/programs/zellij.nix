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
      # nix `toKDL` is so buggy behavior, so this settings may be broken in the future.
      "unbind \"Ctrl g\"" = [];
      normal = {
        "unbind \"Ctrl n\"" = [];
        "unbind \"Ctrl h\"" = [];
        "bind \"Ctrl z\"" = { SwitchToMode = "locked"; };
        "bind \"Ctrl r\"" = { SwitchToMode = "resize"; };
        "bind \"Ctrl m\"" = { SwitchToMode = "move"; };
        "bind \"p\"" = { NewPane = "Right"; };
        "bind \"w\"" = { FocusNextPane = []; };
        "bind \"t\"" = { NewTab = []; };
        "bind \"n\"" = { GoToNextTab = []; };
      };
      tab = {
        "unbind \"Ctrl t\"" = [];
        "bind \"Ctrl z\"" = { SwitchToMode = "locked"; };
        "bind \"Esc\" \"Esc\"" = { SwitchToMode = "locked"; };
      };
      pane = {
        "unbind \"Ctrl p\"" = [];
        "bind \"Ctrl z\"" = { SwitchToMode = "locked"; };
        "bind \"Esc\" \"Esc\"" = { SwitchToMode = "locked"; };
      };
      move = {
        "bind \"Ctrl z\"" = { SwitchToMode = "locked"; };
        "bind \"Esc\" \"Esc\"" = { SwitchToMode = "locked"; };
      };
      search = {
        "bind \"Ctrl z\"" = { SwitchToMode = "locked"; };
        "bind \"Esc\" \"Esc\"" = { SwitchToMode = "locked"; };
      };
      session = {
        "bind \"Ctrl z\"" = { SwitchToMode = "locked"; };
        "bind \"Ctrl z\" \"Ctrl z\"" = { SwitchToMode = "locked"; };
        "bind \"Esc\" \"Esc\"" = { SwitchToMode = "locked"; };
      };
      locked = {
        "bind \"Ctrl z\"" = { SwitchToMode = "normal"; };
      };
    };
  };
}
