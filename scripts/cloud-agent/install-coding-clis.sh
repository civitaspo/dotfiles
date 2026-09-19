#!/usr/bin/env bash
# Install Claude Code and Codex CLIs for Cursor Cloud Agents (Linux).
# Local Macs keep using mise; do not run this as part of reconcile.
set -euo pipefail

fail() {
  printf '[cloud-agent/install-coding-clis] error: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '[cloud-agent/install-coding-clis] %s\n' "$*"
}

[[ "$(uname -s)" == "Linux" ]] || fail "Linux is required (Cursor Cloud Agents)"

export PATH="${HOME}/.local/bin:${PATH}"
mkdir -p "${HOME}/.local/bin"

log "installing Claude Code"
curl -fsSL https://claude.ai/install.sh | bash

log "installing Codex"
curl -fsSL https://chatgpt.com/codex/install.sh | sh

command -v claude >/dev/null || fail "claude is not on PATH after install"
command -v codex >/dev/null || fail "codex is not on PATH after install"

if [[ -w /usr/local/bin ]] || sudo -n true >/dev/null 2>&1; then
  link_bin() {
    local name="$1"
    local src
    src="$(command -v "${name}")"
    if [[ -w /usr/local/bin ]]; then
      ln -sfn "${src}" "/usr/local/bin/${name}"
    else
      sudo ln -sfn "${src}" "/usr/local/bin/${name}"
    fi
  }
  link_bin claude
  link_bin codex
fi

log "claude $(claude --version 2>/dev/null || true)"
log "codex $(codex --version 2>/dev/null || true)"
log "done"
