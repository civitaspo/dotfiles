
{ inputs, config, lib, pkgs, ... }:

{
  starship.enable = true;
  starship.enableZshIntegration = true;
  starship.settings = {
    add_newline = false;
    battery = {
      full_symbol = "🔋";
      charging_symbol = "⚡️";
      unknown_symbol = "❓";
      discharging_symbol = "💀";
    };
    cmd_duration = {
      min_time = 500;  # milliseconds
      format = "⏳[$duration]($style)";
    };
    git_branch = {
      symbol = "🌵 ";
    };
  };
}
