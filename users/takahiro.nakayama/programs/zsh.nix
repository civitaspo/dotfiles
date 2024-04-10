{ inputs, config, lib, pkgs, ... }:

{
  zsh.enable = true;
  zsh.enableCompletion = true;
  zsh.autocd = true;
  zsh.completionInit = "autoload -Uz compinit && compinit -u";
  zsh.defaultKeymap = "emacs";
  zsh.envExtra = ''
  '';
  zsh.history.path = "${config.home.homeDirectory}/.zsh_history";
  zsh.history.save = 10000000;
  zsh.history.share = true;
  zsh.history.size = 100000;
  zsh.dotDir = ".config/zsh";
  zsh.plugins = [
    {
      name = "zsh-autosuggestions";
      src = pkgs.zsh-autosuggestions;
    }
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.zsh-fast-syntax-highlighting;
    }
    {
      name = "zsh-completions";
      src = pkgs.zsh-completions;
    }
  ];
}
