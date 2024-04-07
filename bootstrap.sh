#!/usr/bin/env bash

set -euo pipefail

# https://github.com/DeterminateSystems/nix-installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# https://brew.sh/
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install
if [[ "$(uname -o)" = "Darwin" ]]; then
  readonly SERIAL_NUMBER=$(ioreg -l | grep IOPlatformSerialNumber | cut -d= -f2 | cut -d\" -f2)
  cd $(dirname $0)
  nix build ".#darwinConfigurations.macbook-${SERIAL_NUMBER}.system"
  ./result/sw/bin/darwin-rebuild switch --flake "$(pwd)#macbook-${SERIAL_NUMBER}"
else
  echo "Unimplemented..." >&2
  exit 1
fi
