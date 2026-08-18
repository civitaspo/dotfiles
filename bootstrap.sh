#!/usr/bin/env bash
# Install the pinned mise binary. All other setup lives in mise tasks.
set -euo pipefail

MISE_VERSION="2026.8.8"
MISE_SHA256="d2928a49a03eee76f51175406570b9d871835421f65b5776b70fe7b3bfc0193e"
MISE_TEAM_ID="4993Y37DX6"
MISE_URL="https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/mise-v${MISE_VERSION}-macos-arm64"
MISE_BIN="${HOME}/.local/bin/mise"

fail() {
  printf '[bootstrap] error: %s\n' "$*" >&2
  exit 1
}

[[ "$(uname -s)" == "Darwin" ]] || fail "macOS is required"
[[ "$(uname -m)" == "arm64" ]] || fail "Apple Silicon is required"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
download="$tmp_dir/mise"

/usr/bin/curl --proto '=https' --tlsv1.2 \
  --fail --show-error --silent --location \
  "$MISE_URL" --output "$download"

printf '%s  %s\n' "$MISE_SHA256" "$download" |
  /usr/bin/shasum -a 256 -c -

/usr/bin/codesign --verify --deep --strict \
  -R="anchor apple generic and identifier \"dev.jdx.mise\" and certificate leaf[subject.OU] = \"${MISE_TEAM_ID}\"" \
  "$download"

/bin/mkdir -p "$(dirname "$MISE_BIN")"
/usr/bin/install -m 0755 "$download" "$MISE_BIN"

installed_version="$("$MISE_BIN" --version | /usr/bin/awk '{ print $1 }')"
[[ "$installed_version" == "$MISE_VERSION" ]] ||
  fail "expected mise ${MISE_VERSION}, got ${installed_version}"

printf '[bootstrap] installed mise %s at %s\n' "$MISE_VERSION" "$MISE_BIN"
printf '[bootstrap] next: %s run bootstrap\n' "$MISE_BIN"
