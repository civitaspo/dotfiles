#!/usr/bin/env bash

set -euo pipefail
ROOT=$(cd $(dirname $0); pwd)

# install
if [[ "$(uname -o)" = "Darwin" ]]; then
  readonly SERIAL_NUMBER=$(ioreg -l | grep IOPlatformSerialNumber | cut -d= -f2 | cut -d\" -f2)
  cd ${ROOT}
  nix build ".#darwinConfigurations.macbook-${SERIAL_NUMBER}.system"
  ./result/sw/bin/darwin-rebuild switch --flake "$(pwd)#macbook-${SERIAL_NUMBER}"
else
  echo "Unimplemented..." >&2
  exit 1
fi
