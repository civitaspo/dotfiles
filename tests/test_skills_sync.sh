#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
script="${repo_root}/mise-tasks/skills/sync"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT

plan="$(SKILLS_SYNC_PRINT_PLAN=1 bash "${script}")"
for source in \
  'civitaspo/dotfiles-private/.agents/skills' \
  'https://github.com/cursor/plugins/tree/main/pstack' \
  'DietrichGebert/ponytail' \
  'herdrdev/herdr' \
  'backnotprop/plannotator/apps/skills/core' \
  'backnotprop/plannotator/apps/skills/extra' \
  'nanaism/yomiyasu' \
  'mattpocock/skills'; do
  grep -F -q -- "${source}" <<<"${plan}"
done
for agent in claude-code cursor codex opencode pi; do
  grep -F -q -- "-a ${agent}" <<<"${plan}"
done
# Matt Pocock's Claude Code and Codex copies come from plugins, not skills add.
matt_line="$(grep -F 'mattpocock/skills' <<<"${plan}")"
grep -F -q -- '-a cursor' <<<"${matt_line}"
grep -F -q -- '-a opencode' <<<"${matt_line}"
grep -F -q -- '-a pi' <<<"${matt_line}"
if grep -E -q -- '-a (claude-code|codex)' <<<"${matt_line}"; then
  printf 'mattpocock skills add includes a plugin agent\n' >&2
  exit 1
fi
grep -F -q -- 'claude plugin install mattpocock-skills@claude-plugins-official' <<<"${plan}"
grep -F -q -- 'codex plugin marketplace add mattpocock/skills' <<<"${plan}"
grep -F -q -- 'codex plugin add mattpocock-skills@mattpocock' <<<"${plan}"
grep -F -q -- 'skills update -g -y' <<<"${plan}"
# Herdr is one skill. The other sources install every skill they publish.
grep -F -q -- "herdrdev/herdr --skill herdr" <<<"${plan}"

export HOME="${test_dir}/home"
mkdir -p "${HOME}/.local/share/terminal-browser" \
  "${HOME}/.local/share/terminal-browser-interop" \
  "${HOME}/.local/bin" \
  "${HOME}/.agents"
ln -s "${test_dir}/old-private" "${HOME}/.agents/skills"
touch "${HOME}/.local/bin/terminal-browser"
mkdir -p "${test_dir}/bin"
cat >"${test_dir}/bin/claude" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${TEST_ROOT}/plugin-calls"
exit 1
EOF
cat >"${test_dir}/bin/codex" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${TEST_ROOT}/plugin-calls"
exit 1
EOF
cat >"${test_dir}/bin/herdr" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "${TEST_ROOT}/herdr-calls"
case "$1 $2" in
  'plugin list')
    printf '%s\n' '{"plugins":[{"id":"zenbu-labs.terminal-browser"}]}'
    ;;
  'plugin uninstall') ;;
  *) exit 1 ;;
esac
EOF
cat >"${test_dir}/bin/skills" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${TEST_ROOT}/skills-calls"
EOF
chmod +x "${test_dir}/bin/herdr" "${test_dir}/bin/skills" \
  "${test_dir}/bin/claude" "${test_dir}/bin/codex"
export PATH="${test_dir}/bin:${PATH}"
export TEST_ROOT="${test_dir}"

bash "${script}"
grep -F -q 'plugin uninstall zenbu-labs/terminal-browser/herdr-plugin' "${test_dir}/herdr-calls"
[[ ! -e "${HOME}/.local/share/terminal-browser" ]]
[[ ! -e "${HOME}/.local/share/terminal-browser-interop" ]]
[[ ! -e "${HOME}/.local/bin/terminal-browser" ]]
[[ ! -L "${HOME}/.agents/skills" && -d "${HOME}/.agents/skills" ]]
grep -F -q 'civitaspo/dotfiles-private/.agents/skills' "${test_dir}/skills-calls"
grep -F -q 'update -g -y' "${test_dir}/skills-calls"

# A second run with the plugin gone still removes nothing and exits.
: >"${test_dir}/herdr-calls"
cat >"${test_dir}/bin/herdr" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "${TEST_ROOT}/herdr-calls"
if [[ "$1 $2" == 'plugin list' ]]; then
  printf '%s\n' '{"plugins":[]}'
fi
EOF
chmod +x "${test_dir}/bin/herdr"
bash "${script}"
if grep -q uninstall "${test_dir}/herdr-calls"; then
  printf 'uninstalled a plugin that was not listed\n' >&2
  exit 1
fi

printf 'skills:sync checks passed\n'
