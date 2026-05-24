# AGENTS.md

Guidance for AI coding agents working in this repository.

## What this repository is

civitaspo's macOS configuration. Responsibilities are split across five tools:

- **nix-darwin** (`nix/darwin.nix`) -- macOS system settings and base CLI packages.
- **home-manager** (`nix/home.nix`) -- symlinks dotfiles into `$HOME`.
- **Homebrew** (`Brewfile`) -- GUI apps and App Store apps. Not on `$PATH`; only `task brew` and friends invoke it (each scopes `/opt/homebrew/bin` onto PATH locally).
- **mise** (`config/mise/config.toml`) -- CLI binaries and language runtimes.
- **Task** (`Taskfile.yml`) -- setup, update and reconcile workflows.

Dotfiles are plain files under `config/` (-> `~/.config`) and `home/`
(-> `$HOME`); home-manager symlinks them. `init.sh` bootstraps a fresh machine.

## Conventions

- Always end files with a trailing newline.
- Code, comments, commit messages and pull requests are written in English.
- Use semantic commit messages (`feat(scope): ...`, `fix(scope): ...`).
- After editing any `*.nix` file, run `task check` (`nix flake check`).
- Prefer mise for binaries; do not add packages to Nix or commit binaries.
- `Taskfile.yml` only orchestrates -- it must not contain shell logic.

## Boundaries

This is a **public** repository. Never commit anything tied to an employer or
other private context. Such configuration belongs in the private repository
`civitaspo/dotfiles-private`, which supplies `~/.aws/config`,
`~/.ssh/config.d/`, `~/.snowsql/config`, `~/.claude/` and `~/.codex/`.
