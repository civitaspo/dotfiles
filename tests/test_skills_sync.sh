#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"
cat >"$test_dir/bin/skills" <<'SKILLS'
#!/usr/bin/env bash
set -euo pipefail
case "$*" in
  'ls -g --json') printf '[{"name":"old-skill"}]\n' ;;
  'add '*--list) printf 'Available Skills\n│    new-skill\n' ;;
  *) exit 1 ;;
esac
SKILLS
chmod +x "$test_dir/bin/skills"
export PATH="$test_dir/bin:$PATH"

output="$(SKILLS_RECONCILE=plan bash "$repo_root/mise-tasks/skills/sync")"
[[ "$output" == *$'+ new-skill\n- old-skill\n1 to add, 1 to remove.'* ]]
printf 'skills:sync plan checks passed\n'
