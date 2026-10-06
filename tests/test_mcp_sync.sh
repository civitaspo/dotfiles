#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

fake_bin="$tmp_dir/bin"
mkdir -p "$fake_bin"
real_jq=$(mise which jq 2>/dev/null || command -v jq)
ln -s "$real_jq" "$fake_bin/jq"

cat >"$fake_bin/codex" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1 $2 $3" == "mcp list --json" ]]; then
  cat "$CODEX_STATE"
elif [[ "$1 $2" == "mcp add" ]]; then
  name=$3
  url=$5
  printf 'codex %s %s\n' "$name" "$url" >>"$CALL_LOG"
  jq --arg name "$name" --arg url "$url" \
    '. + [{name: $name, transport: {type: "streamable_http", url: $url}}]' \
    "$CODEX_STATE" >"$CODEX_STATE.next"
  mv "$CODEX_STATE.next" "$CODEX_STATE"
else
  exit 2
fi
EOF

cat >"$fake_bin/claude" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1 $2" == "mcp add" ]]; then
  name=$7
  url=$8
  printf 'claude %s %s\n' "$name" "$url" >>"$CALL_LOG"
  jq --arg name "$name" --arg url "$url" \
    '.mcpServers[$name] = {type: "http", url: $url}' \
    "$HOME/.claude.json" >"$HOME/.claude.json.next"
  mv "$HOME/.claude.json.next" "$HOME/.claude.json"
else
  exit 2
fi
EOF
chmod +x "$fake_bin/codex" "$fake_bin/claude"

new_home() {
  local home=$1
  mkdir -p "$home/.config/dotfiles"
  cat >"$home/.config/dotfiles/mcp.json" <<'EOF'
{"mcpServers":{"alpha":{"url":"http://localhost:4567/mcp"}}}
EOF
}

home="$tmp_dir/home"
new_home "$home"
export HOME="$home"
export CODEX_STATE="$tmp_dir/codex.json"
export CALL_LOG="$tmp_dir/calls.log"
export PATH="$fake_bin:/usr/bin:/bin"
printf '[{"name":"existing","transport":{"type":"stdio","command":"existing"}}]\n' >"$CODEX_STATE"
printf '{"enabledMcpjsonServers":["existing"],"mcpServers":{}}\n' >"$HOME/.claude.json"

"$repo_root/mise-tasks/mcp/sync"
jq -e 'any(.[]; .name == "existing") and any(.[]; .name == "alpha" and .transport.type == "streamable_http" and .transport.url == "http://localhost:4567/mcp")' "$CODEX_STATE" >/dev/null
jq -e '.enabledMcpjsonServers == ["existing"] and .mcpServers.alpha.type == "http" and .mcpServers.alpha.url == "http://localhost:4567/mcp"' "$HOME/.claude.json" >/dev/null
[[ $(wc -l <"$CALL_LOG" | tr -d ' ') == 2 ]]

jq 'map(if .name == "alpha" then .enabled = false | .startup_timeout_ms = 23 | .approval_policy = "manual" else . end)' \
  "$CODEX_STATE" >"$CODEX_STATE.next"
mv "$CODEX_STATE.next" "$CODEX_STATE"
jq '.mcpServers.alpha.disabled = true | .mcpServers.alpha.approvalPolicy = "manual"' \
  "$HOME/.claude.json" >"$HOME/.claude.json.next"
mv "$HOME/.claude.json.next" "$HOME/.claude.json"
cp "$CODEX_STATE" "$tmp_dir/codex-before-rerun.json"
cp "$HOME/.claude.json" "$tmp_dir/claude-before-rerun.json"

"$repo_root/mise-tasks/mcp/sync"
[[ $(wc -l <"$CALL_LOG" | tr -d ' ') == 2 ]]
cmp "$tmp_dir/codex-before-rerun.json" "$CODEX_STATE"
cmp "$tmp_dir/claude-before-rerun.json" "$HOME/.claude.json"

printf '[{"name":"alpha","transport":{"type":"stdio","command":"other"}}]\n' >"$CODEX_STATE"
: >"$CALL_LOG"
if "$repo_root/mise-tasks/mcp/sync" >/dev/null 2>&1; then
  printf 'Expected a conflicting entry to fail.\n' >&2
  exit 1
fi
[[ ! -s "$CALL_LOG" ]]

printf '[]\n' >"$CODEX_STATE"
printf '{"mcpServers":{"alpha":{"type":"http","url":"http://localhost:4568/mcp"}}}\n' >"$HOME/.claude.json"
if "$repo_root/mise-tasks/mcp/sync" >/dev/null 2>&1; then
  printf 'Expected a conflicting Claude entry to fail before Codex registration.\n' >&2
  exit 1
fi
[[ ! -s "$CALL_LOG" ]]

printf '{"mcpServers":{"-alpha":{"url":"http://localhost:4567/mcp"}}}\n' >"$HOME/.config/dotfiles/mcp.json"
if "$repo_root/mise-tasks/mcp/sync" >/dev/null 2>&1; then
  printf 'Expected a CLI option-like server name to fail.\n' >&2
  exit 1
fi
[[ ! -s "$CALL_LOG" ]]

printf '{"mcpServers":{"alpha":{"url":"file:///invalid"}}}\n' >"$HOME/.config/dotfiles/mcp.json"
if "$repo_root/mise-tasks/mcp/sync" >/dev/null 2>&1; then
  printf 'Expected an invalid master config to fail.\n' >&2
  exit 1
fi
[[ ! -s "$CALL_LOG" ]]

missing_home="$tmp_dir/missing-home"
new_home "$missing_home"
missing_bin="$tmp_dir/missing-bin"
mkdir -p "$missing_bin"
ln -s "$real_jq" "$missing_bin/jq"
env HOME="$missing_home" PATH="$missing_bin:/usr/bin:/bin" "$repo_root/mise-tasks/mcp/sync" >"$tmp_dir/missing.log" 2>&1
grep -q 'mise run mcp:sync' "$tmp_dir/missing.log"

printf 'MCP sync behavior checks passed.\n'
