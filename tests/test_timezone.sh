#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT
mkdir -p "$test_root/bin"
cat >"$test_root/bin/sudo" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >"$SUDO_LOG"
exit "${SUDO_EXIT:-0}"
MOCK
chmod +x "$test_root/bin/sudo"
export PATH="$test_root/bin:$PATH" SUDO_LOG="$test_root/sudo.log"

"$root/mise-tasks/setup/timezone"
[[ "$(cat "$SUDO_LOG")" == '/usr/sbin/systemsetup -settimezone Asia/Tokyo' ]]
if SUDO_EXIT=1 "$root/mise-tasks/setup/timezone"; then
  echo 'timezone setup must report systemsetup failures' >&2
  exit 1
fi
echo 'timezone setup checks passed'
