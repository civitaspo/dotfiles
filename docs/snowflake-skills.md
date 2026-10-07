# Generated Snowflake skills

`nix/snowflake-skills.nix` downloads a pinned official Cortex Code CLI archive
and extracts only `bundled_skills/`. The CLI is not installed or executed.
home-manager links the generated catalog to `~/.agents/snowflake-skills`.
The private repository keeps the small Snowflake router and host adaptation
files, not the catalog.

Host customizations come from the private input's `snowflake-skills/`:
`catalog.patch`, a single-line `notice.md`, and `CURSOR_ADAPTATION.md`.
The generic shell adapter inserts the notice after Markdown frontmatter.
Keep organization-specific tool names and instructions in those private files.
The trial lockfile pins the companion private branch. After adopting both
PRs, refresh the private input from its default branch.
The original Python helpers and dependency manifests remain in the generated
catalog. Helpers requiring a direct connection retain that requirement.

Build without activation:

```sh
nix build .#snowflake-skills --no-link --print-out-paths
```

To update, read the official installer's current distribution prefix and its
`stable_version.txt`, then read that version's `manifest.json`. Update `version`
and the Linux amd64 archive's SHA-256 in `nix/snowflake-skills.nix`. The Linux
archive is used as a platform-independent source of skill assets.

Official installer: <https://ai.snowflake.com/static/cc-scripts/install.sh>

Run `mise run check`. Patch application uses zero fuzz and fails the build
when a hunk no longer applies; review the new upstream instructions and update
the patch before adopting a new version. Review offsets reported by `patch`
as well.

Keep upstream manifests out of Git: committing the generated catalog would
make those helper dependencies visible to Dependabot again. This removes
Dependabot entries for this catalog only; other vendored skills are unchanged.
