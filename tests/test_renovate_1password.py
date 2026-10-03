"""Check that Renovate can bump both URL versions in either order."""

import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
manager = json.loads((root / "renovate.json").read_text())["customManagers"][0]
directory, archive = [
    re.compile(pattern.replace("(?<currentValue>", "(?P<currentValue>"))
    for pattern in manager["matchStrings"][2:]
]

for patterns in ((directory, archive), (archive, directory)):
    url = "https://cache.agilebits.com/dist/1P/op2/pkg/v2.39.0/op_darwin_arm64_v2.39.0.zip"
    for version in ("2.40.0", "2.41.0"):
        for pattern in patterns:
            match = pattern.search(url)
            assert match is not None, url
            start, end = match.span("currentValue")
            url = url[:start] + version + url[end:]
        assert url == (
            f"https://cache.agilebits.com/dist/1P/op2/pkg/v{version}/"
            f"op_darwin_arm64_v{version}.zip"
        ), url

print("1password Renovate checks passed")
