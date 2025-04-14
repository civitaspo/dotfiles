#!/bin/bash

set -euo pipefail
REPO_ROOT=$(cd $(dirname $0); pwd)
AQUA_BIN_PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin"
BREW_BIN_PATH="/opt/homebrew/bin"
NIX_BIN_PATH="/nix/var/nix/profiles/default/bin"

has() {
    command -v "$1" > /dev/null 2>&1
}

info() {
    echo "$(date "+%Y-%m-%dT%H:%M:%S%z") [INFO] $1"
}

install_aqua() {
    local current_dir=$(pwd)
    cd $(mktemp -d)
    # https://aquaproj.github.io/docs/products/aqua-installer#shell-script
    curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v3.1.1/aqua-installer
    echo "e9d4c99577c6b2ce0b62edf61f089e9b9891af1708e88c6592907d2de66e3714  aqua-installer" | sha256sum -c -
    chmod +x aqua-installer
    ./aqua-installer
    cd "${current_dir}"
}

aqua_install() {
    env PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH" \
        AQUA_GLOBAL_CONFIG="${AQUA_GLOBAL_CONFIG:-}:${REPO_ROOT}/aqua.yaml" \
        aqua install --only-link --all
}

install_nix() {
    # XXX: checksum???
    # https://github.com/DeterminateSystems/nix-installer
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
}

install_brew() {
    # XXX: checksum???
    # https://brew.sh/
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

if [[ ! -f "${AQUA_BIN_PATH}/aqua" ]]; then
    install_aqua
fi
if [[ ! -f "${BREW_BIN_PATH}/brew" ]]; then
    install_brew
fi
if [[ ! -f "${NIX_BIN_PATH}/nix" ]]; then
    install_nix
fi

aqua_install

info "Done."
