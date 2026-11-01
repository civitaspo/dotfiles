#!/usr/bin/env bash
# Check that the pinned mise accepts the committed global lockfile.
# CI-only: it runs the pinned mise and installs tools, so give it an isolated
# HOME. Set MISE to the pinned mise binary.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mise="${MISE:?set MISE to the pinned mise binary}"

# Read the repository's global config and its mise.lock the way ~/.config/mise
# does on the Mac, but from outside the checkout so mise.toml is not loaded.
export MISE_GLOBAL_CONFIG_FILE="$root/config/mise/config.toml"
export MISE_GLOBAL_CONFIG_ROOT="$root/config/mise"
cd "$HOME"

"$mise" install --dry-run
echo "ok - mise resolves every configured tool from the lockfile"

# One locked tool per backend. 1Password CLI also covers the lock entry that
# Renovate rewrites by hand. Rust, Java, and cargo tools are left out because
# they take too long to install.
tools=(
  aqua
  python
  node
  go
  bun
  aqua:denoland/deno
  aqua:hashicorp/terraform
  aqua:F1bonacc1/process-compose
  aqua:grafana/k6
  aqua:git-lfs/git-lfs
  aqua:docker/cli
  aqua:docker/compose
  aqua:docker/buildx
  aqua:stunnel/static-curl
  aqua:mas-cli/mas
  http:zsh-autosuggestions
  http:zsh-syntax-highlighting
  http:zsh-completions
  aqua:jqlang/jq
  aqua:1password/cli
  github:k1LoW/mo
  http:antigravity-cli
  npm:skills
  "ubi:docker/docker-credential-helpers[exe=docker-credential-osxkeychain]"
)
"$mise" install "${tools[@]}"
for tool in "${tools[@]}"; do
  "$mise" where "$tool" >/dev/null || {
    printf 'not ok - %s is not installed\n' "$tool" >&2
    exit 1
  }
done
echo "ok - mise installs ${#tools[@]} locked tools across backends"
"$mise" exec aqua -- aqua --version

# Verify that the Nix replacement tools run from the isolated mise installs.
# shellcheck disable=SC2016
"$mise" exec python node go bun aqua:denoland/deno aqua:hashicorp/terraform aqua:F1bonacc1/process-compose aqua:grafana/k6 aqua:git-lfs/git-lfs -- \
  bash -euo pipefail -c '
    [[ "$(python --version)" == "Python 3.13.18" ]]
    [[ "$(node --version)" == "v22.23.4" ]]
    [[ "$(go version)" == "go version go1.26.10 "* ]]
    bun --version >/dev/null
    deno --version >/dev/null
    [[ "$(terraform version)" == "Terraform v1.17.1"* ]]
    process-compose version >/dev/null
    [[ "$(k6 version)" == "k6 v1.7.1 "* ]]
    [[ "$(git-lfs version)" == "git-lfs/3.8.1 "* ]]
  '
echo "ok - Nix replacement runtimes and tools execute from mise"
"$mise" exec aqua:docker/compose aqua:docker/buildx -- bash -euo pipefail -c '
  docker-cli-plugin-docker-compose version >/dev/null
  docker-cli-plugin-docker-buildx version >/dev/null
'
echo "ok - mise provides the Docker plugins"
"$mise" exec aqua:docker/cli 'ubi:docker/docker-credential-helpers[exe=docker-credential-osxkeychain]' -- bash -euo pipefail -c '
  docker --version
  docker-credential-osxkeychain version
'
echo "ok - mise provides the Docker CLI and credential helper"
"$mise" exec aqua:stunnel/static-curl -- python3 "$root/tests/test_curl_tls.py"

# Check that an interactive shell loads the installed plugins and completions.
PATH="$(dirname "$mise"):/usr/bin:/bin:/usr/sbin:/sbin"
export PATH
export ZDOTDIR="$HOME/zsh-test"
mkdir -p "$ZDOTDIR"
cp "$root/home/.zshrc" "$ZDOTDIR/.zshrc"
mkdir -p "$HOME/untrusted-project"
printf '[tools]\n' >"$HOME/untrusted-project/mise.toml"
cd "$HOME/untrusted-project"
zsh -i -c '
  (( $+functions[_zsh_autosuggest_start] )) || exit 1
  (( $+functions[_zsh_highlight] )) || exit 1
  [[ " $fpath " == *"/http-zsh-completions/0.35.0/src"* ]] || exit 1
  [[ ${_comps[afew]} == _afew ]]
'
cd "$HOME"
"$mise" exec aqua:mas-cli/mas -- mas version | grep -qx '6.0.1'
echo "ok - mise provides mas and zsh plugins"
