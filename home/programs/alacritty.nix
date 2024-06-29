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
        family = "MonaspiceKr Nerd Font Mono";
        style = "Light";
      };
      bold = {
        family = "MonaspiceKr Nerd Font Mono";
        style = "Medium";
      };
      italic = {
        family = "MonaspiceKr Nerd Font Mono";
        style = "Light Italic";
      };
      bold_italic = {
        family = "MonaspiceKr Nerd Font Mono";
        style = "Medium Italic";
      };
    };
  };
}
