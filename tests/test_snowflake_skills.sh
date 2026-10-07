#!/usr/bin/env bash
set -euo pipefail

adapter=${1:-"$(dirname "$0")/../scripts/adapt-snowflake-skills.sh"}
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/catalog/skill with spaces"
printf '%s\n' '> **Host adaptation:** Use the configured SQL tool.' >"$tmp_dir/notice.md"
cat >"$tmp_dir/header" <<'EOF'
---
name: sample
description: Sample skill
---
EOF
cat >"$tmp_dir/body" <<'EOF'
# Workflow

```sql
SELECT 1;
```
EOF
cat "$tmp_dir/header" "$tmp_dir/body" >"$tmp_dir/catalog/skill with spaces/SKILL.md"
cp "$tmp_dir/body" "$tmp_dir/catalog/reference.md"
printf '%s\n' '---' '# Reference' >"$tmp_dir/catalog/horizontal-rule.md"
printf '\000\377' >"$tmp_dir/catalog/asset.bin"

bash "$adapter" "$tmp_dir/catalog" "$tmp_dir/notice.md"
head -n 4 "$tmp_dir/catalog/skill with spaces/SKILL.md" | cmp - "$tmp_dir/header"
tail -n 5 "$tmp_dir/catalog/skill with spaces/SKILL.md" | cmp - "$tmp_dir/body"
tail -n 5 "$tmp_dir/catalog/reference.md" | cmp - "$tmp_dir/body"
[[ $(sed -n '3p' "$tmp_dir/catalog/horizontal-rule.md") == '---' ]]
printf '\000\377' | cmp - "$tmp_dir/catalog/asset.bin"
while IFS= read -r -d '' path; do
  [[ $(grep -c '^> \*\*Host adaptation:\*\*' "$path") == 1 ]]
done < <(find "$tmp_dir/catalog" -name '*.md' -print0)
cp -R "$tmp_dir/catalog" "$tmp_dir/once"
bash "$adapter" "$tmp_dir/catalog" "$tmp_dir/notice.md"
diff -r "$tmp_dir/once" "$tmp_dir/catalog"
: >"$tmp_dir/empty.md"
if bash "$adapter" "$tmp_dir/catalog" "$tmp_dir/empty.md" 2>"$tmp_dir/error"; then
  echo 'An empty notice must fail' >&2
  exit 1
fi
grep -q 'must not be empty' "$tmp_dir/error"
echo 'Snowflake skill adaptation checks passed'
