#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT
sudo_config="$test_root/sudo"
local_config="$test_root/sudo_local"
activation="$test_root/activate"
mkdir -p "$test_root/bin"
cat >"$test_root/bin/nix-env" <<'MOCK'
#!/usr/bin/env bash
echo "$*" >>"$PROFILE_LOG"
MOCK
chmod +x "$test_root/bin/nix-env"
export PATH="$test_root/bin:$PATH" PROFILE_LOG="$test_root/profiles"
cat >"$activation" <<'MOCK'
#!/usr/bin/env bash
echo activated >>"$ACTIVATION_LOG"
if [[ "${REMOVE_LOCAL:-0}" == 1 ]]; then rm "$LOCAL_CONFIG"; fi
exit "${ACTIVATION_EXIT:-0}"
MOCK
chmod +x "$activation"
export ACTIVATION_LOG="$test_root/activations" LOCAL_CONFIG="$local_config"
printf 'auth include sudo_local\n' >"$sudo_config"

# nix-darwin removes its old link during activation; restore Touch ID afterwards.
printf 'auth sufficient pam_tid.so\n' >"$test_root/nix-managed"
ln -s "$test_root/nix-managed" "$local_config"
REMOVE_LOCAL=1 "$root/mise-tasks/setup/activate-system" "$activation" "$sudo_config" "$local_config"
[[ ! -L "$local_config" && "$(cat "$local_config")" == 'auth       sufficient     pam_tid.so' ]]
if [[ "$(uname -s)" == Darwin ]]; then
  mode="$(/usr/bin/stat -f '%Lp' "$local_config")"
else
  mode="$(/usr/bin/stat -c '%a' "$local_config")"
fi
[[ "$mode" == 644 ]]

# Keep an existing compatible local file unchanged across repeated runs.
printf '# local configuration\nauth sufficient pam_tid.so\n' >"$local_config"
cp "$local_config" "$test_root/expected"
"$root/mise-tasks/setup/activate-system" "$activation" "$sudo_config" "$local_config"
cmp "$test_root/expected" "$local_config"

# Preserve Touch ID even if activation fails after removing its old file.
rm "$local_config"
if ACTIVATION_EXIT=1 "$root/mise-tasks/setup/activate-system" "$activation" "$sudo_config" "$local_config"; then
  echo 'activation failure must be reported' >&2
  exit 1
fi
[[ "$(cat "$local_config")" == 'auth       sufficient     pam_tid.so' ]]

# Refuse conflicting configuration or unsupported sudo before activation.
printf 'auth required pam_example.so\n' >"$local_config"
cp "$local_config" "$test_root/expected"
before="$(wc -l <"$ACTIVATION_LOG" | tr -d ' ')"
profiles_before="$(wc -l <"$PROFILE_LOG" | tr -d ' ')"
if "$root/mise-tasks/setup/activate-system" "$activation" "$sudo_config" "$local_config"; then
  echo 'conflicting PAM configuration must fail' >&2
  exit 1
fi
cmp "$test_root/expected" "$local_config"
printf '# no local include\n' >"$sudo_config"
if "$root/mise-tasks/setup/activate-system" "$activation" "$sudo_config" "$local_config"; then
  echo 'missing sudo_local include must fail' >&2
  exit 1
fi
printf 'auth include sudo_local # nix-darwin: security.pam.services.sudo_local\n' >"$sudo_config"
printf 'auth sufficient pam_tid.so\n' >"$local_config"
if "$root/mise-tasks/setup/activate-system" "$activation" "$sudo_config" "$local_config"; then
  echo 'nix-darwin-managed include must fail' >&2
  exit 1
fi
[[ "$(wc -l <"$ACTIVATION_LOG" | tr -d ' ')" == "$before" ]]
[[ "$(wc -l <"$PROFILE_LOG" | tr -d ' ')" == "$profiles_before" ]]
echo 'system activation checks passed'
