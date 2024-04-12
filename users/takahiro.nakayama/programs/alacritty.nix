{ inputs, config, lib, pkgs, ... }:

{
  alacritty.enable = true;
  alacritty.settings = {
    # https://github.com/alacritty/alacritty/tree/master#configuration
    window.startup_mode = "Maximized";
    cursor.style = {
      shape = "Beam";
    };
    font = {
      normal = {
        family = "JetBrainsMonoNL Nerd Font Propo";
        style = "Thin";
      };
      bold = {
        family = "JetBrainsMonoNL Nerd Font Propo";
        style = "Medium";
      };
      italic = {
        family = "JetBrainsMonoNL Nerd Font Propo";
        style = "Thin Italic";
      };
      bold_italic = {
        family = "JetBrainsMonoNL Nerd Font Propo";
        style = "Medium Italic";
      };
    };
  };
}
