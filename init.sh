#!/usr/bin/env bash
# First-time bootstrap for civitaspo/dotfiles.
#
# Installs Nix, Homebrew and mise, clones the private dotfiles, then applies
# the whole configuration. Safe to re-run; every step is idempotent. For day
# to day work use `task` instead (see Taskfile.yml).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_DIR="${PRIVATE_DIR:-$HOME/src/github.com/civitaspo/dotfiles-private}"
PRIVATE_REPO="git@github.com:civitaspo/dotfiles-private.git"

log() { printf '\033[1;32m[init]\033[0m %s\n' "$*"; }

cd "$REPO_ROOT"

# --- Nix (Determinate Systems installer) ------------------------------------
if [ ! -e /nix/var/nix/profiles/default/bin/nix ]; then
  log "Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# --- Homebrew ---------------------------------------------------------------
if [ ! -x /opt/homebrew/bin/brew ]; then
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- mise -------------------------------------------------------------------
if [ ! -x "$HOME/.local/bin/mise" ]; then
  log "Installing mise..."
  curl -fsSL https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$PATH"

# --- Private dotfiles -------------------------------------------------------
if [ ! -d "$PRIVATE_DIR/.git" ]; then
  log "Cloning dotfiles-private into $PRIVATE_DIR..."
  mkdir -p "$(dirname "$PRIVATE_DIR")"
  git clone "$PRIVATE_REPO" "$PRIVATE_DIR"
fi

# --- mise-managed tools (this is what provides `task`) ----------------------
log "Installing mise-managed tools..."
mkdir -p "$HOME/.config/mise"
ln -sfn "$REPO_ROOT/config/mise/config.toml" "$HOME/.config/mise/config.toml"
mise install

# --- First nix-darwin activation --------------------------------------------
HOST="macbook-$(/usr/sbin/ioreg -l | awk -F'"' '/IOPlatformSerialNumber/{print $4}')"
if [ ! -e /run/current-system/sw/bin/darwin-rebuild ]; then
  log "Activating nix-darwin for the first time ($HOST)..."
  nix build ".#darwinConfigurations.${HOST}.system"
  ./result/sw/bin/darwin-rebuild switch --flake ".#${HOST}"
  rm -f ./result
fi
export PATH="/run/current-system/sw/bin:$PATH"

# --- Apply the rest with Task -----------------------------------------------
log "Applying configuration..."
mise exec -- task reconcile

log "Done. Open a new terminal to load the new shell environment."
