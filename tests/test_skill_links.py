"""Exercise nested and flattened skill links without private content."""

import subprocess
import sys
import tempfile
from pathlib import Path


def main():
    checker = Path(sys.argv[1]).resolve()
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        first = root / "category/first"
        second = root / "category/second"
        first.mkdir(parents=True)
        second.mkdir()
        (first / "guide.md").write_text("Guide\n")
        (second / "SKILL.md").write_text("Second skill\n")

        cases = [
            ("[own](guide.md) [sibling](../second/SKILL.md)\n", 0, "0 problem(s)"),
            ("[missing](missing.md)\n", 1, "broken link"),
            ("[category](../../category/second/SKILL.md)\n", 1, "leaves the skill tree"),
            ("[outside](../../outside.md)\n", 1, "leaves the skill tree"),
            ("`[example](missing.md)`\n```\n[example](missing.md)\n```\n", 0, "0 problem(s)"),
        ]
        (root / "outside.md").write_text("Outside\n")
        for markdown, expected_code, expected_message in cases:
            (first / "SKILL.md").write_text(markdown)
            result = subprocess.run(
                [sys.executable, str(checker), str(root)], capture_output=True, text=True
            )
            assert result.returncode == expected_code, result.stdout + result.stderr
            assert expected_message in result.stdout + result.stderr, result.stdout + result.stderr

        result = subprocess.run(
            [sys.executable, str(checker), str(root / "missing")], capture_output=True, text=True
        )
        assert result.returncode == 2, result.stderr
        assert "skills root is not a directory" in result.stderr, result.stderr
    print("skill link regression checks passed")


if __name__ == "__main__":
    main()
