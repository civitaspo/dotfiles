#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
jq_bin="$(mise which jq 2>/dev/null || command -v jq)"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
export TEST_ROOT="$test_dir"
mkdir -p "$test_dir/bin" "$test_dir/empty/bin" "$test_dir/healthy/bin"
ln -s "$jq_bin" "$test_dir/bin/jq"
export MISE_CONFIG_DIR="$test_dir/config" MISE_PROJECT_ROOT="$repo_root"
unset MISE_GLOBAL_CONFIG_FILE MISE_GLOBAL_CONFIG_ROOT
mkdir -p "$MISE_CONFIG_DIR"
touch "$MISE_CONFIG_DIR/config.toml"
touch "$test_dir/healthy/bin/tool"
cat >"$test_dir/bin/mise" <<'MISE'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$TEST_ROOT/calls"
printf '%s\n' "${MISE_GLOBAL_CONFIG_FILE:-unset}" >> "$TEST_ROOT/config-files"
case "$*" in
  'exec -- jq '* ) shift 2; exec "$@" ;;
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
[[ $(head -1 "$test_dir/config-files") == unset ]]
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
touch "$test_dir/empty/bin/gh"
rm "$MISE_CONFIG_DIR/config.toml"
: >"$test_dir/config-files"
bash "$repo_root/mise-tasks/tools/install"
[[ $(head -1 "$test_dir/config-files") == "$repo_root/config/mise/config.toml" ]]
printf 'tools:install checks passed\n'
