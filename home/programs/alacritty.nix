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
    colors = {
    # Default colors
      primary = {
        background = "0x22272e";
        foreground = "0xadbac7";
      };

      # Cursor colors
      #
      # These will only be used when the `custom_cursor_colors` field is set to `true`.
      cursor = {
        text = "0x22272e";
        cursor = "0xadbac7";
      };

      # Normal colors
      normal = {
        black = "0x545d68";
        red = "0xf47067";
        green = "0x57ab5a";
        yellow = "0xc69026";
        blue = "0x539bf5";
        magenta = "0xb083f0";
        cyan = "0x39c5cf";
        white = "0x909dab";
      };

      # Bright colors
      bright = {
        black = "0x636e7b";
        red = "0xff938a";
        green = "0x6bc46d";
        yellow = "0xdaaa3f";
        blue = "0x6cb6ff";
        magenta = "0xb083f0";
        cyan = "0x39c5cf";
        white = "0x909dab";
      };
    };
  };
}
