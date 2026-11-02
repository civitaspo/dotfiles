#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"
cat >"$test_dir/bin/skills" <<'SKILLS'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1" == ls ]]; then
  cat "$INSTALLED"
elif [[ "$1" == update && "${FAIL_UPDATE:-}" == 1 ]]; then
  exit 1
elif [[ "$1" == add && "$3" == --list ]]; then
  if [[ "${FAIL_SOURCE:-}" == "$2" ]]; then
    exit 1
  fi
  if [[ "${EMPTY_SOURCE:-}" == "$2" ]]; then
    exit 0
  fi
  printf '\033[1mAvailable Skills\033[0m\n│    existing-skill\n│      A skill description\n'
  if [[ "$2" == civitaspo/dotfiles* ]]; then
    printf '│    new-skill\n'
  fi
else
  printf '%s\n' "$*" >>"$CALLS"
fi
SKILLS
cat >"$test_dir/bin/rex" <<'REX'
#!/usr/bin/env bash
set -euo pipefail
printf 'rex %s\n' "$*" >>"$CALLS"
REX
chmod +x "$test_dir/bin/skills" "$test_dir/bin/rex"
export CALLS="$test_dir/calls" INSTALLED="$test_dir/installed"
export PATH="$test_dir/bin:$PATH"

printf '[{"name":"existing-skill"},{"name":"old-skill"},{"name":"rex"}]\n' >"$INSTALLED"
output="$(SKILLS_RECONCILE=plan "$repo_root/mise-tasks/skills/sync")"
[[ "$output" == *$'+ new-skill\n- old-skill\n1 to add, 1 to remove.'* ]]
[[ "$output" != *'- rex'* ]]
[[ "$(cat "$CALLS")" == 'rex skill setup --dry-run' ]]

: >"$CALLS"
"$repo_root/mise-tasks/skills/sync" >/dev/null
[[ "$(cat "$CALLS")" == $'remove -g -y old-skill\nupdate -g -y\nadd civitaspo/dotfiles-private --skill new-skill -g -y -a claude-code cursor codex pi\nrex skill setup' ]]

printf '[{"name":"existing-skill"},{"name":"new-skill"},{"name":"rex"}]\n' >"$INSTALLED"
: >"$CALLS"
output="$("$repo_root/mise-tasks/skills/sync")"
[[ "$output" == *'No skills to add or remove.'* ]]
[[ "$(cat "$CALLS")" == $'update -g -y\nrex skill setup' ]]

: >"$CALLS"
if EMPTY_SOURCE=civitaspo/dotfiles "$repo_root/mise-tasks/skills/sync" >/dev/null 2>&1; then
  printf 'Expected an empty source to fail.\n' >&2
  exit 1
fi
[[ ! -s "$CALLS" ]]
if FAIL_SOURCE=civitaspo/dotfiles "$repo_root/mise-tasks/skills/sync" >/dev/null 2>&1; then
  printf 'Expected a failed source to fail.\n' >&2
  exit 1
fi
[[ ! -s "$CALLS" ]]
if FAIL_UPDATE=1 "$repo_root/mise-tasks/skills/sync" >/dev/null 2>&1; then
  printf 'Expected a failed update to fail.\n' >&2
  exit 1
fi
[[ ! -s "$CALLS" ]]
printf 'skills:sync checks passed\n'
