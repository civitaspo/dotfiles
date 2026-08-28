# Homebrew bundle: GUI applications, local casks, and App Store apps.
#
# This file is the source of truth. Apply it with `mise run brew` (installs,
# upgrades, and uninstalls packages not listed here) and capture drift with
# `mise run import:brew` (VS Code extensions are intentionally excluded via
# --no-vscode). Local tap casks are pinned after install so brew leaves them
# to in-app updates; check stale Casks/ pins with `mise run livecheck:casks`.
# Homebrew is intentionally NOT on $PATH --
# `mise run brew` is the only entry point. CLI binaries come from mise, and
# base packages plus pinned runtimes come from Nix.

# --- Taps -------------------------------------------------------------------
# Clone from this checkout so Brewfile and Casks/ stay in sync.
# `mise run brew` / `mise run update:brew` run `mise run brew:tap` first so
# the installed tap remote matches `__dir__` (required for Homebrew 6 trust).
tap "civitaspo/dotfiles", __dir__, trusted: true

# --- Casks: applications ----------------------------------------------------
cask "1password"
cask "aqua-voice"
cask "azookey"
cask "cleanshot"
cask "codex-app"
cask "cursor"
cask "facescreen"
cask "ghostty"
cask "hammerspoon"
cask "homerow"
cask "civitaspo/dotfiles/kanary"
cask "karabiner-elements"
cask "keyboard-maestro"
cask "linear"
cask "mimestream"
cask "civitaspo/dotfiles/nospace"
cask "civitaspo/dotfiles/openin4"
cask "qmk-toolbox"
cask "raycast"
cask "civitaspo/dotfiles/reflect-open"
cask "space-rabbit"
cask "spotify"
cask "tabtab"

# --- Casks: fonts -----------------------------------------------------------
cask "font-monaspice-nerd-font"

# --- Mac App Store ----------------------------------------------------------
# Keynote/Numbers/Pages use the universal App Store IDs. Apple delisted the
# classic Mac ADAM IDs (409183694, 409203825, 409201541) in April 2026, so
# mas fails those with "No apps found in the App Store". The current
# listings install as Creator Studio builds (com.apple.Keynote and friends)
# alongside any remaining classic iWork apps (com.apple.iWork.*).
mas "1Password for Safari", id: 1569813296
mas "Amphetamine", id: 937984704
mas "Bear", id: 1091189122
mas "Display Menu", id: 549083868
mas "Keynote", id: 361285480
mas "Kindle", id: 302584613
mas "Klack", id: 6446206067
mas "LINE", id: 539883307
mas "Numbers", id: 361304891
mas "Pages", id: 361309726
mas "Twingate", id: 1501592214
