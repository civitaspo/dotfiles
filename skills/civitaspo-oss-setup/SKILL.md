---
name: civitaspo-oss-setup
description: Set up a new public civitaspo OSS repository with csm-ci-server, Renovate, protected branches, and optional releases. Use when bootstrapping a new civitaspo OSS repository.
---

# Set up a civitaspo OSS repository

Create a public repository under `civitaspo`, adapted to the project's actual language and needs. Write all repository text in English, including code, comments, documentation, commits, and PRs. Use Conventional Commit PR titles and signed commits.

The authoritative configuration is [`civitaspo/csm-ci-server`](https://github.com/civitaspo/csm-ci-server), especially its [`csm-ci.yaml`](https://github.com/civitaspo/csm-ci-server/blob/main/csm-ci.yaml). Before choosing workflow pins or applying settings, inspect the deployed server workflows and the documentation at the corresponding published `csm-ci-actions` revision. Do not assume features documented on an unreleased branch are deployed.

## Bootstrap

1. Create the public repository and its initial default branch. Repo-settings does not create repositories. If the repository is empty, use a minimal signed bootstrap commit; use PRs for subsequent changes.
2. Add only the foundation files the project needs, including an English README, license, `AGENTS.md`, project tooling, tests, and CI. Provide a PR workflow with the `status-check` required by the server. Pin GitHub Actions and reusable workflows to reviewed full commit SHAs.
3. Configure Renovate using [renovate.json5](renovate.json5) as the baseline. Adapt language-specific settings to the project. Renovate requests merges with `/merge`; it does not use GitHub platform automerge.
4. Enroll the repository and enable its client workflows using [enrollment.md](enrollment.md). Review and verify the caller workflows before activating the server-managed rulesets.
5. For releases, enable only the operations and build type the project needs. Follow the deployed version of the csm-ci-actions release and release-PR guides. Keep publishing and signing credentials on the server.
6. Verify a real PR: confirm `csm-ci/policy`, `status-check`, approval, and a merge request work for the current head. Confirm an eligible Renovate PR requests `/merge` and a major update does not. Verify the applied repository settings and rulesets.

## Pull requests

Use a feature branch and a PR for every change after bootstrap. A trusted operator reviews changes and uses an exact `/approve` comment when approval is needed, then `/merge` to request a squash merge. Automatic approval can also occur when the server's trust and policy checks pass. Do not treat `/approve` as a bypass for untrusted or unsigned commits. Check the deployed merge documentation for reservation and cancellation behavior.

Never weaken or remove rulesets to force a merge. If the server cannot operate, follow its documented break-glass procedure only with the repository owner's explicit authorization. Never include credentials in repository text or ask the user to paste secrets into chat.
