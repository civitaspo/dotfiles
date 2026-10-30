#!/usr/bin/env bash
set -euo pipefail

"$MISE" bootstrap macos defaults apply --yes

# Compare actual property-list values and types with the configuration.
"$MISE" exec python -- python - <<'PY'
import plistlib
import subprocess
import tomllib

with open("mise.toml", "rb") as f:
    config = tomllib.load(f)["bootstrap"]["macos"]

domains = config["defaults"].copy()
trackpad = {"Clicking": True, "TrackpadThreeFingerDrag": True}
domains["com.apple.AppleMultitouchTrackpad"] = trackpad
domains["com.apple.driver.AppleBluetoothMultitouch.trackpad"] = trackpad

for domain, expected in domains.items():
    result = subprocess.run(
        ["/usr/bin/defaults", "export", domain, "-"],
        check=True,
        stdout=subprocess.PIPE,
    )
    actual = plistlib.loads(result.stdout)
    for key, value in expected.items():
        found = actual.get(key)
        assert type(found) is type(value) and found == value, (domain, key, value, found)

print("ok - macOS defaults match the declared values and types")
PY

"$MISE" bootstrap macos defaults apply --yes
