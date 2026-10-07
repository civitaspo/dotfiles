# Generated Snowflake skills

`nix/snowflake-skills.nix` downloads a pinned official Cortex Code CLI archive
and extracts only `bundled_skills/`. The CLI is not installed or executed.
home-manager links the generated catalog to `~/.agents/snowflake-skills`.
Upstream files are preserved without patches or injected notices.

The private repository keeps the small Snowflake router and shared
`snowflake-skills/HOST_ADAPTATION.md` guide, not the catalog. The build copies
that guide into the catalog root. The router requires agents to read it before
loading any upstream entrypoint, including in later sessions and after updates.
Codex, Cursor, and OpenCode discover the nested router in `~/.agents/skills`;
Claude Code gets the same router at `~/.claude/skills/snowflake`.
OpenCode supports recursive `SKILL.md` discovery in its compatibility roots
without an additional skill path configuration:
<https://opencode.ai/v2/docs/skills#discovery>.
`HOST_ADAPTATION.md` is an ordinary shared document, loaded by the router's
instructions rather than automatically by any client.
Keep organization-specific tool names and instructions in the private guide.
This relies on agents following the router and guide; it does not rewrite or
make upstream helpers compatible with the host. CoCo-only tools and helpers
requiring direct connections may be unavailable.

The trial lockfile pins the companion private branch. After adopting both
PRs, refresh the private input from its default branch before deleting that branch.

Build without activation:

```sh
nix build .#snowflake-skills --no-link --print-out-paths
```

Ordinary installations use the pinned version and hash. To update deliberately,
read the official installer's current distribution prefix and its
`stable_version.txt`, then read that version's `manifest.json`. Update `version`
and the Linux amd64 archive's SHA-256 in `nix/snowflake-skills.nix`. The Linux
archive is used as a platform-independent source of skill assets.

Official installer: <https://ai.snowflake.com/static/cc-scripts/install.sh>

Run `mise run check` and review upstream release notes for changes to tool
contracts or catalog layout. Update the shared private guide only when those
contracts change. There are no patch hunks to rebase on each release; build
checks validate extraction and configuration, not every upstream workflow.

Keep upstream manifests out of Git: committing the generated catalog would
make those helper dependencies visible to Dependabot again. This removes
Dependabot entries for this catalog only; other vendored skills are unchanged.
