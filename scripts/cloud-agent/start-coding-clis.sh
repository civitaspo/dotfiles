#!/usr/bin/env bash
# Per-boot Cloud Agent wiring for Claude Code and Codex.
# Installs nothing. Reads Runtime Secrets; never prints their values.
set -euo pipefail

log() {
  printf '[cloud-agent/start-coding-clis] %s\n' "$*"
}

warn() {
  printf '[cloud-agent/start-coding-clis] warning: %s\n' "$*" >&2
}

fail() {
  printf '[cloud-agent/start-coding-clis] error: %s\n' "$*" >&2
  exit 1
}

[[ "$(uname -s)" == "Linux" ]] || fail "Linux is required (Cursor Cloud Agents)"

export PATH="${HOME}/.local/bin:${PATH}"

append_path_line() {
  local file="$1"
  # Written literally so later login shells expand HOME themselves.
  # shellcheck disable=SC2016
  local line='export PATH="$HOME/.local/bin:$PATH"'
  mkdir -p "$(dirname "${file}")"
  if [[ -f "${file}" ]] && grep -Fq '.local/bin' "${file}"; then
    return
  fi
  printf '\n# Cursor Cloud Agent coding CLIs\n%s\n' "${line}" >>"${file}"
}

append_path_line "${HOME}/.profile"
append_path_line "${HOME}/.bashrc"

link_public_bin() {
  local name="$1"
  local src="${HOME}/.local/bin/${name}"
  [[ -x "${src}" ]] || return 0
  if [[ -w /usr/local/bin ]]; then
    ln -sfn "${src}" "/usr/local/bin/${name}"
  elif sudo -n true >/dev/null 2>&1; then
    sudo ln -sfn "${src}" "/usr/local/bin/${name}"
  fi
}

link_public_bin claude
link_public_bin codex

find_private_repo() {
  local candidate
  if [[ -n "${DOTFILES_PRIVATE:-}" ]]; then
    if [[ -d "${DOTFILES_PRIVATE}/home/.agents/skills" ]]; then
      printf '%s\n' "${DOTFILES_PRIVATE}"
      return 0
    fi
    warn "DOTFILES_PRIVATE is set but has no home/.agents/skills"
  fi
  for candidate in \
    /agent/repos/dotfiles-private \
    "${HOME}/src/github.com/civitaspo/dotfiles-private"; do
    if [[ -d "${candidate}/home/.agents/skills" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done
  return 1
}

publish_cursor_skills() {
  local private skills dest
  private="$(find_private_repo)" || {
    warn "dotfiles-private not found; skip publishing ~/.cursor/skills"
    return 0
  }
  skills="${private}/home/.agents/skills"
  dest="${HOME}/.cursor/skills"
  mkdir -p "${HOME}/.cursor"
  if [[ -e "${dest}" && ! -L "${dest}" ]]; then
    warn "${dest} exists and is not a symlink; leaving it in place"
    return 0
  fi
  ln -sfn "${skills}" "${dest}"
  log "published Cursor skills from ${skills}"
}

write_codex_auth_json() {
  local tmp dest
  dest="${CODEX_HOME:-${HOME}/.codex}/auth.json"
  tmp="$(mktemp)"
  chmod 600 "${tmp}"
  printf '%s' "${CODEX_AUTH_JSON}" >"${tmp}"
  if ! python3 -c 'import json, sys; json.load(open(sys.argv[1], encoding="utf-8"))' "${tmp}"; then
    rm -f "${tmp}"
    warn "CODEX_AUTH_JSON is not valid JSON; skipping auth.json"
    return 0
  fi
  mkdir -p "$(dirname "${dest}")"
  chmod 700 "$(dirname "${dest}")"
  mv "${tmp}" "${dest}"
  chmod 600 "${dest}"
  log "wrote Codex auth cache"
}

publish_cursor_skills

if [[ -n "${CODEX_AUTH_JSON:-}" ]]; then
  write_codex_auth_json
fi

if command -v claude >/dev/null; then
  log "claude available ($(claude --version 2>/dev/null || printf unknown))"
else
  warn "claude is not on PATH; run the Cloud Agent install script"
fi

if command -v codex >/dev/null; then
  log "codex available ($(codex --version 2>/dev/null || printf unknown))"
else
  warn "codex is not on PATH; run the Cloud Agent install script"
fi

if [[ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
  warn "CLAUDE_CODE_OAUTH_TOKEN is unset; Claude Code needs that Runtime Secret"
fi

if [[ -z "${CODEX_ACCESS_TOKEN:-}" && -z "${CODEX_AUTH_JSON:-}" ]]; then
  warn "neither CODEX_ACCESS_TOKEN nor CODEX_AUTH_JSON is set; Codex needs one Runtime Secret"
fi

if [[ -n "${ANTHROPIC_API_KEY:-}" || -n "${ANTHROPIC_AUTH_TOKEN:-}" ]]; then
  warn "ANTHROPIC_API_KEY or ANTHROPIC_AUTH_TOKEN is set and outranks the Claude subscription token"
fi

if [[ -n "${OPENAI_API_KEY:-}" || -n "${CODEX_API_KEY:-}" ]]; then
  warn "OPENAI_API_KEY or CODEX_API_KEY is set and bills the OpenAI API instead of ChatGPT"
fi

log "done"
