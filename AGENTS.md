# AGENTS.md

Guidance for AI coding agents working in this repository.

## What this repository is

civitaspo's macOS configuration. Responsibilities are split across four tools:

- **nix-darwin** (`nix/darwin.nix`) -- macOS system settings and base CLI packages.
- **home-manager** (`nix/home.nix`) -- symlinks dotfiles into `$HOME`.
- **Homebrew** (`Brewfile`) -- GUI apps and App Store apps. Not on `$PATH`; only `mise run brew` and friends invoke it (via `/opt/homebrew/bin/brew`).
- **mise** (`config/mise/config.toml`, `mise.toml`, `mise-tasks/`) -- CLI binaries, language runtimes, and repository task orchestration.

Dotfiles are plain files under `config/` (-> `~/.config`) and `home/`
(-> `$HOME`); home-manager symlinks them. `bootstrap.sh` installs a pinned
mise; `mise run bootstrap` installs Nix and Homebrew.

## Conventions

- Always end files with a trailing newline.
- Code, comments, commit messages and pull requests are written in English.
- Use semantic commit messages (`feat(scope): ...`, `fix(scope): ...`).
- After editing any `*.nix` file, run `mise run check` (`nix flake check`).
- Prefer mise for binaries; do not add packages to Nix or commit binaries.
- Keep `mise.toml` declarative; use a file task for defensive shell logic
  (e.g. `brew:tap`).

## Git workflow

- Before creating a feature branch or worktree, run `git fetch origin main`.
- Base new feature branches and worktrees on `origin/main`, not a stale local
  `main`.
- After creating or entering a feature worktree, confirm it is based on the
  latest `origin/main`; if the worktree is clean and `origin/main` moved,
  rebase onto it before editing.
- Before opening a pull request, fetch `origin main` again and rebase the
  feature branch onto the latest `origin/main` when the worktree is clean.
- Never discard or overwrite user changes while updating from `main`; if the
  worktree is dirty, stop and ask how to proceed.

## Boundaries

This is a **public** repository. Never commit anything tied to an employer or
other private context. Such configuration belongs in the private repository
`civitaspo/dotfiles-private`, which supplies `~/.aws/config`,
`~/.ssh/config.d/`, `~/.snowsql/config`, and `~/.agents/skills/`.
