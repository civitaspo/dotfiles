#!/usr/bin/env bash
# CI-only integration fixture for the TabTab Homebrew-to-mise migration.
# Uses the pinned mise binary, temporary HOME and appdir, and restores the
# complete Homebrew Caskroom token directory on exit.
set -euo pipefail

mise="${MISE:?set MISE to the pinned mise binary}"
brew="/opt/homebrew/bin/brew"
[[ -x "$brew" ]] || { echo "Homebrew is unavailable" >&2; exit 1; }

tmp_dir="$(mktemp -d "$RUNNER_TEMP/tabtab-adopt.XXXXXX")"
appdir="$tmp_dir/Applications"
config="$tmp_dir/mise.toml"
caskroom="$("$brew" --prefix)/Caskroom/tabtab"
backup="$tmp_dir/Caskroom-tabtab-backup"
app="$appdir/TabTab.app"
backup_ready=0

cleanup() {
  status=$?
  if (( backup_ready )); then
    rm -rf "$caskroom"
    mv "$backup" "$caskroom"
  fi
  # Keep the temporary appdir until this disposable runner is torn down so
  # the restored Homebrew receipt never points at a missing app bundle.
  exit "$status"
}
trap cleanup EXIT

fail() {
  echo "not ok - $*" >&2
  exit 1
}

app_fingerprint() {
  (
    cd "$app"
    find . -type f -exec shasum -a 256 {} + | sort
    find . -type l -exec sh -c '
      for path do
        printf "link %s -> %s\n" "$path" "$(readlink "$path")"
      done
    ' sh {} + | sort
  )
}

mkdir -p "$appdir"
[[ ! -e "$caskroom" ]] || fail "runner already has a TabTab Caskroom token"

# This cask declares sha256 :no_check. Adoption still verifies app content
# against the cask download before mise claims the app.
"$brew" install --cask --appdir="$appdir" tabtab
[[ -d "$app" ]] || fail "Homebrew did not install TabTab into the fixture appdir"
"$brew" list --cask tabtab >/dev/null 2>&1 || fail "Homebrew does not list the baseline TabTab cask"

app_inode="$(stat -f '%i' "$app")"
app_content="$(app_fingerprint)"

# Move the whole token directory out of Homebrew's view while retaining the
# already-installed app. This models an ownership transfer without uninstall.
mv "$caskroom" "$backup"
backup_ready=1
if "$brew" list --cask tabtab >/dev/null 2>&1; then
  fail "Homebrew still lists TabTab after its Caskroom token was moved"
fi

cat >"$config" <<EOF
[settings]
task.run_auto_install = false

[bootstrap.packages]
"brew-cask:tabtab" = { version = "2.2.2", adopt = true, appdir = "$appdir" }
EOF

(
  cd "$tmp_dir"
  MISE_GLOBAL_CONFIG_FILE="$config" \
    MISE_GLOBAL_CONFIG_ROOT="$tmp_dir" \
    "$mise" bootstrap packages apply brew-cask:tabtab --yes
)

[[ -d "$caskroom" ]] || fail "mise did not create the TabTab Caskroom token"
[[ ! -e "$caskroom/.metadata" ]] || fail "mise adoption unexpectedly wrote Homebrew .metadata"
[[ "$(stat -f '%i' "$app")" == "$app_inode" ]] || fail "adoption replaced the TabTab app inode"
[[ "$(app_fingerprint)" == "$app_content" ]] ||
  fail "adoption changed TabTab app contents"
echo "ok - mise adopted TabTab without replacing its app bundle"

# Reapplying and upgrading the same pinned cask must preserve the adopted
# ownership state and app bundle.
(
  cd "$tmp_dir"
  MISE_GLOBAL_CONFIG_FILE="$config" \
    MISE_GLOBAL_CONFIG_ROOT="$tmp_dir" \
    "$mise" bootstrap packages apply brew-cask:tabtab --yes
  MISE_GLOBAL_CONFIG_FILE="$config" \
    MISE_GLOBAL_CONFIG_ROOT="$tmp_dir" \
    "$mise" bootstrap packages upgrade brew-cask:tabtab --yes
)
[[ -d "$caskroom" ]] || fail "repeat apply or upgrade lost the TabTab Caskroom token"
[[ ! -e "$caskroom/.metadata" ]] || fail "repeat apply or upgrade wrote Homebrew .metadata"
[[ "$(stat -f '%i' "$app")" == "$app_inode" ]] || fail "repeat apply or upgrade replaced the TabTab app inode"
[[ "$(app_fingerprint)" == "$app_content" ]] ||
  fail "repeat apply or upgrade changed TabTab app contents"
echo "ok - repeated apply and targeted upgrade preserve mise ownership and the app bundle"

# Explicitly roll back the Caskroom transition, then prove the original token
# directory and app are still present. The EXIT trap also performs this on any
# earlier failure, so CI never leaves the runner in a partial state.
rm -rf "$caskroom"
mv "$backup" "$caskroom"
backup_ready=0
[[ -d "$caskroom" ]] || fail "rollback did not restore the original Caskroom token"
"$brew" list --cask tabtab >/dev/null 2>&1 || fail "Homebrew does not list TabTab after rollback"
[[ "$(stat -f '%i' "$app")" == "$app_inode" ]] || fail "rollback changed the TabTab app inode"
[[ "$(app_fingerprint)" == "$app_content" ]] ||
  fail "rollback changed TabTab app contents"
echo "ok - rollback restored the original Caskroom token and kept the app unchanged"
