# dotfiles

civitaspo's macOS configuration.

## Architecture

Each tool owns one clear responsibility:

| Tool | Responsibility | Files |
|------|----------------|-------|
| [nix-darwin](https://github.com/nix-darwin/nix-darwin) | macOS system settings | `flake.nix`, `nix/darwin.nix` |
| [Homebrew](https://brew.sh) | GUI apps, App Store apps, base packages | `Brewfile` |
| [mise](https://mise.jdx.dev) | CLI binaries and language runtimes | `config/mise/config.toml` |
| [Task](https://taskfile.dev) | Setup, update and reconcile workflows | `Taskfile.yml` |

Plain dotfiles under `config/` are symlinked into `~/.config`, and dotfiles
under `home/` into `$HOME`. Private configuration (work accounts, internal
hosts, agent settings) lives in the separate private repository
[civitaspo/dotfiles-private](https://github.com/civitaspo/dotfiles-private).

## First-time setup

```sh
git clone git@github.com:civitaspo/dotfiles.git \
  ~/src/github.com/civitaspo/dotfiles
cd ~/src/github.com/civitaspo/dotfiles
./init.sh
```

`init.sh` installs Nix, Homebrew and mise, clones the private repository, and
applies the whole configuration. Open a new terminal afterwards.

## Daily workflow

```sh
task               # list available tasks
task reconcile     # apply everything: symlinks + nix-darwin + Homebrew + mise
task switch        # apply only the nix-darwin configuration
task update        # update Nix inputs, mise tools and Homebrew packages
task import:brew   # capture the live Homebrew state back into the Brewfile
task check         # validate the nix-darwin configuration
```

To change a configuration file, edit it under `config/` or `home/` and run
`task reconcile` (the files in `$HOME` are symlinks back into this repository).

## Adding a machine

Machines are identified by their device serial number. Add an entry
`macbook-<serial>` to the `hostnames` list in `flake.nix`.
