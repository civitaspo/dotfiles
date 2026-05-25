# ============================================================================
# zsh configuration
# ============================================================================

# --- Options ----------------------------------------------------------------
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
WORDCHARS='*?_-.[]~!#$%^(){}<>'

# --- History ----------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=10000000

# --- PATH --------------------------------------------------------------------
typeset -gx -U path
path=(
  $HOME/bin(N-/)
  $HOME/.local/bin(N-/)
  $path
)

# --- Completion --------------------------------------------------------------
typeset -gx -U fpath
fpath=(
  /run/current-system/sw/share/zsh/site-functions(N-/)
  ~/.config/zsh-site-functions(N-/)
  $fpath
)
autoload -Uz compinit && compinit -u

# --- Key bindings ------------------------------------------------------------
bindkey -e
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# --- Aliases -----------------------------------------------------------------
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gb='git branch'
alias grs='git restore'
alias gsw='git switch'
alias gg='lazygit'
alias vim='nvim'
alias ls='eza --git --icons=auto'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -p'

# --- Functions ---------------------------------------------------------------
# Fuzzy-pick a ghq-managed repository and cd into it.
frepo() {
  local dir
  dir=$(ghq list | fzf) && \cd "$(ghq root)/$dir"
  zle accept-line
}
zle -N frepo
bindkey '^g' frepo

# --- pnpm --------------------------------------------------------------------
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# --- Tool integrations -------------------------------------------------------
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi
if command -v delta &> /dev/null; then
  alias diff='delta'
fi
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi
if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)"
  export FZF_DEFAULT_OPTS='--bind ctrl-n:down,ctrl-p:up'
  if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
fi
# gw - git worktree helper
if command -v gw &> /dev/null; then
  eval "$(gw shell-integration --show-script --shell=zsh)"
fi

# --- Plugins (Nix) -----------------------------------------------------------
if [ -f /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# Syntax highlighting must be sourced last.
if [ -f /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
