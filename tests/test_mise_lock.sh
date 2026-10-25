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
