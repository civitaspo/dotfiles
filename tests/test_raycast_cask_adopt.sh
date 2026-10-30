#!/usr/bin/env bash
# CI integration test for the reversible Raycast Homebrew-to-mise handoff.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash "$root/tests/test_cask_migration.sh" raycast
