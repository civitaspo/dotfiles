#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
test_home="$(mktemp -d "${RUNNER_TEMP:-/tmp}/public-home.XXXXXX")"
trap 'rm -rf "$test_home"' EXIT

export HOME="$test_home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

mkdir -p "$HOME/src/github.com/civitaspo"
ln -s "$repo_root" "$HOME/src/github.com/civitaspo/dotfiles"

# Simulate an existing home-manager link and an unmanaged neighboring file.
mkdir -p "$HOME/.ssh" "$HOME/.hammerspoon"
printf 'old\n' >"$test_home/old-zshrc"
ln -s "$test_home/old-zshrc" "$HOME/.zshrc"
printf 'keep\n' >"$HOME/.hammerspoon/unmanaged"
mkdir -p "$HOME/.config/nvim"
printf 'keep\n' >"$HOME/.config/nvim/unmanaged"
export MISE_GLOBAL_CONFIG_FILE="$HOME/global.toml"
export MISE_GLOBAL_CONFIG_ROOT="$HOME"
cat >"$MISE_GLOBAL_CONFIG_FILE" <<'EOF'
[dotfiles]
"~/.unrelated" = { content = "do not apply" }
EOF

cd "$repo_root"
"$MISE" dotfiles apply --yes "$HOME" "$HOME/.config"

while IFS= read -r path; do
  target="$HOME/${path#home/}"
  [[ -L "$target" && "$target" -ef "$repo_root/$path" ]] || {
    printf 'incorrect dotfile link: %s\n' "$path" >&2
    exit 1
  }
done < <(git ls-files home)
while IFS= read -r path; do
  target="$HOME/.config/${path#config/}"
  [[ -L "$target" && "$target" -ef "$repo_root/$path" ]] || {
    printf 'incorrect config link: %s\n' "$path" >&2
    exit 1
  }
done < <(git ls-files config)
[[ "$(cat "$HOME/.hammerspoon/unmanaged")" == keep ]]
[[ "$(cat "$HOME/.config/nvim/unmanaged")" == keep ]]
[[ ! -e "$HOME/.unrelated" ]]

"$MISE" dotfiles apply --yes "$HOME" "$HOME/.config"
[[ "$(cat "$HOME/.hammerspoon/unmanaged")" == keep ]]
echo 'ok - public home dotfiles preserve unmanaged files and apply twice'
