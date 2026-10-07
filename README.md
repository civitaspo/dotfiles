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
- Configure the Secure Enclave key using the steps below, then confirm access
  to `civitaspo/dotfiles-private` (`git ls-remote git@github.com:civitaspo/dotfiles-private.git`).
- Optionally clone the private repo for editing:

  ```sh
  git clone git@github.com:civitaspo/dotfiles-private.git \
    ~/src/github.com/civitaspo/dotfiles-private
  ```

  That checkout is not the symlink source. `mise run switch` fetches the
  locked `dotfiles-private` flake input over SSH.

Install the CLI tools and register this Mac's GitHub key before applying the
SSH configuration:

```sh
~/.local/bin/mise run tools:install
gh auth login --hostname github.com --git-protocol ssh --skip-ssh-key
gh auth refresh --hostname github.com --scopes admin:public_key,admin:ssh_signing_key
~/.local/bin/mise run setup:github-key
```

Open a new terminal and apply the configuration:

```sh
cd ~/src/github.com/civitaspo/dotfiles
~/.local/bin/mise run reconcile
```

`bootstrap.sh` only installs a pinned, verified mise. `mise run bootstrap`
installs pinned, signed Determinate Nix and Homebrew packages. `mise run
reconcile` is the only apply step: nix-darwin, Homebrew, then locked mise
tools.

Private MCP servers are installed from the private configuration during
`mise run switch`. If a client CLI was unavailable during setup, install it
and run `mise run mcp:sync` to register the servers later.

If App Store apps fail until they have been acquired on this Apple ID, Get
them once in the App Store and rerun `mise run brew`. Other failed steps are
idempotent; rerun the task that stopped. Keynote, Numbers, and Pages use
the universal App Store IDs; the classic Mac IDs were delisted in April
2026 and cannot be installed by mas.

`mise run brew` and `mise run update:brew` accept the Xcode license before
running Homebrew and after installing or upgrading App Store apps. They
request sudo only when the installed Xcode license has not been accepted.
To fix an existing installation directly, run `mise run setup:xcode`.

Rosetta is required because the committed `mise.lock` entries for dust and
procs use x86_64 assets on macOS arm64.

## Agent CLI authentication

Cursor Agent is an exception to mise-managed CLIs: Homebrew's `cursor-cli`
cask publishes the archive SHA-256 before download and verifies it during
installation. Install and update it with `mise run brew` / `mise run update:brew`.
The `~/bin/cursor-agent` wrapper exposes only this CLI without adding Homebrew
to PATH. Use `cursor-agent` to launch it and Homebrew to update it.

```sh
mise run auth:cursor
mise run auth:opencode
```

For OpenCode v2, choose **ChatGPT Pro/Plus (browser)** or **ChatGPT Pro/Plus
(headless)** and sign in with the account used for Codex. OpenCode supports
this OAuth flow natively; no additional plugin or API key is needed.
Check the saved connection with `opencode2 auth list`, then choose an OpenAI
model with `/models` inside OpenCode.

OpenCode stores its own OAuth credentials in its local SQLite database;
it does not need a copy of Codex's `auth.json` in either dotfiles repository.
A saved account takes precedence over `OPENAI_API_KEY`. See the
[provider account documentation](https://opencode.ai/v2/docs/cli/providers).

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

`mise run tools` (also part of `reconcile`) reinstalls configured tools whose
installation directories contain no files, even when mise reports them as
installed. Healthy installations and unused versions are left alone. An empty
installation after repair fails the task. This checks for missing contents;
it does not verify every installed file's checksum or runtime behavior.

## Herdr

mise installs [Herdr](https://herdr.dev/) and, in the tool's `postinstall`,
its plugins. Herdr has no plugin update command, so plugins are refreshed
whenever a new Herdr version is installed (force it with
`mise install -f aqua:herdrdev/herdr`). The prefix is `ctrl+t`
(`config/herdr/config.toml`).

[Herdr GPUI](https://github.com/penso/herdr-gpui) attaches to that daemon as a
native window. `mise run brew` installs the signed cask from `penso/tap`
(`Herdr.app`). The cask requires macOS Sequoia or newer.

Layout and navigation (Emacs-style pane motion: `b`/`p`/`n`/`f`):

| Key | Action |
| --- | --- |
| `prefix+t` | new tab |
| `prefix+\|` | split right |
| `prefix+-` | split down |
| `prefix+ctrl+b` / `+p` / `+n` / `+f` | focus pane left / up / down / right |
| `prefix+shift+b` / `+p` / `+n` / `+f` | swap pane left / up / down / right |
| `prefix+ctrl+r` | rename tab |
| `prefix+ctrl+x` | close tab |
| `prefix+ctrl+w` | new workspace |
| `prefix+ctrl+d` | close workspace |

[terminal-browser](https://github.com/zenbu-labs/terminal-browser) is
installed by its Herdr plugin via the official installer into
`~/.local/share/terminal-browser`, with a launcher at
`~/.local/bin/terminal-browser`. The Herdr plugin opens it in a right split
(`prefix+u`).

[Herdr Annotate](https://github.com/plannotator/herdr-annotate) is the
full install (terminal comments plus Plannotator TUI document review):

| Key | Action |
| --- | --- |
| `prefix+a` | comment on the selected text |
| `prefix+shift+a` | copy annotations as Markdown |
| `prefix+m` | manage annotations |
| `prefix+o` | review documents in this folder |
| `prefix+shift+o` | review the agent's last reply |

[herdr-linear-agent](https://github.com/civitaspo/herdr-linear-agent) runs
coding agents for Linear issues delegated to its app user. The Herdr
postinstall pins it to `v0.7.0`. Its build step
downloads the release binary named by the repository's `.release-version`.
Its config and agent profiles come from dotfiles-private
(`config/herdr-linear-agent/`), linked into `~/.config/herdr-linear-agent/`.
`config/opencode/opencode.json` defines the `herdr-linear-agent-coordinator`
agent, which denies subagents, for coordinators that run on OpenCode.

[herdr-infobox](https://github.com/civitaspo/herdr-infobox) shows a session's
repositories, diffs, references, and plans. Press `ctrl+t`, then `i` to open
or close Info (Herdr action **Toggle Info**). Inside Info, `s` selects a
session, `Tab` switches sections, `Enter` opens details, and `d` shows changed
files. Press `p` to resume following the current tab's agent session. It
has no release binary yet, so its build step compiles it with the mise Rust
toolchain. Provider hooks are not installed; see its installation guide.

Kitty graphics is enabled so terminal-browser can render inside Herdr.
The first launch of terminal-browser may prompt for Accessibility /
Input Monitoring; grant those in System Settings. The app is notarized,
but GNU tar (from nix-darwin) extracts its tarball's AppleDouble entries as
`._*` files, breaking the code seal so Gatekeeper reports it as "damaged".
The Herdr `postinstall` puts `/usr/bin` first on `PATH` so the installer
uses macOS tar instead.

## Codex + Plannotator

`mise run tools` installs [Plannotator](https://plannotator.ai/) and configures
its Codex `Stop` hook in `$CODEX_HOME` or `~/.codex`. The setup enables Codex's
hooks feature (`[features] hooks = true`) and merges an absolute mise shim
path into the existing `hooks.json`, so existing Codex hooks remain in place.
Restart Codex Desktop after the first setup.

Locked Codex is 0.153.4 or newer. That release accepts nested `[features.*]`
tables such as `[features.context_management] experimental_mode = true`.
0.152 treated every `[features]` value as a boolean and refused to start
with `invalid type: map, expected a boolean`.

Plan review opens automatically when Codex finishes a plan. Code review and
document annotation are available from a Codex prompt:

```text
!plannotator review
!plannotator annotate path/to/file.md
!plannotator last
```

The public repository does not manage Codex session state or the shared private
skill trees (`~/.agents/skills`, flattened `~/.claude/skills/<name>`, and the
Snowflake catalog in `~/.agents/snowflake-skills`);
the commands above do not require installing those skills.

## After the first reconcile

These are manual and are not part of `mise run reconcile`:

- grant Accessibility / Input Monitoring / Screen Recording to Karabiner,
  Hammerspoon, Space Rabbit, Homerow, Keyboard Maestro, CleanShot, and
  terminal-browser
- sign into paid apps (CleanShot, Keyboard Maestro, Mimestream, and others)
- verify Git commit and tag signing with this Mac's Secure Enclave key
- `op signin`, `gh auth`, `gcloud auth`, AWS SSO, SnowSQL, and Atuin
- Cursor, Claude Code, and Codex sign-in

home-manager moves conflicting files aside with a `.backup` suffix.
Activation disables Spotlight indexing. `mise run brew` uses
`brew bundle --force-cleanup`, so packages not listed in the Brewfile are
removed. Local tap casks (Kanary, Nospace, OpenIn, Reflect Open) are
pinned and self-update in-app; `brew upgrade` skips them.

## Set up GitHub authentication and Git signing

Run `mise run setup:github-key` explicitly on each Mac. The task creates a
non-exportable P-256 key in Secure Enclave with label `dotfiles-github` and
registers its public key with the `civitaspo` GitHub account for authentication
and signing. It is not part of `reconcile`.

The key uses `sc_auth` protection `none`, so signing and SSH authentication
do not request Touch ID. Processes running as your macOS user can use it
without an approval prompt. The secret key stays in Secure Enclave;
`~/.ssh/id_github_secure_enclave` is its local reference file. Keep that file
and its `.pub` companion outside this repository. Generate a separate key
on each Mac rather than copying these files between machines.

For an existing installation, register the key before `mise run switch`.
The task requires `gh` to be signed into `civitaspo` with `admin:public_key`
and `admin:ssh_signing_key` scopes. If needed, run:

```sh
gh auth refresh --hostname github.com --scopes admin:public_key,admin:ssh_signing_key
mise run setup:github-key
mise run switch
ssh -T git@github.com
```

GitHub's successful SSH test prints `Hi civitaspo!` and exits with status 1
because it does not provide shell access. A new signed commit pushed to
GitHub must display `Verified`. Git and annotated tags use `~/bin/ssh-sign`,
which selects Apple's SSH keychain provider. GitHub connects through
`ssh.github.com:443` using the dedicated key. Other SSH hosts retain their
existing configuration and 1Password agent.

Rerun the task after an interruption. It reuses the identity and key files
and registers only missing GitHub entries. If it finds duplicate identities,
partial key files, or a mismatch, it stops without replacing them. Inspect
`sc_auth list-ctk-identities` and the reported fingerprints before repairing
the local state. Preserve the old 1Password keys and GitHub registrations
until the replacement is verified. To roll back, restore the previous Git
and SSH configuration and run `mise run switch`; do not delete either key.

This setup follows [mizdra's Secure Enclave guide](https://www.mizdra.net/entry/2026/08/07/101542).

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
