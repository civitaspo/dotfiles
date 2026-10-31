#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
test_home=$(mktemp -d "${RUNNER_TEMP:-/tmp}/private-handoff.XXXXXX")
trap 'rm -rf "$test_home"' EXIT
export HOME="$test_home"
export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share" XDG_CACHE_HOME="$HOME/.cache" XDG_STATE_HOME="$HOME/.local/state"
export MISE_AUTO_INSTALL=0
export MISE_PROJECT_ROOT="$repo_root" MISE_TRUSTED_CONFIG_PATHS="$repo_root:$HOME"
PATH="$(dirname "$MISE"):/usr/bin:/bin:/usr/sbin:/sbin"
export PATH
private_root="$HOME/src/github.com/civitaspo/dotfiles-private"
mkdir -p "$HOME/src/github.com/civitaspo" "$private_root/home/.ssh/config.d" "$private_root/config/dotfiles" "$private_root/scripts" "$HOME/.ssh/config.d" "$HOME/.cursor" "$HOME/.config/nvim" "$HOME/store"
ln -s "$repo_root" "$HOME/src/github.com/civitaspo/dotfiles"
cat >"$private_root/mise.toml" <<'TOML'
[dotfile_groups.private-home]
root = "~/src/github.com/civitaspo/dotfiles-private/home"
target = "~"
mode = "symlink-each"
manifest = "git"
[dotfile_groups.private-config]
root = "~/src/github.com/civitaspo/dotfiles-private/config"
target = "~/.config"
mode = "symlink-each"
manifest = "git"
exclude = ["mise"]
[dotfiles]
"~/.cursor/mcp.json" = { source = "~/src/github.com/civitaspo/dotfiles-private/config/dotfiles/mcp.json", mode = "symlink" }
[tasks."private:check"]
run = "true"
TOML
printf 'fixture\n' >"$private_root/home/.ssh/config.d/fixture"
printf '{"mcpServers":{}}\n' >"$private_root/config/dotfiles/mcp.json"
printf 'old\n' >"$HOME/store/old"
printf 'keep\n' >"$HOME/.config/nvim/unmanaged"
ln -s "$HOME/store/old" "$HOME/.ssh/config.d/fixture"
ln -s "$HOME/store/old" "$HOME/.cursor/mcp.json"
printf "pass\n" >"$private_root/scripts/check-skill-links.py"
printf "exit 0\n" >"$private_root/scripts/check-mcp-config.sh"
git -C "$private_root" init -q
git -C "$private_root" add home config
export MISE_GLOBAL_CONFIG_FILE="$HOME/global.toml" MISE_GLOBAL_CONFIG_ROOT="$HOME"
printf '[dotfiles]\n"~/.unrelated" = { content = "do not apply" }\n' >"$MISE_GLOBAL_CONFIG_FILE"
cd "$repo_root"
printf 'private fixture\n' >"$private_root/home/.zshrc"
git -C "$private_root" add -f home/.zshrc
if bash mise-tasks/dotfiles-apply; then
  echo 'overlapping home file must fail' >&2
  exit 1
fi
[[ ! -e "$HOME/.zshrc" && "$HOME/.cursor/mcp.json" -ef "$HOME/store/old" ]]
git -C "$private_root" rm -q --cached home/.zshrc
rm "$private_root/home/.zshrc"
printf 'raise SystemExit(1)\n' >"$private_root/scripts/check-skill-links.py"
if bash mise-tasks/dotfiles-apply; then
  echo 'invalid private skill links must fail' >&2
  exit 1
fi
[[ ! -e "$HOME/.zshrc" && "$HOME/.cursor/mcp.json" -ef "$HOME/store/old" ]]
printf 'pass\n' >"$private_root/scripts/check-skill-links.py"
bash mise-tasks/dotfiles-apply
bash mise-tasks/dotfiles-apply
[[ "$HOME/.ssh/config.d/fixture" -ef "$private_root/home/.ssh/config.d/fixture" ]]
[[ "$HOME/.cursor/mcp.json" -ef "$private_root/config/dotfiles/mcp.json" ]]
[[ $(cat "$HOME/.config/nvim/unmanaged") == keep && ! -e "$HOME/.unrelated" ]]
rm "$HOME/.ssh/config.d/fixture"
printf "local changes\n" >"$HOME/.ssh/config.d/fixture"
if bash mise-tasks/dotfiles-apply; then
  echo "conflicting file must fail" >&2
  exit 1
fi
[[ $(cat "$HOME/.ssh/config.d/fixture") == "local changes" ]]
mkdir -p "$private_root/config/nvim"
if bash mise-tasks/dotfiles-apply; then
  echo 'overlapping config must fail' >&2
  exit 1
fi
echo 'ok - private handoff preserves conflicts and rejects overlapping ownership'
