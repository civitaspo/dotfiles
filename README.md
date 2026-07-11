# dotfiles

civitaspo's macOS configuration.

## Architecture

Each tool owns one clear responsibility:

| Tool | Responsibility | Files |
|------|----------------|-------|
| [nix-darwin](https://github.com/nix-darwin/nix-darwin) | macOS system settings, base CLI packages | `flake.nix`, `nix/darwin.nix` |
| [home-manager](https://github.com/nix-community/home-manager) | Dotfile placement (symlinks into `$HOME`) | `nix/home.nix` |
| [Homebrew](https://brew.sh) | GUI apps, local casks and App Store apps | `Brewfile`, `Casks/` |
| [mise](https://mise.jdx.dev) | CLI binaries and language runtimes | `config/mise/config.toml` |
| [Task](https://taskfile.dev) | Setup, update and reconcile workflows | `Taskfile.yml` |

Dotfiles are plain files: `config/` is placed into `~/.config` and `home/`
into `$HOME` by home-manager. Private configuration (work accounts, internal
hosts, agent settings, personal Cursor skills under `~/.cursor/skills/`)
lives in the separate private repository
[civitaspo/dotfiles-private](https://github.com/civitaspo/dotfiles-private),
consumed as a flake input.

## First-time setup

```sh
git clone git@github.com:civitaspo/dotfiles.git \
  ~/src/github.com/civitaspo/dotfiles
cd ~/src/github.com/civitaspo/dotfiles
./init.sh
```

`init.sh` installs Nix, Homebrew and mise, then applies the whole
configuration. Open a new terminal afterwards.

## Daily workflow

```sh
task               # list available tasks
task reconcile     # apply everything: nix-darwin + home-manager + Homebrew + mise
task switch        # apply only the Nix configuration (nix-darwin + home-manager)
task update        # update Nix inputs, mise tools and Homebrew packages
task import:brew   # capture the live Homebrew state back into the Brewfile
task check         # validate the nix-darwin configuration
```

To change a configuration file, edit it under `config/` or `home/` and run
`task switch`; home-manager re-links it into place.

## Dependency updates

The Renovate GitHub App runs daily on weekdays to open dependency update pull
requests for GitHub Actions, Nix flake inputs and mise-managed tools.

No repository token or Actions secret is required. Repository access is scoped
by the Renovate GitHub App installation.
