# Configure project tooling

Use `mise.toml` to pin the project's tool versions and define tasks. Generate and commit `mise.lock` for the platforms the project supports. Use the aqua backend when a usable package exists, and use prebuilt binaries. Add the language runtime and project-specific formatters, linters, and tests only where needed.

Install these GitHub Actions tools through mise, using reviewed versions available at setup time:

- `aqua:jdx/jactionlint` checks workflow syntax, expressions, and Actions-specific errors.
- `aqua:suzuki-shunsuke/pinact` pins actions and reusable workflows to commit SHAs.
- `aqua:suzuki-shunsuke/ghalint` checks GitHub Actions security policies.
- `aqua:suzuki-shunsuke/disable-checkout-persist-credentials` updates checkout steps to disable persisted credentials.

Define a read-only `lint` task that runs `jactionlint`, `pinact run --check`, and `ghalint run`, plus format checks and project-specific linters. If the repository has composite actions, also check them with `ghalint run-action`. Define a `securefix` task for commands that modify files, including `pinact run`, `disable-checkout-persist-credentials`, and applicable formatters. The credential tool edits workflows; do not run it in check-only CI. Keep intentional exceptions narrow and explain their reason, especially for CSM's generated callers.

Define a `test` task for the project's tests. Run `mise run lint` and `mise run test` locally and in pull request CI. The required `status-check` must reflect failures from both tasks. Document the commands in the README and `AGENTS.md` so contributors and agents use the same checks.
