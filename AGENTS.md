# AGENTS.md

Guidance for AI coding agents working in this repository.

## What this repository is

civitaspo's macOS configuration. Responsibilities are split across four tools:

- **nix-darwin** (`nix/darwin.nix`) -- macOS system settings only.
- **Homebrew** (`Brewfile`) -- GUI apps, App Store apps, base packages.
- **mise** (`config/mise/config.toml`) -- CLI binaries and language runtimes.
- **Task** (`Taskfile.yml`) -- setup, update and reconcile workflows.

`config/` is symlinked into `~/.config` and `home/` into `$HOME` by
`task reconcile`. `init.sh` bootstraps a fresh machine.

## Conventions

- Always end files with a trailing newline.
- Code, comments, commit messages and pull requests are written in English.
- Use semantic commit messages (`feat(scope): ...`, `fix(scope): ...`).
- After editing any `*.nix` file, run `task check` (`nix flake check`).
- Prefer mise for binaries; do not add packages to Nix or commit binaries.

## Boundaries

This is a **public** repository. Never commit anything tied to an employer or
other private context. Such configuration belongs in the private repository
`civitaspo/dotfiles-private`, which supplies `~/.aws/config`,
`~/.ssh/config.d/`, `~/.snowsql/config`, `~/.claude/` and `~/.codex/`.
