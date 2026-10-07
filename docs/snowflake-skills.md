# mise-managed Snowflake skills

Public dotfiles manages CoCo CLI with `http:coco` in `config/mise/config.toml`.
The official macOS arm64 archive contains both `cortex` and `bundled_skills/`.
mise retains the full archive payload. The CLI does not need to run for agents
to read these skills, and Nix does not download or extract the catalog.

The small private Snowflake router resolves the global installation using
`mise -C "$HOME" where http:coco`, then reads its `bundled_skills/` directory.
It must first read its adjacent `HOST_ADAPTATION.md`. Host mappings remain
private and work in both the nested and flattened skill layouts. Missing
installation, catalog, or guide stops catalog use; the router does not install
or launch CoCo implicitly. Direct-connection helpers are not automatically
portable to other agent runtimes.

Codex, Cursor, and OpenCode discover the nested router in `~/.agents/skills`;
Claude Code gets the same router at `~/.claude/skills/snowflake`.
OpenCode supports recursive compatibility-root discovery without extra paths:
<https://opencode.ai/v2/docs/skills#discovery>.

`latest` resolves from the official distribution's `stable_version.txt`;
`config/mise/mise.lock` records the selected version, URL, and archive checksum.
After activating the configuration, update only this tool with:

```sh
mise lock --global --bump http:coco --platform macos-arm64
mise install http:coco
```

When editing the repository configuration instead, run these commands from
`config/mise` and omit `--global`. Commit the updated lockfile. Checksums are resolved automatically from the selected release's official
`manifest.json` through `checksum_url` and `checksum_expr`. Review
changes to tool contracts or catalog layout. There are no per-file patches
to rebase. Update the private guide only when host translations need to change.

Official installer: <https://ai.snowflake.com/static/cc-scripts/install.sh>

home-manager removes the previous managed `~/.agents/snowflake-skills`
link during activation; the router uses mise directly.

Keep upstream skill assets and dependency manifests out of Git. Their presence
in a local mise installation does not create Dependabot entries in either
repository; other vendored skills are unchanged.
