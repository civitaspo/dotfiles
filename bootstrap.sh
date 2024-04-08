#!/usr/bin/env bash

set -euo pipefail
ROOT=$(cd $(dirname $0); pwd)

# https://github.com/DeterminateSystems/nix-installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# https://brew.sh/
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install
${ROOT}/build-switch.sh
