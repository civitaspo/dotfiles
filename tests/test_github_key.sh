#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT
fake_bin="$test_root/bin"
mkdir -p "$fake_bin"

cat >"$fake_bin/uname" <<'EOF'
#!/usr/bin/env bash
[[ "$*" == -n ]] || exit 2
printf '%s\n' "${UNAME_OUTPUT:-test-mac.local}"
EOF

cat >"$fake_bin/sc_auth" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$1" in
  list-ctk-identities)
    [[ "${FAIL_IDENTITY_LIST:-0}" == 0 ]] || exit 1
    printf 'Key Type Public Key Hash Prot Label Common Name Email Address Valid To Valid\n'
    if [[ "${2:-} ${3:-}" == '-t ssh' ]]; then
      sed -E "s/^[^ ]+ [^ ]+/p-256-ne ${SSH_FINGERPRINT:-SHA256:Jgm4W91kTQbSh0\/LHFdqWIwcTHrpCVxVppoPDTSPFLE}/" "$IDENTITIES"
    else
      cat "$IDENTITIES"
    fi
    ;;
  create-ctk-identity)
    [[ "${FAIL_IDENTITY_CREATE:-0}" == 0 ]] || exit 1
    [[ "$2 $3 $4 $5 $6 $7" == '-l macbook-pro-test-mac.local -k p-256-ne -t none' ]] || exit 2
    printf 'p-256-ne %s none macbook-pro-test-mac.local macbook-pro-test-mac.local 2027/09/02, 7:22 YES\n' "$IDENTITY_HASH" >>"$IDENTITIES"
    ;;
  *) exit 2 ;;
esac
EOF

cat >"$fake_bin/ssh-keygen" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
key_body() {
  case "$1" in
    A) printf '%s' "$KEY_BODY" ;;
    B) printf '%s' "$UNRELATED_KEY_BODY" ;;
    C) printf '%s' "${DUPLICATE_KEY_BODY:-$UNRELATED_KEY_BODY}" ;;
    *) return 1 ;;
  esac
}
key_fingerprint() {
  case "$1" in
    A) printf '%s' "$KEY_FINGERPRINT" ;;
    B) printf '%s' "$UNRELATED_FINGERPRINT" ;;
    C) printf '%s' "${DUPLICATE_FINGERPRINT:-$UNRELATED_FINGERPRINT}" ;;
    *) return 1 ;;
  esac
}
key_id_for_public() {
  case "$(awk 'NF >= 2 { print $1 " " $2; exit }' "$1")" in
    "$KEY_BODY") printf A ;;
    "$UNRELATED_KEY_BODY") printf B ;;
    "${DUPLICATE_KEY_BODY:-$UNRELATED_KEY_BODY}") printf C ;;
    *) return 1 ;;
  esac
}
if [[ "$1" == -K ]]; then
  [[ "$#" == 5 && "$2" == -w && "$3" == "$SSH_SK_PROVIDER" && "$4" == -N && -z "$5" ]] || exit 2
  printf 'Enter PIN for authenticator:'
  IFS= read -r pin
  printf 'PIN\n' >>"$EXPORT_LOG"
  printf 'handle A\n' >id_ecdsa_sk_rk
  printf '%s test-key\n' "$KEY_BODY" >id_ecdsa_sk_rk.pub
  printf 'id_ecdsa_sk_rk already exists. Overwrite (y/n)?'
  IFS= read -r response
  [[ "$response" == y ]] || exit 1
  printf 'OVERWRITE\n' >>"$EXPORT_LOG"
  printf 'handle B\n' >id_ecdsa_sk_rk
  printf '%s unrelated\n' "$UNRELATED_KEY_BODY" >id_ecdsa_sk_rk.pub
  if [[ "${EXTRA_EXPORT:-0}" == 1 ]]; then
    printf 'id_ecdsa_sk_rk already exists. Overwrite (y/n)?'
    IFS= read -r response
    [[ "$response" == y ]] || exit 1
    printf 'OVERWRITE\n' >>"$EXPORT_LOG"
    printf 'handle C\n' >id_ecdsa_sk_rk
    printf '%s extra\n' "${DUPLICATE_KEY_BODY:-$UNRELATED_KEY_BODY}" >id_ecdsa_sk_rk.pub
  fi
  [[ "${FAIL_EXPORT:-0}" == 0 ]] || exit 1
elif [[ "$1" == -lf ]]; then
  key_file=$2
  key_id=$(key_id_for_public "$key_file")
  printf '256 %s ssh-key: (ECDSA-SK)\n' "$(key_fingerprint "$key_id")"
elif [[ "$1" == -y ]]; then
  [[ "$2 $3 $4" == "-P  -w" ]] || exit 2
  while (($#)); do
    if [[ "$1" == -f ]]; then key_file=$2; shift 2; else shift; fi
  done
  [[ -f "$key_file" ]] || exit 1
  key_id=$(awk 'NR == 1 { print $2 }' "$key_file")
  printf '%s test-key\n' "$(key_body "$key_id")"
else
  exit 2
fi
EOF

cat >"$fake_bin/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1" == api ]]; then
  [[ "${*: -2}" == '--hostname github.com' ]] || exit 2
fi
if [[ "$1 $2" == 'auth status' ]]; then
  [[ "${FAIL_GH_STATUS:-0}" == 0 ]] || exit 1
  printf '%s\t%s\n' "${GH_LOGIN:-civitaspo}" "${GH_SCOPES:-admin:public_key, admin:ssh_signing_key}"
elif [[ "$1 $2 $3" == 'api user --jq' ]]; then
  [[ "${FAIL_GH_USER:-0}" == 0 ]] || exit 1
  printf '%s\n' "${GH_API_LOGIN:-civitaspo}"
elif [[ "$1 $2" == 'api --paginate' ]]; then
  endpoint=$5
  [[ "${FAIL_GH_LIST:-}" != "$endpoint" ]] || exit 1
  case "$endpoint" in
    /user/keys) cat "$AUTH_KEYS" ;;
    /user/ssh_signing_keys) cat "$SIGNING_KEYS" ;;
    *) exit 2 ;;
  esac
elif [[ "$1 $2 $3" == 'api --method POST' ]]; then
  endpoint=$4
  key=${8#key=}
  [[ "${FAIL_GH_POST:-}" != "$endpoint" ]] || exit 1
  if [[ "$endpoint" == /user/ssh_signing_keys && "${FAIL_SIGNING_POST_ONCE:-0}" == 1 && ! -f "$SIGNING_POST_FAILED" ]]; then
    touch "$SIGNING_POST_FAILED"
    exit 1
  fi
  case "$endpoint" in
    /user/keys) printf '%s\n' "$key" >>"$AUTH_KEYS" ;;
    /user/ssh_signing_keys) printf '%s\n' "$key" >>"$SIGNING_KEYS" ;;
    *) exit 2 ;;
  esac
else
  exit 2
fi
EOF
chmod +x "$fake_bin"/*

reset_case() {
  export GH_HOST=enterprise.invalid
  export HOME="$test_root/home"
  export IDENTITIES="$test_root/identities"
  export AUTH_KEYS="$test_root/auth-keys"
  export SIGNING_KEYS="$test_root/signing-keys"
  export SIGNING_POST_FAILED="$test_root/signing-post-failed"
  export IDENTITY_HASH=BF1823F480CB551E1E5315C0DC2EBFD4FB40981C
  export KEY_FINGERPRINT=SHA256:Jgm4W91kTQbSh0/LHFdqWIwcTHrpCVxVppoPDTSPFLE
  export UNRELATED_FINGERPRINT=SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
  export KEY_BODY='sk-ecdsa-sha2-nistp256@openssh.com AAAAE2VjZHNhLXNoYTItbmlzdHAyNTY='
  export UNRELATED_KEY_BODY='sk-ecdsa-sha2-nistp256@openssh.com BBBBE2VjZHNhLXNoYTItbmlzdHAyNTY='
  export SC_AUTH_BIN="$fake_bin/sc_auth"
  export SSH_KEYGEN_BIN="$fake_bin/ssh-keygen"
  export SSH_SK_PROVIDER="$test_root/provider.dylib"
  export EXPECT_BIN=/usr/bin/expect
  export GH_BIN="$fake_bin/gh"
  export EXPORT_LOG="$test_root/export.log"
  export PATH="$fake_bin:/usr/bin:/bin"
  unset FAIL_IDENTITY_LIST FAIL_IDENTITY_CREATE FAIL_EXPORT EXTRA_EXPORT FAIL_GH_STATUS FAIL_GH_USER FAIL_GH_LIST FAIL_GH_POST FAIL_SIGNING_POST_ONCE GH_LOGIN GH_API_LOGIN GH_SCOPES SSH_FINGERPRINT DUPLICATE_FINGERPRINT DUPLICATE_KEY_BODY UNAME_OUTPUT
  rm -rf "$HOME" "$SIGNING_POST_FAILED"
  mkdir -p "$HOME"
  : >"$IDENTITIES"
  : >"$AUTH_KEYS"
  : >"$SIGNING_KEYS"
  : >"$EXPORT_LOG"
}

run_task() {
  bash "$repo_root/mise-tasks/setup/github-key"
}

file_mode() {
  if stat -c %a "$1" >/dev/null 2>&1; then
    stat -c %a "$1"
  else
    stat -f %Lp "$1"
  fi
}

reset_case
run_task >/dev/null
[[ -f "$HOME/.ssh/id_github_secure_enclave" && -f "$HOME/.ssh/id_github_secure_enclave.pub" ]]
[[ "$(cat "$HOME/.ssh/id_github_secure_enclave")" == 'handle A' ]]
[[ "$(cat "$HOME/.ssh/id_github_secure_enclave.pub")" == "$KEY_BODY test-key" ]]
[[ "$(file_mode "$HOME/.ssh")" == 700 ]]
[[ "$(file_mode "$HOME/.ssh/id_github_secure_enclave")" == 600 ]]
[[ "$(file_mode "$HOME/.ssh/id_github_secure_enclave.pub")" == 644 ]]
[[ $(wc -l <"$IDENTITIES" | tr -d ' ') == 1 ]]
[[ $(wc -l <"$AUTH_KEYS" | tr -d ' ') == 1 && $(wc -l <"$SIGNING_KEYS" | tr -d ' ') == 1 ]]
run_task >/dev/null
[[ $(wc -l <"$IDENTITIES" | tr -d ' ') == 1 ]]
[[ $(wc -l <"$AUTH_KEYS" | tr -d ' ') == 1 && $(wc -l <"$SIGNING_KEYS" | tr -d ' ') == 1 ]]
[[ $(wc -l <"$EXPORT_LOG" | tr -d ' ') == 2 ]]

reset_case
export UNAME_OUTPUT='bad host'
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -s "$IDENTITIES" ]]

reset_case
printf 'p-256-ne OTHERHASH none other other 2027/09/02, 7:22 YES\n' >"$IDENTITIES"
run_task >/dev/null
[[ $(wc -l <"$IDENTITIES" | tr -d ' ') == 2 ]]

reset_case
printf 'p-256-ne %s none macbook-pro-test-mac.local macbook-pro-test-mac.local 2027/09/02, 7:22 YES\np-256-ne SECONDHASH none macbook-pro-test-mac.local macbook-pro-test-mac.local 2027/09/02, 7:22 YES\n' "$IDENTITY_HASH" >"$IDENTITIES"
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -e "$HOME/.ssh/id_github_secure_enclave" ]]

reset_case
printf 'p-256-ne %s none macbook-pro-test-mac.local macbook-pro-test-mac.local 2027/09/02, 7:22 YES\n' "$IDENTITY_HASH" >"$IDENTITIES"
mkdir -p "$HOME/.ssh"
printf 'handle %s\n' "$KEY_BODY" >"$HOME/.ssh/id_github_secure_enclave"
if run_task >/dev/null 2>&1; then exit 1; fi

reset_case
printf 'p-256-ne %s none macbook-pro-test-mac.local macbook-pro-test-mac.local 2027/09/02, 7:22 YES\n' "$IDENTITY_HASH" >"$IDENTITIES"
mkdir -p "$HOME/.ssh"
printf 'handle B\n' >"$HOME/.ssh/id_github_secure_enclave"
printf '%s test-key\n' "$KEY_BODY" >"$HOME/.ssh/id_github_secure_enclave.pub"
if run_task >/dev/null 2>&1; then exit 1; fi

reset_case
printf 'p-256-ne %s none macbook-pro-test-mac.local macbook-pro-test-mac.local 2027/09/02, 7:22 YES\n' "$IDENTITY_HASH" >"$IDENTITIES"
export FAIL_GH_STATUS=1
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -e "$HOME/.ssh/id_github_secure_enclave" ]]

reset_case
export GH_SCOPES='repo, gist'
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -e "$HOME/.ssh/id_github_secure_enclave" ]]

reset_case
export FAIL_IDENTITY_LIST=1
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -s "$IDENTITIES" ]]

reset_case
export FAIL_IDENTITY_CREATE=1
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -s "$IDENTITIES" ]]

reset_case
export IDENTITY_HASH=not-a-hash
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -e "$HOME/.ssh/id_github_secure_enclave" ]]

reset_case
export SSH_FINGERPRINT=not-a-fingerprint
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -s "$EXPORT_LOG" && ! -e "$HOME/.ssh/id_github_secure_enclave" ]]

reset_case
export FAIL_EXPORT=1
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -e "$HOME/.ssh/id_github_secure_enclave" ]]
[[ $(wc -l <"$EXPORT_LOG" | tr -d ' ') == 2 ]]

reset_case
export EXTRA_EXPORT=1
run_task >/dev/null
[[ "$(cat "$HOME/.ssh/id_github_secure_enclave.pub")" == "$KEY_BODY test-key" ]]
[[ $(grep -c '^OVERWRITE$' "$EXPORT_LOG") == 2 ]]

reset_case
export SSH_FINGERPRINT=SHA256:CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -e "$HOME/.ssh/id_github_secure_enclave" ]]

reset_case
export EXTRA_EXPORT=1
export DUPLICATE_FINGERPRINT="$KEY_FINGERPRINT"
export DUPLICATE_KEY_BODY="$KEY_BODY"
if run_task >/dev/null 2>&1; then exit 1; fi
[[ ! -e "$HOME/.ssh/id_github_secure_enclave" ]]

reset_case
export FAIL_GH_LIST=/user/keys
if run_task >/dev/null 2>&1; then exit 1; fi
[[ -f "$HOME/.ssh/id_github_secure_enclave" && ! -s "$AUTH_KEYS" ]]

reset_case
export FAIL_SIGNING_POST_ONCE=1
if run_task >/dev/null 2>&1; then exit 1; fi
[[ $(wc -l <"$AUTH_KEYS" | tr -d ' ') == 1 && ! -s "$SIGNING_KEYS" ]]
run_task >/dev/null
[[ $(wc -l <"$AUTH_KEYS" | tr -d ' ') == 1 && $(wc -l <"$SIGNING_KEYS" | tr -d ' ') == 1 ]]

reset_case
printf '%s another-title\n' "$KEY_BODY" >"$AUTH_KEYS"
printf '%s another-title\n' "$KEY_BODY" >"$SIGNING_KEYS"
run_task >/dev/null
[[ $(wc -l <"$AUTH_KEYS" | tr -d ' ') == 1 && $(wc -l <"$SIGNING_KEYS" | tr -d ' ') == 1 ]]

printf 'github-key setup checks passed\n'
