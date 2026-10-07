#!/usr/bin/env python3
"""Check that relative skill links resolve in both published layouts.

Codex and Cursor read the nested tree at ~/.agents/skills. Claude Code reads
each skill flattened to ~/.claude/skills/<name>. A relative Markdown link must
resolve in both, so it may only point inside its own skill or into a sibling
skill directory.
"""

import argparse
import os
import re
import sys
from pathlib import Path

LINK = re.compile(r"\]\(([^)\s]+)")
FENCE = re.compile(r"^\s*(```|~~~)")
CODE = re.compile(r"`[^`]*`")
FLAT = Path("/flat")


def skill_dirs(d):
    for p in sorted(d.iterdir()):
        if not p.is_dir():
            continue
        if (p / "SKILL.md").is_file():
            yield p
        else:
            yield from skill_dirs(p)


def links(md):
    fenced = False
    for n, line in enumerate(md.read_text(encoding="utf-8").splitlines(), 1):
        if FENCE.match(line):
            fenced = not fenced
            continue
        if fenced:
            continue
        for m in LINK.finditer(CODE.sub("", line)):
            target = m.group(1).split("#", 1)[0]
            # Skip URLs, absolute paths, and template placeholders like (url).
            if re.match(r"^([a-z][a-z0-9+.-]*:|/|~|\$)", target):
                continue
            if "/" in target or "." in target:
                yield n, target


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("skills_root", type=Path, help="Root of the nested skill tree")
    root = parser.parse_args().skills_root.resolve()
    if not root.is_dir():
        parser.error(f"skills root is not a directory: {root}")
    # Duplicate basenames are rejected by the Nix assert in public dotfiles.
    skills = {s.name: s for s in skill_dirs(root)}
    errors = []

    for name, s in skills.items():
        for md in sorted(s.rglob("*.md")):
            rel = md.parent.relative_to(s)
            for n, target in links(md):
                where = f"{md.relative_to(root)}:{n}: {target}"
                if not Path(os.path.normpath(md.parent / target)).exists():
                    errors.append(f"{where}: broken link")
                    continue
                flat = Path(os.path.normpath(FLAT / name / rel / target))
                parts = flat.relative_to(FLAT).parts if flat.is_relative_to(FLAT) else ()
                if not parts or parts[0] not in skills:
                    errors.append(f"{where}: leaves the skill tree when flattened for Claude Code")
                elif not skills[parts[0]].joinpath(*parts[1:]).exists():
                    errors.append(f"{where}: resolves differently when flattened for Claude Code")

    for e in errors:
        print(e, file=sys.stderr)
    print(f"checked {len(skills)} skills under {root}: {len(errors)} problem(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
