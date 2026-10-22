"""The 1Password lock entry must move its checksum with its version."""

import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
renovate = json.loads((root / "renovate.json").read_text())
managers = renovate["customManagers"]
assert len(managers) == 2

config_text = (root / "config/mise/config.toml").read_text()
lock_text = (root / "config/mise/mise.lock").read_text()

config_pattern = re.compile(
    managers[0]["matchStrings"][0].replace("(?<currentValue>", "(?P<currentValue>")
)
config_match = config_pattern.search(config_text)
assert config_match is not None, "config pin not found"
config_version = config_match.group("currentValue")

lock_pattern = re.compile(
    managers[1]["matchStrings"][0]
    .replace("(?<currentValue>", "(?P<currentValue>")
    .replace("(?<currentDigest>", "(?P<currentDigest>")
)
lock_match = lock_pattern.search(lock_text)
assert lock_match is not None, "lock entry not found"
assert lock_match.group("currentValue") == config_version
digest = lock_match.group("currentDigest")
assert re.fullmatch(r"[a-f0-9]{64}", digest)

rendered = (
    managers[1]["autoReplaceStringTemplate"]
    .replace("{{{newValue}}}", "9.9.9")
    .replace("{{{newDigest}}}", "ab" * 32)
)
assert rendered == (
    '[[tools."aqua:1password/cli"]]\n'
    'version = "9.9.9"\n'
    'backend = "aqua:1password/cli"\n'
    "\n"
    '[tools."aqua:1password/cli"."platforms.macos-arm64"]\n'
    f'checksum = "sha256:{"ab" * 32}"\n'
    "url = "
    '"https://cache.agilebits.com/dist/1P/op2/pkg/v9.9.9/'
    'op_darwin_arm64_v9.9.9.zip"'
)
assert lock_pattern.search(rendered)

transform = renovate["customDatasources"]["1password-cli"]["transformTemplates"][0]
assert '"digest": sha256' in transform

# A rewritten entry must still match, so the next bump can see the new digest.
bumped = lock_text.replace(lock_match.group(0), rendered)
assert lock_pattern.search(bumped)

print("1password Renovate checks passed")
