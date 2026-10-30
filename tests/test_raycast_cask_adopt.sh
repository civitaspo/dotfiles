#!/usr/bin/env bash
# CI-only integration fixture for Raycast's Homebrew-to-mise ownership change.
# It uses an isolated HOME/appdir and restores the full Caskroom token on exit.
set -euo pipefail

mise="${MISE:?set MISE to the pinned mise binary}"
brew="/opt/homebrew/bin/brew"
[[ -x "$brew" ]] || { echo "Homebrew is unavailable" >&2; exit 1; }

tmp_dir="$(mktemp -d "$RUNNER_TEMP/raycast-adopt.XXXXXX")"
appdir="$tmp_dir/Applications"
config="$tmp_dir/mise.toml"
caskroom="$("$brew" --prefix)/Caskroom/raycast"
backup="$tmp_dir/Caskroom-raycast-backup"
app="$appdir/Raycast.app"
backup_ready=0
login_item_observed=0

cleanup() {
  status=$?
  if (( backup_ready )); then
    rm -rf "$caskroom"
    mv "$backup" "$caskroom"
  fi
  # Keep the appdir until the disposable runner is torn down so a restored
  # Homebrew receipt never points at a missing app bundle.
  exit "$status"
}
trap cleanup EXIT

fail() {
  echo "not ok - $*" >&2
  exit 1
}

app_fingerprint() {
  local output="$1"
  (
    cd "$app"
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

read_login_items() {
  /usr/bin/osascript -e 'tell application "System Events" to get the name of every login item' \
    >"$tmp_dir/login-items.txt" 2>"$tmp_dir/login-items.err"
}

has_raycast_login_item() {
  grep -Fq "Raycast" "$tmp_dir/login-items.txt"
}

mkdir -p "$appdir"
[[ ! -e "$caskroom" ]] || fail "runner already has a Raycast Caskroom token"

# Raycast's cask declares uninstall login_item: "Raycast". The runner may not
# have a GUI login session or Automation permission, so first probe whether a
# login item can be created and observed in its isolated account.
"$brew" install --cask --appdir="$appdir" raycast
[[ -d "$app" ]] || fail "Homebrew did not install Raycast into the fixture appdir"
bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist")"
[[ "$bundle_id" == "com.raycast.macos" ]] || fail "unexpected Raycast bundle identifier: $bundle_id"
"$brew" list --cask raycast >/dev/null 2>&1 || fail "Homebrew does not list the baseline Raycast cask"

if read_login_items; then
  if has_raycast_login_item; then
    echo "skip - runner already has a Raycast login item; leaving it untouched"
  elif /usr/bin/osascript - "$app" >"$tmp_dir/login-item-add.txt" 2>&1 <<'APPLESCRIPT'
on run argv
  set appPath to item 1 of argv
  tell application "System Events"
    make login item at end with properties {name:"Raycast", path:appPath, hidden:true}
  end tell
end run
APPLESCRIPT
  then
    if read_login_items && has_raycast_login_item; then
      login_item_observed=1
      echo "ok - runner registered and observed the Raycast login item"
    else
      echo "skip - runner created a Raycast login item but could not observe it afterward"
      cat "$tmp_dir/login-items.err" >&2 || true
    fi
  else
    echo "skip - runner could not register a Raycast login item"
    cat "$tmp_dir/login-item-add.txt" >&2 || true
  fi
else
  echo "skip - System Events login item inspection is unavailable on this runner"
  cat "$tmp_dir/login-items.err" >&2 || true
fi

app_inode="$(stat -f '%i' "$app")"
app_content="$tmp_dir/raycast-before.sha256"
app_fingerprint "$app_content"

# Move the complete Homebrew token while retaining the installed app and any
# test login item. This is the ownership handoff exercised by the TabTab pilot.
mv "$caskroom" "$backup"
backup_ready=1
if "$brew" list --cask raycast >/dev/null 2>&1; then
  fail "Homebrew still lists Raycast after its Caskroom token was moved"
fi

cat >"$config" <<EOF
[settings]
task.run_auto_install = false

[bootstrap.packages]
"brew-cask:raycast" = { adopt = true, appdir = "$appdir" }
EOF

(
  cd "$tmp_dir"
  MISE_GLOBAL_CONFIG_FILE="$config" \
    MISE_GLOBAL_CONFIG_ROOT="$tmp_dir" \
    "$mise" bootstrap packages apply brew-cask:raycast --yes
)

[[ -d "$caskroom" ]] || fail "mise did not create the Raycast Caskroom token"
[[ ! -e "$caskroom/.metadata" ]] || fail "mise adoption unexpectedly wrote Homebrew .metadata"
[[ "$(stat -f '%i' "$app")" == "$app_inode" ]] || fail "adoption replaced the Raycast app inode"
app_fingerprint "$tmp_dir/raycast-after-adopt.sha256"
cmp -s "$app_content" "$tmp_dir/raycast-after-adopt.sha256" ||
  fail "adoption changed Raycast app contents"
if (( login_item_observed )); then
  read_login_items || fail "System Events became unavailable after Raycast adoption"
  has_raycast_login_item || fail "Raycast adoption removed the registered login item"
  echo "ok - Raycast login item remained registered through adoption"
else
  echo "skip - login item preservation was not asserted because the runner could not verify it"
fi
echo "ok - mise adopted Raycast without replacing its app bundle"

# Roll back to the original Homebrew token before testing its cask uninstall
# cleanup. The app identity and test login item must still be intact.
rm -rf "$caskroom"
mv "$backup" "$caskroom"
backup_ready=0
[[ -d "$caskroom" ]] || fail "rollback did not restore the original Caskroom token"
"$brew" list --cask raycast >/dev/null 2>&1 || fail "Homebrew does not list Raycast after rollback"
[[ "$(stat -f '%i' "$app")" == "$app_inode" ]] || fail "rollback changed the Raycast app inode"
app_fingerprint "$tmp_dir/raycast-after-rollback.sha256"
cmp -s "$app_content" "$tmp_dir/raycast-after-rollback.sha256" ||
  fail "rollback changed Raycast app contents"
echo "ok - rollback restored the original Caskroom token and kept Raycast unchanged"

if (( login_item_observed )); then
  "$brew" uninstall --cask --force raycast
  [[ ! -e "$app" ]] || fail "Homebrew uninstall did not remove the fixture Raycast app"
  read_login_items || fail "System Events became unavailable after Homebrew uninstall"
  if has_raycast_login_item; then
    fail "Homebrew uninstall left the fixture Raycast login item registered"
  fi
  echo "ok - Homebrew uninstall removed the observable Raycast login item"
else
  echo "skip - cask uninstall login_item cleanup was not asserted without a verified login item"
fi
