#!/usr/bin/env bash
# Build and test the Keycap package, optionally clean.
# Usage: bash scripts/build.sh [--clean]
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
clean=0
for argument in "$@"; do
  case "$argument" in
    --clean) clean=1 ;;
    -h|--help) printf '%s\n' 'Usage: bash scripts/build.sh [--clean]'; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$argument" >&2; exit 2 ;;
  esac
done

if ((clean)); then swift package --package-path "$ROOT" clean; fi
swift test --package-path "$ROOT"
swift build --package-path "$ROOT" -c release
