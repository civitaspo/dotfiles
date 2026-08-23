# dotfiles

civitaspo's macOS configuration.

## Architecture

Each tool owns one clear responsibility:

| Tool | Responsibility | Files |
|------|----------------|-------|
| [nix-darwin](https://github.com/nix-darwin/nix-darwin) | macOS system settings, base CLI packages | `flake.nix`, `nix/darwin.nix` |
| [home-manager](https://github.com/nix-community/home-manager) | Dotfile placement (symlinks into `$HOME`) | `nix/home.nix` |
| [Homebrew](https://brew.sh) | GUI apps, local casks and App Store apps | `Brewfile`, `Casks/` |
| [mise](https://mise.jdx.dev) | CLI binaries, language runtimes, and repository workflows | `config/mise/config.toml`, `mise.toml`, `mise-tasks/` |

Dotfiles are plain files: `config/` is placed into `~/.config` and `home/`
into `$HOME` by home-manager. Private configuration (work accounts, internal
hosts, agent settings) lives in the separate private repository
[civitaspo/dotfiles-private](https://github.com/civitaspo/dotfiles-private),
consumed as a flake input.

## First-time setup

Prerequisites:

- Apple Silicon Mac running macOS Sonoma or later
- macOS account short name exactly `takahiro.nakayama`
- Xcode Command Line Tools (`xcode-select --install`)
- an administrator password for sudo

```sh
git clone https://github.com/civitaspo/dotfiles.git \
  ~/src/github.com/civitaspo/dotfiles
cd ~/src/github.com/civitaspo/dotfiles
./bootstrap.sh
~/.local/bin/mise run bootstrap
/opt/homebrew/bin/brew install --cask 1password
sudo softwareupdate --install-rosetta --agree-to-license
```

Then pause and do the following by hand:

- Open 1Password and sign in.
- Enable Settings → Developer → SSH Agent.
- Confirm the keys named in `config/1Password/ssh/agent.toml`.
- Sign into the Mac App Store with the Apple ID that owns the Brewfile `mas` apps.
- Confirm GitHub access to `civitaspo/dotfiles-private` (`ssh -T git@github.com`).
- Optionally clone the private repo for editing:

  ```sh
  git clone git@github.com:civitaspo/dotfiles-private.git \
    ~/src/github.com/civitaspo/dotfiles-private
  ```

  That checkout is not the symlink source. `mise run switch` fetches the
  locked `dotfiles-private` flake input over SSH.

Open a new terminal and apply the configuration:

```sh
cd ~/src/github.com/civitaspo/dotfiles
~/.local/bin/mise run reconcile
```

`bootstrap.sh` only installs a pinned, verified mise. `mise run bootstrap`
installs pinned, signed Determinate Nix and Homebrew packages. `mise run
reconcile` is the only apply step: nix-darwin, Homebrew, then locked mise
tools.

If App Store apps fail until they have been acquired on this Apple ID, Get
them once in the App Store and rerun `mise run brew`. Other failed steps are
idempotent; rerun the task that stopped.

Rosetta is required because the committed `mise.lock` entries for dust,
procs, and silicon use x86_64 assets on macOS arm64.

## Daily workflow

```sh
mise run               # list available tasks
mise run reconcile     # apply everything: nix-darwin + home-manager + Homebrew + mise
mise run switch        # apply only the Nix configuration (nix-darwin + home-manager)
mise run update        # update Nix inputs, mise tools and Homebrew packages
mise run import:brew   # capture the live Homebrew state back into the Brewfile
mise run livecheck:casks # show newer upstream versions for local tap casks
mise run check         # validate the configuration
```

To change a configuration file, edit it under `config/` or `home/` and run
`mise run switch`; home-manager re-links it into place.

After the first successful reconcile, home-manager puts mise on `PATH`, so
`mise run …` works without the `~/.local/bin/mise` prefix.

## After the first reconcile

These are manual and are not part of `mise run reconcile`:

- grant Accessibility / Input Monitoring / Screen Recording to Karabiner,
  Hammerspoon, AeroSpace, Space Rabbit, Homerow, Keyboard Maestro, and
  CleanShot
- sign into paid apps (CleanShot, Keyboard Maestro, Mimestream, and others)
- Git commit signing via 1Password (`op-ssh-sign`)
- `op signin`, `gh auth`, `gcloud auth`, AWS SSO, SnowSQL, and Atuin
- Cursor, Claude Code, and Codex sign-in

home-manager moves conflicting files aside with a `.backup` suffix.
Activation disables Spotlight indexing. `mise run brew` uses
`brew bundle --force-cleanup`, so packages not listed in the Brewfile are
removed. Local tap casks (Kanary, Nospace, OpenIn, Reflect Open) are
pinned and self-update in-app; `brew upgrade` skips them.

## Dependency updates

The Renovate GitHub App runs daily on weekdays to open dependency update pull
requests for GitHub Actions, Nix flake inputs and mise-managed tools.

Trusted PRs (Renovate, Dependabot, and `civitaspo`) request approval through
[`civitaspo/securefix-server`](https://github.com/civitaspo/securefix-server)
via `.github/workflows/approve-request.yml`. Non-major Renovate updates enable
GitHub auto-merge (`platformAutomerge: true`); after the Securefix bot
approves, the `main` ruleset lets GitHub squash-merge.

The private flake input `dotfiles-private` is ignored by Renovate (SSH lookup
is impossible from the Mend app). Repository access for Renovate is scoped by
the Renovate GitHub App installation. Approve requests need the repository
secret `SECUREFIX_CLIENT_PRIVATE_KEY` only.
