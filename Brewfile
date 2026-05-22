# Homebrew bundle: GUI applications and App Store apps.
#
# This file is the source of truth. Apply it with `task brew` and capture
# drift with `task import:brew`. CLI binaries and language runtimes come from
# mise; base packages (GNU userland, git, shell plugins) come from Nix.

# --- Taps -------------------------------------------------------------------
tap "civitaspo/tap"
tap "nikitabobko/tap"

# --- Formula (exception) ----------------------------------------------------
# colima would normally be a Nix package, but nixpkgs currently flags its
# lima dependency (lima-full) as insecure. It is kept on Homebrew to avoid
# whitelisting a known-insecure package in Nix.
brew "colima"

# --- Casks: applications ----------------------------------------------------
cask "1password"
cask "nikitabobko/tap/aerospace"
cask "aqua-voice"
cask "arc"
cask "azookey"
cask "chatgpt"
cask "chatwise"
cask "choosy"
cask "claude"
cask "cleanshot"
cask "cmux"
cask "codex-app"
cask "cursor"
cask "emdash"
cask "flashspace"
cask "gather"
cask "ghostty"
cask "google-cloud-sdk"
cask "google-japanese-ime"
cask "hammerspoon"
cask "homerow"
cask "karabiner-elements"
cask "keyboard-maestro"
cask "kiro"
cask "linear"
cask "mimestream"
cask "civitaspo/tap/openin4"
cask "qmk-toolbox"
cask "raycast"
cask "snowflake-snowsql"
cask "spotify"
cask "tabtab"
cask "thingsmacsandboxhelper"

# --- Casks: fonts -----------------------------------------------------------
cask "font-monaspace-nerd-font"

# --- Mac App Store ----------------------------------------------------------
mas "1Password for Safari", id: 1569813296
mas "Amphetamine", id: 937984704
mas "Anybox", id: 1593408455
mas "Bear", id: 1091189122
mas "Display Menu", id: 549083868
mas "GarageBand", id: 682658836
mas "Goodnotes", id: 1444383602
mas "iMovie", id: 408981434
mas "Keynote", id: 409183694
mas "Kindle", id: 302584613
mas "Klack", id: 6446206067
mas "LINE", id: 539883307
mas "Magnet", id: 441258766
mas "Numbers", id: 409203825
mas "Pages", id: 409201541
mas "Things", id: 904280696
mas "Toggl Track", id: 1291898086
mas "Twingate", id: 1501592214

# --- VS Code / Cursor extensions --------------------------------------------
vscode "alefragnani.project-manager"
vscode "anysphere.cursorpyright"
vscode "asvetliakov.vscode-neovim"
vscode "bbenoist.nix"
vscode "bufbuild.vscode-buf"
vscode "catppuccin.catppuccin-vsc"
vscode "catppuccin.catppuccin-vsc-icons"
vscode "charliermarsh.ruff"
vscode "christian-kohler.path-intellisense"
vscode "denoland.vscode-deno"
vscode "drcika.apc-extension"
vscode "eamodio.gitlens"
vscode "formulahendry.auto-close-tag"
vscode "github.vscode-github-actions"
vscode "github.vscode-pull-request-github"
vscode "golang.go"
vscode "grafana.vscode-jsonnet"
vscode "hashicorp.terraform"
vscode "mads-hartmann.bash-ide-vscode"
vscode "ms-python.debugpy"
vscode "ms-python.isort"
vscode "ms-python.python"
vscode "ms-vscode-remote.remote-containers"
vscode "ms-vscode.vscode-typescript-next"
vscode "oderwat.indent-rainbow"
vscode "samuelcolvin.jinjahtml"
vscode "shopify.ruby-lsp"
vscode "streetsidesoftware.code-spell-checker"
vscode "tamasfe.even-better-toml"
vscode "task.vscode-task"
vscode "tompollak.lazygit-vscode"
vscode "tomrijndorp.find-it-faster"
vscode "tshino.kb-macro"
vscode "visualstudioexptteam.intellicode-api-usage-examples"
vscode "visualstudioexptteam.vscodeintellicode"
vscode "visualstudioexptteam.vscodeintellicode-completions"
vscode "wayou.vscode-todo-highlight"
