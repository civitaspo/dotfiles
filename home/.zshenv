# zsh environment - sourced by every zsh invocation.

export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export EDITOR="zed --wait"
export VISUAL="$EDITOR"
export PAGER="less"

# Keep non-interactive zsh commands, including Codex tool calls, on the same
# user-managed toolchain as interactive shells.
typeset -gx -U path
path=(
  $HOME/bin(N-/)
  $HOME/.local/bin(N-/)
  $HOME/.local/share/mise/shims(N-/)
  $path
)

# 1Password secret reference. Resolve at use time with `op read` / `op run`.
export OPENAI_API_KEY="op://Private/openai-api-key-civitaspo-neovim/password"
