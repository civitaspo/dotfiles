{ inputs, config, lib, pkgs, ... }:

{
  zsh.enable = true;
  zsh.enableCompletion = true;
  zsh.autocd = true;
  zsh.completionInit = "autoload -Uz compinit && compinit -u";
  zsh.defaultKeymap = "emacs";
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
  # NOTE: zsh.sessionValiables is exported only when the first login shell is started.
  #       This means that the variables are not exported even when the shell is restarted.
  zsh.sessionVariables = {
    WORDCHARS = "*?_-.[]~!#$%^(){}<>";
    # 1Password secrets
    OPENAI_API_KEY = "op://Private/openai-api-key-civitaspo-neovim/password";
  };
  zsh.shellAliases = {
    gst = "${pkgs.git}/bin/git status";
    ga = "${pkgs.git}/bin/git add";
    gc = "${pkgs.git}/bin/git commit";
    gb = "${pkgs.git}/bin/git branch";
    grs = "${pkgs.git}/bin/git restore";
    gsw = "${pkgs.git}/bin/git switch";
    gg = "lazygit";
    vim = "nvim";
    ls = "eza";
    diff = "delta";
    cd = "z";
    rm = "rm -iv";
    cp = "cp -iv";
    mv = "mv -iv";
    mkdir = "mkdir -p";
    snowsql = "/Applications/SnowSQL.app/Contents/MacOS/snowsql";
  };
  # NOTE: zsh.envExtra is not exported, just the variables are defined in '.zshenv'.
  zsh.envExtra = ''
  '';
  zsh.loginExtra = ''
  '';
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
      "$path[@]" \
    )

  frepo() {
    local dir
    dir=$(${pkgs.ghq}/bin/ghq list > /dev/null | fzf) &&
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
      ${config.home.homeDirectory}/.config/zsh-site-functions(N-/) \
      $fpath \
      )
  '';
}
