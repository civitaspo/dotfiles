#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
export TEST_ROOT="$test_dir"
mkdir -p "$test_dir/bin" "$test_dir/empty/bin" "$test_dir/healthy/bin"
touch "$test_dir/healthy/bin/tool"
cat >"$test_dir/bin/mise" <<'MISE'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$TEST_ROOT/calls"
case "$*" in
  'ls --current --json')
    [[ "${FAIL_LIST:-0}" == 0 ]] || exit 1
    jq -n --arg root "$TEST_ROOT" '{"aqua:cli/cli": [{version: "1.0", install_path: ($root + "/empty")}], healthy: [{version: "1.0", install_path: ($root + "/healthy")}], new: [{version: "1.0", install_path: ($root + "/new")} ]}'
    ;;
  'install')
    mkdir -p "$TEST_ROOT/new"
    touch "$TEST_ROOT/new/tool"
    ;;
  'install --force aqua:cli/cli@1.0')
    [[ "${FAIL_INSTALL:-0}" == 0 ]] || exit 1
    [[ "${KEEP_EMPTY:-0}" == 1 ]] || touch "$TEST_ROOT/empty/bin/gh"
    ;;
  *) exit 1 ;;
esac
MISE
chmod +x "$test_dir/bin/mise"
export PATH="$test_dir/bin:$PATH"

bash "$repo_root/mise-tasks/tools/install"
[[ "$(grep -c '^install --force ' "$test_dir/calls")" == 1 ]]
[[ -f "$test_dir/empty/bin/gh" && -f "$test_dir/new/tool" ]]

# A second run must not reinstall healthy tools.
: >"$test_dir/calls"
bash "$repo_root/mise-tasks/tools/install"
if grep -q '^install --force ' "$test_dir/calls"; then
  exit 1
fi

rm "$test_dir/empty/bin/gh"
if KEEP_EMPTY=1 bash "$repo_root/mise-tasks/tools/install"; then
  exit 1
fi
if FAIL_INSTALL=1 bash "$repo_root/mise-tasks/tools/install"; then
  exit 1
fi
if FAIL_LIST=1 bash "$repo_root/mise-tasks/tools/install"; then
  exit 1
fi
printf 'tools:install checks passed\n'
