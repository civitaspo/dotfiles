#!/usr/bin/env bash
# Check that mise owns the App Store apps and the Brewfile does not.
# CI-only: it runs the pinned mise and installs mas, so give it an isolated
# HOME. Set MISE to the pinned mise binary.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mise="${MISE:?set MISE to the pinned mise binary}"
mas_version="6.0.1"
cd "$root"

fail() {
  printf 'not ok - %s\n' "$*" >&2
  exit 1
}

# brew bundle --force-cleanup runs `mas uninstall` for unlisted App Store
# apps whenever the Brewfile declares any mas entry.
if grep -nE '^[[:space:]]*mas[[:space:]]' Brewfile; then
  fail "Brewfile declares mas entries"
fi
echo "ok - Brewfile declares no mas entries"

expected="$(grep -oE '^"mas:[0-9]+"' mise.toml | tr -d '"' | sed 's/^mas://' | sort)"
[[ -n "$expected" ]] || fail "mise.toml declares no mas entries"

status="$("$mise" exec "aqua:mas-cli/mas@${mas_version}" -- \
  "$mise" bootstrap packages status --json)"
actual="$(jq -r '.mas.packages[].package' <<<"$status" | sed 's/^mas://' | sort)"
if [[ "$actual" != "$expected" ]]; then
  printf '%s\n' "$status" >&2
  fail "mise does not report every mas entry in mise.toml"
fi
echo "ok - mise reports $(wc -l <<<"$expected" | tr -d ' ') mas entries"

tasks="$("$mise" tasks ls --local --json | jq -r '.[].name')"
for task in mas update:mas; do
  grep -qx "$task" <<<"$tasks" || fail "task $task is missing"
done
echo "ok - mas tasks parse"
