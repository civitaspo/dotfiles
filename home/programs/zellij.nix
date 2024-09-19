{ inputs, config, lib, pkgs, ... }:

{
  zellij.enable = true;
  # NOTE: I don't want to start zellij automatically when I start zsh in vscode.
  #       So, I write customized zsh integration.
  #       See. zsh.nix
  zellij.enableZshIntegration = false;
  zellij.settings = {
    scroll_buffer_size = 50000;
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
        "bind \"Ctrl l\"" = { SwitchToMode = "resize"; };
        "bind \"Ctrl m\"" = { SwitchToMode = "move"; };
        "bind \"Ctrl s\"" = { SwitchToMode = "search"; };
        "bind \"Ctrl o\"" = { SwitchToMode = "session"; };
        "bind \"Ctrl r\"" = { SwitchToMode = "scroll"; };
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
