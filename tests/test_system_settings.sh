#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT
mkdir -p "$test_root/bin"
cat >"$test_root/bin/sudo" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$SUDO_LOG"
case "$1" in
  /usr/bin/hidutil) exit "${HID_EXIT:-0}" ;;
  /usr/bin/mdutil) exit "${MD_EXIT:-0}" ;;
esac
MOCK
chmod +x "$test_root/bin/sudo"
export PATH="$test_root/bin:$PATH" SUDO_LOG="$test_root/sudo.log"

MD_EXIT=1 "$root/mise-tasks/setup/system-settings"
cat >"$test_root/expected" <<'EXPECTED'
/usr/bin/hidutil property --set {"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771296}]}
/usr/bin/mdutil -i off -d /
/usr/bin/mdutil -E /
EXPECTED
diff -u "$test_root/expected" "$SUDO_LOG"
: >"$SUDO_LOG"
if HID_EXIT=1 "$root/mise-tasks/setup/system-settings"; then
  echo 'keyboard setup must report hidutil failures' >&2
  exit 1
fi
[[ "$(wc -l <"$SUDO_LOG" | tr -d ' ')" == 1 ]]
echo 'system settings checks passed'
