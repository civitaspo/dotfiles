#!/usr/bin/env bash
# First-time bootstrap for civitaspo/dotfiles.
#
# Installs Nix, Homebrew and mise, then applies the configuration. The
# nix-darwin activation also runs home-manager, which links every dotfile.
# Safe to re-run; every step is idempotent. For day-to-day work use `task`
# (see Taskfile.yml).
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
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# --- Homebrew ---------------------------------------------------------------
if [ ! -x /opt/homebrew/bin/brew ]; then
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Homebrew is intentionally not added to $PATH; both this script and
# `task brew` invoke it via the absolute path.

# --- mise -------------------------------------------------------------------
if [ ! -x "$HOME/.local/bin/mise" ]; then
  log "Installing mise..."
  curl -fsSL https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$PATH"

# --- Private dotfiles checkout (for editing; the flake fetches its own copy)
if [ ! -d "$PRIVATE_DIR/.git" ]; then
  log "Cloning dotfiles-private into $PRIVATE_DIR..."
  mkdir -p "$(dirname "$PRIVATE_DIR")"
  git clone "$PRIVATE_REPO" "$PRIVATE_DIR"
fi

# --- nix-darwin + home-manager (also links every dotfile) -------------------
if [ -e /run/current-system/sw/bin/darwin-rebuild ]; then
  darwin-rebuild switch --flake ".#aarch64-darwin"
else
  log "Activating nix-darwin for the first time..."
  nix build ".#darwinConfigurations.aarch64-darwin.system"
  ./result/sw/bin/darwin-rebuild switch --flake ".#aarch64-darwin"
  rm -f ./result
fi
export PATH="/run/current-system/sw/bin:$PATH"

# --- mise tools and Homebrew packages ---------------------------------------
log "Installing mise-managed tools..."
mise install
log "Installing Homebrew packages..."
PATH="/opt/homebrew/bin:$PATH" brew bundle --file ./Brewfile --force-cleanup

log "Done. Open a new terminal to load the new shell environment."
