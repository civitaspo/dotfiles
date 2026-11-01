# Configure project tooling

Use `mise.toml` to pin the project's tool versions and define tasks. Generate and commit `mise.lock` for the platforms the project supports. Use the aqua backend when a usable package exists, and prefer prebuilt binaries. Add the language runtime and project-specific formatters, linters, and tests only where needed.

Install these GitHub Actions tools through mise, using reviewed versions available at setup time:

- `aqua:jdx/jactionlint` checks workflow syntax, expressions, and Actions-specific errors.
- `aqua:suzuki-shunsuke/pinact` pins actions and reusable workflows to commit SHAs.
- `aqua:suzuki-shunsuke/ghalint` checks GitHub Actions security policies.
- `aqua:suzuki-shunsuke/disable-checkout-persist-credentials` updates checkout steps to disable persisted credentials.
- `aqua:koalaman/shellcheck` checks shell scripts, including workflow `run` steps via jactionlint.
- `aqua:ast-grep/ast-grep` checks source code against structural rules without a Python runtime.

Configure `sgconfig.yml` and commit relevant ast-grep rules for the project's languages and security risks. Set blocking rules to `severity: error` and test the rules against matching and nonmatching examples with `ast-grep test`. ast-grep runs configured rules; do not assume it supplies Semgrep's rules or equivalent security coverage by default.

Define a read-only `lint` task that runs `jactionlint --shellcheck=shellcheck`, `pinact run --check`, `ghalint run`, and `ast-grep scan`, plus format checks and project-specific linters. Run ShellCheck on standalone shell scripts as well. If the repository has composite actions, also check them with `ghalint run-action`. Define a `fix` task for commands that modify files, including `pinact run`, `disable-checkout-persist-credentials`, and applicable formatters. Review ast-grep rewrites before enabling them in `fix`. Keep intentional exceptions narrow and explain their reason, especially for CSM's generated callers.

Define a `test` task for the project's tests. Run `mise run lint` and `mise run test` locally and in pull request CI. The required `status-check` must reflect failures from both tasks. Document `mise run lint`, `mise run fix`, and `mise run test` in the README and `AGENTS.md` so contributors and agents use the same commands.
