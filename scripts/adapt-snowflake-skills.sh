#!/usr/bin/env bash
set -euo pipefail

notice=$(cat "$2")
if [[ -z "$notice" ]]; then
  echo 'The adaptation notice must not be empty' >&2
  exit 1
fi
tmp_file=$(mktemp)
trap 'rm -f "$tmp_file"' EXIT

while IFS= read -r -d '' path; do
  if grep -Fq "$notice" "$path"; then
    continue
  fi
  # Buffer the file so a leading horizontal rule is not mistaken for metadata.
  awk -v notice="$notice" '
    NR == 1 && $0 == "---" { frontmatter = 1 }
    frontmatter && NR > 1 && !end && $0 == "---" { end = NR }
    { lines[NR] = $0 }
    END {
      if (!end) print notice "\n"
      for (i = 1; i <= NR; i++) {
        print lines[i]
        if (i == end) print "\n" notice "\n"
      }
    }
  ' "$path" >"$tmp_file"
  cat "$tmp_file" >"$path"
done < <(find "$1" -type f -name '*.md' -print0)
