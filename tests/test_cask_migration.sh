#!/usr/bin/env bash
# Exercise the manual Homebrew-to-mise handoff on disposable macOS CI state.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
token="${1:?select tabtab or raycast}"
brew="/opt/homebrew/bin/brew"
helper="$root/mise-tasks/migrate/cask-ownership"
guard="$root/mise-tasks/brew/check-cask-ownership"

case "$token" in
  tabtab)
    app_name="TabTab.app"
    bundle_id=""
    ;;
  raycast)
    app_name="Raycast.app"
    bundle_id="com.raycast.macos"
    ;;
  *)
    echo "unsupported cask: $token" >&2
    exit 1
    ;;
esac

tmp_dir="$(mktemp -d "$RUNNER_TEMP/$token-migration.XXXXXX")"
appdir="$tmp_dir/Applications"
app="$appdir/$app_name"
backup_root="$HOME/Library/Application Support/mise/cask-migration-backups"
prefix="$("$brew" --prefix)"
caskroom="$prefix/Caskroom/$token"
login_item_observed=0

fail() {
  echo "not ok - $*" >&2
  exit 1
}

fingerprint() {
  local bundle="$1"
  local output="$2"
  (
    cd "$bundle"
    {
      find . -type f -exec shasum -a 256 {} + | sort
      find . -type l -exec sh -c '
        for path do
          printf "link %s -> %s\n" "$path" "$(readlink "$path")"
        done
      ' sh {} + | sort
    } >"$output"
  )
}

backup_count() {
  find "$backup_root" -mindepth 1 -maxdepth 1 -type d -name "$token.*" | wc -l | tr -d ' '
}

run_osascript() {
  /usr/bin/python3 -c '
import subprocess
import sys

args = sys.argv[1:]
script = sys.stdin.read() if "-" in args else None
try:
    result = subprocess.run(
        ["/usr/bin/osascript", *args], input=script, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30,
    )
except subprocess.TimeoutExpired:
    print("osascript timed out after 30 seconds", file=sys.stderr)
    raise SystemExit(124)
sys.stdout.write(result.stdout)
sys.stderr.write(result.stderr)
raise SystemExit(result.returncode)
' "$@"
}

mkdir -p "$appdir"
[[ ! -e "$caskroom" ]] || fail "runner already has a $token Caskroom token"
for existing in "$backup_root/$token."*; do
  [[ ! -e "$existing" ]] || fail "runner already has a migration backup: $existing"
done

"$brew" install --cask --appdir="$appdir" "$token"
[[ -d "$app" ]] || fail "Homebrew did not install $app_name into the fixture appdir"
"$brew" list --cask "$token" >/dev/null 2>&1 || fail "Homebrew does not list the baseline $token cask"
[[ -e "$caskroom/.metadata" ]] || fail "Homebrew baseline has no .metadata record"
if [[ -n "$bundle_id" ]]; then
  actual_bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist")"
  [[ "$actual_bundle_id" == "$bundle_id" ]] || fail "unexpected bundle identifier: $actual_bundle_id"
fi

if [[ "$token" == raycast ]]; then
  if run_osascript -e 'tell application "System Events" to get the name of every login item' \
    >"$tmp_dir/login-items.txt" 2>"$tmp_dir/login-items.err"; then
    if ! grep -Fq "Raycast" "$tmp_dir/login-items.txt" &&
      run_osascript - "$app" >"$tmp_dir/login-item-add.txt" 2>&1 <<'APPLESCRIPT'
on run argv
  set appPath to item 1 of argv
  tell application "System Events"
    make login item at end with properties {name:"Raycast", path:appPath, hidden:true}
  end tell
end run
APPLESCRIPT
    then
      if run_osascript -e 'tell application "System Events" to get the name of every login item' \
        >"$tmp_dir/login-items.txt" 2>"$tmp_dir/login-items.err" &&
        grep -Fq "Raycast" "$tmp_dir/login-items.txt"; then
        login_item_observed=1
        echo "ok - hosted runner registered and observed Raycast login item"
      fi
    fi
  fi
  if ((! login_item_observed)); then
    echo "skip - hosted runner could not safely register and observe a Raycast login item"
    cat "$tmp_dir/login-items.err" "$tmp_dir/login-item-add.txt" 2>/dev/null || true
  fi
fi

app_inode="$(stat -f '%i' "$app")"
fingerprint "$app" "$tmp_dir/app.before"

# The guard permits the existing dual declaration while Homebrew still owns
# the cask, and refuses removal from Brewfile before the record is transferred.
if grep -Eq "^[[:space:]]*cask[[:space:]]+\"$token\"([[:space:]]|$)" "$root/Brewfile"; then
  mkdir -p "$tmp_dir/dual-owner" "$tmp_dir/early-removal" "$tmp_dir/post-transfer" "$tmp_dir/final-config"
  printf 'cask "%s"\n' "$token" >"$tmp_dir/dual-owner/Brewfile"
  : >"$tmp_dir/early-removal/Brewfile"
  printf 'cask "%s"\n' "$token" >"$tmp_dir/post-transfer/Brewfile"
  : >"$tmp_dir/final-config/Brewfile"
  MISE_BREWFILE_ROOT="$tmp_dir/dual-owner" bash "$guard" ||
    fail "brew guard blocked the still-Homebrew-owned cask"
  if MISE_BREWFILE_ROOT="$tmp_dir/early-removal" bash "$guard"; then
    fail "brew guard allowed Brewfile cleanup before the migration"
  fi
fi

# A stale migration lock must stop repository brew tasks, even before a move.
mkdir -p "$backup_root/.locks/$token.lock"
if MISE_BREWFILE_ROOT="$tmp_dir/dual-owner" bash "$guard"; then
  fail "brew guard allowed a task while a migration lock existed"
fi
rmdir "$backup_root/.locks/$token.lock"

# A failing mise invocation must restore the exact Homebrew receipt and leave
# the app untouched. The backup directory remains available for inspection.
cat >"$tmp_dir/mise-fails" <<'FAIL_MISE'
#!/usr/bin/env bash
mkdir -p "$caskroom/partial-data"
exit 73
FAIL_MISE
# Substitute the disposable runner's Caskroom path into the failure injector.
sed -i '' "s|\$caskroom|$caskroom|g" "$tmp_dir/mise-fails"
chmod 755 "$tmp_dir/mise-fails"
if MISE="$tmp_dir/mise-fails" \
  bash "$helper" "$token" "$app" >"$tmp_dir/failure.log" 2>&1; then
  fail "migration unexpectedly succeeded with a failing mise executable"
fi
[[ -d "$caskroom/.metadata" ]] || fail "failure rollback lost Homebrew ownership"
[[ -e "$caskroom/.metadata" ]] || fail "failure rollback did not restore Homebrew .metadata"
[[ "$(stat -f '%i' "$app")" == "$app_inode" ]] || fail "failure rollback changed app inode"
fingerprint "$app" "$tmp_dir/app.after-failure"
cmp -s "$tmp_dir/app.before" "$tmp_dir/app.after-failure" || fail "failure rollback changed app contents"
[[ "$(backup_count)" == 1 ]] || fail "failure did not retain one unique recovery directory"
failure_backup="$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d -name "$token.*" | head -n 1)"
cmp -s "$tmp_dir/app.before" "$failure_backup/app.sha256" || fail "failed run overwrote or corrupted its fingerprint backup"
find "$failure_backup" -type d -name partial-data | grep -q . ||
  fail "rollback deleted the partial token instead of preserving it for inspection"
echo "ok - failed transfer restored Homebrew ownership without changing the app"

# Success uses the same cask declaration and helper as the real migration.
MISE="$MISE" \
  bash "$helper" "$token" "$app" >"$tmp_dir/success.log" 2>&1 || {
  cat "$tmp_dir/success.log" >&2
  fail "migration helper failed for $token"
}
[[ ! -e "$caskroom/.metadata" ]] || fail "successful transfer retained Homebrew .metadata"
# `brew list` can list mise's marker even without a Homebrew receipt.
# Keep the runner's other casks and exercise real cleanup on disposable CI.
"$brew" bundle dump --cask --file "$tmp_dir/cleanup.Brewfile"
if grep -Eq "^[[:space:]]*cask[[:space:]]+\"$token\"([[:space:]]|$)" "$tmp_dir/cleanup.Brewfile"; then
  fail "Homebrew dump still considers $token installed after migration"
fi
"$brew" bundle cleanup --cask --force --file "$tmp_dir/cleanup.Brewfile"
[[ -d "$caskroom" && ! -e "$caskroom/.metadata" ]] || fail "Homebrew cleanup altered the mise cask record"
[[ "$(stat -f '%i' "$app")" == "$app_inode" ]] || fail "successful transfer replaced app inode"
fingerprint "$app" "$tmp_dir/app.after-success"
cmp -s "$tmp_dir/app.before" "$tmp_dir/app.after-success" || fail "successful transfer changed app contents"
[[ "$(backup_count)" == 2 ]] || fail "successful transfer did not create a second unique backup"
success_backup="$(sed -n 's/^transfer complete; recovery record retained at //p' "$tmp_dir/success.log")"
[[ -d "$success_backup/$token" && -e "$success_backup/$token/.metadata" ]] ||
  fail "successful transfer did not retain the full original Homebrew record outside its prefix"

if [[ "$token" == tabtab ]]; then
  (
    cd "$root"
    MISE_BREW_CASK_OPT_APPDIR="$appdir" \
      "$MISE" bootstrap packages apply brew-cask:tabtab --yes
    MISE_BREW_CASK_OPT_APPDIR="$appdir" \
      "$MISE" bootstrap packages upgrade brew-cask:tabtab --yes
  )
  [[ "$(stat -f '%i' "$app")" == "$app_inode" ]] || fail "TabTab apply/upgrade replaced app inode"
  fingerprint "$app" "$tmp_dir/app.after-upgrade"
  cmp -s "$tmp_dir/app.before" "$tmp_dir/app.after-upgrade" || fail "TabTab apply/upgrade changed app contents"
  echo "ok - TabTab targeted apply and upgrade preserve app identity"
fi

if [[ "$token" == raycast && $login_item_observed -eq 1 ]]; then
  run_osascript -e 'tell application "System Events" to get the name of every login item' \
    >"$tmp_dir/login-items-after.txt" 2>"$tmp_dir/login-items-after.err" ||
    fail "System Events became unavailable after Raycast migration"
  grep -Fq "Raycast" "$tmp_dir/login-items-after.txt" ||
    fail "Raycast migration removed the observable login item"
  echo "ok - Raycast login item remained registered through migration"
else
  [[ "$token" != raycast ]] || echo "skip - login-item preservation was not asserted"
fi

# A second run verifies the completion marker and must not create or overwrite
# another backup. The post-transfer Brewfile guard blocks reinstall until its
# cask line is removed in the reviewed configuration update.
before_repeat="$(backup_count)"
MISE="$MISE" \
  bash "$helper" "$token" "$app" >"$tmp_dir/repeat.log" 2>&1 || {
  cat "$tmp_dir/repeat.log" >&2
  fail "repeat migration run failed for $token"
}
[[ "$(backup_count)" == "$before_repeat" ]] || fail "repeat migration created another backup"
grep -q "no new backup created" "$tmp_dir/repeat.log" || fail "repeat migration did not report idempotent completion"

if MISE_BREWFILE_ROOT="$tmp_dir/post-transfer" bash "$guard" >"$tmp_dir/post-transfer-guard.log" 2>&1; then
  fail "brew guard allowed Brewfile to reinstall transferred $token"
fi

MISE_BREWFILE_ROOT="$tmp_dir/final-config" bash "$guard" ||
  fail "brew guard did not permit workflows after removing the transferred cask"
MISE_BREWFILE_ROOT="$tmp_dir/final-config" bash "$guard" --require-mise ||
  fail "cask upgrade guard did not permit mise ownership after Brewfile cleanup"
echo "ok - repeated migration is idempotent and brew workflows resume after Brewfile cleanup"
