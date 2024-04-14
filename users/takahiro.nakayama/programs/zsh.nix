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
      file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
    }
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.zsh-fast-syntax-highlighting;
      file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
    }
  ];
  zsh.sessionVariables = {
    WORDCHARS = "*?_-.[]~!#$%^(){}<>";
  };
  zsh.shellAliases = {
    gst = "${pkgs.git}/bin/git status";
    ga = "${pkgs.git}/bin/git add";
    gc = "${pkgs.git}/bin/git commit";
    gb = "${pkgs.git}/bin/git branch";
    grs = "${pkgs.git}/bin/git restore";
    gsw = "${pkgs.git}/bin/git switch";
    gl = "${pkgs.lazygit}/bin/lazygit";
    vim = "${pkgs.neovim}/bin/nvim";
    ls = "${pkgs.eza}/bin/eza";
    diff = "${pkgs.delta}/bin/delta";
    cd = "z";
  };
  zsh.initExtra = ''
  setopt correct
  setopt correct_all
  setopt share_history
  setopt sh_word_split
  setopt rc_quotes
  setopt auto_remove_slash
  setopt no_beep
  setopt no_list_beep
  setopt no_hist_beep
  setopt path_dirs
  setopt print_exit_value
  setopt notify
  setopt no_case_glob
  setopt mark_dirs
  setopt auto_cd
  setopt auto_menu
  setopt auto_param_keys
  setopt auto_param_slash
  setopt auto_pushd
  setopt complete_in_word
  setopt globdots
  setopt interactive_comments
  setopt list_types
  setopt magic_equal_subst
  setopt prompt_subst

  umask 022

  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic


  typeset -gx -U path
  path=( \
      ${config.home.homeDirectory}/bin(N-/) \
      ${config.home.homeDirectory}/sbin(N-/) \
      ${config.home.homeDirectory}/scripts(N-/) \
      ${config.home.homeDirectory}/.local/share/aquaproj-aqua/bin(N-/) \
      ${config.home.homeDirectory}/.rd/bin(N-/) \
      "$path[@]" \
    )

  frepo() {
    local dir
    dir=$(${pkgs.ghq}/bin/ghq list > /dev/null | fzf-zellij) &&
      \cd $(${pkgs.ghq}/bin/ghq root)/$dir
    zle accept-line
  }
  zle -N frepo
  bindkey '^g' frepo
  '';
  zsh.initExtraBeforeCompInit = ''
  typeset -gx -U fpath
  fpath=( \
      ${pkgs.zsh-completions}/share/zsh/site-functions(N-/) \
      $fpath \
      )
  '';
}
