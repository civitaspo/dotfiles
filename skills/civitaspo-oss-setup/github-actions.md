# GitHub Actions architecture

At setup, write `docs/github-actions.md` in the new repository, adapted from the requirements below to its actual workflows. Add an explicit instruction to the root `AGENTS.md`: before creating or changing GitHub Actions workflows, composite actions, CI scripts, or CI configuration, read and follow `docs/github-actions.md`. Keep the document current when the architecture changes. Do not include this skill's research history or unrelated example repositories in the new repository.

The rules below govern project-owned CI, including the Securefix job. The csm-ci server distributes and owns its caller workflows: follow its deployed documentation, preserve the generated files, and do not hand-edit or restructure them. When a generated caller needs an update, use the server's managed-file distribution. Verify it against the server's requirements independently of project-owned CI.

## PR workflow and required check

- Use one project-owned `pull_request` entry workflow without workflow-level path or branch filters that can leave its required check pending. Run it for changes to every PR, including updates and reopening. A required check name must be unique across workflows. If a merge queue is enabled, also run the required checks on `merge_group`.
- The entry workflow calls a local `workflow_call` checks workflow as a single job. Put every PR validation job, including lint, tests, and Securefix when enabled, inside that called workflow; use additional focused reusable workflows when useful. The entry workflow contains the call and its `status-check` gate, not a separate list of every validation job. Keep the required gate outside the called workflow.
- The `status-check` job depends on that one call, runs with `if: always()`, and succeeds only when the call result is `success`. Failure, cancellation, or an unexpectedly skipped call must not become a passing check. For example:

  ```yaml
  jobs:
    checks:
      uses: ./.github/workflows/workflow_call_pr.yml
      # Grant only the permissions and explicit secrets the called workflow needs.

    status-check:
      needs: checks
      if: ${{ always() }}
      runs-on: ubuntu-latest
      timeout-minutes: 5
      permissions: {}
      steps:
        - name: Require successful checks
          env:
            RESULT: ${{ needs.checks.result }}
          run: test "$RESULT" = success
  ```

- Configure the server-managed ruleset to require the unique `status-check` and server policy checks. Do not give another workflow the same required check name. If filtering is needed, run the entry and gate on every PR and skip only explicitly inapplicable jobs inside the called workflow; make unexpected skips fail. An `edited` event may skip expensive jobs only when it cannot cancel or substitute for the full run for the current head. Use separate concurrency groups where needed.
- Run `mise run lint` and `mise run test` as checks on the PR head. Preserve their results even if Securefix changes files; a fix request is not a passing lint result. For default-branch checks, use a separate push entry and reusable workflow as needed; it must not share the PR's required check name or submit Securefix requests.
- Exercise successful, failed, cancelled, intentionally skipped, and retried checks on a real PR before relying on branch protection. Confirm that adding a failing job inside the called workflow prevents the outer gate from passing and that a later commit reruns the full checks.

## Security and maintenance

- Start with workflow-level `permissions: {}`; grant each job only the token permissions it needs. Apply explicit minimal permissions and named secrets through every reusable-workflow call. Set a finite `timeout-minutes` on every runner job. Use concurrency to cancel obsolete runs without cancelling a distinct required run.
- Pin external actions and external reusable workflows to reviewed full commit SHAs. Local reusable workflows use relative paths from the same commit. Set `persist-credentials: false` for checkout; authenticate only the step that needs it. Keep secrets confined to the steps and workflows that require them. Avoid `secrets: inherit`.
- Treat PR titles, branch names, inputs, artifacts, caches, and checked-out PR code as untrusted. Pass untrusted values to shell through environment variables with proper quoting, not expression interpolation into scripts. Do not execute PR code with elevated credentials or in `pull_request_target`; do not let untrusted runs poison caches or artifacts later consumed by privileged runs. Follow GitHub's current fork and event security guidance.
- Integrate Securefix into the project-owned PR checks using the deployed csm-ci-actions Securefix guide: the job runs the local `fix` task, then the pinned client action requests server-side changes. Pass the client secret explicitly through the call chain only where needed. Follow the deployed action's fork behavior; never switch to `pull_request_target` to obtain secrets. Treat the job and the code it executes as a trust boundary, and restrict secret-bearing runs to trusted code and contributors. Test a same-repository fix and a fork PR.
- Run the configured `jactionlint`, ShellCheck, `pinact`, and `ghalint` checks in CI and locally. Use `fix` for supported automatic changes, review its diff, and preserve distributed csm-ci files. Protect workflow changes through the server's existing policy and rulesets.

Sources: [GitHub Actions Best Practice 2025](https://suzuki-shunsuke.github.io/slides/github-actions-best-practice-2025), [GitHub secure use reference](https://docs.github.com/en/actions/reference/security/secure-use), [reusing workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows), and [required status checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks).
