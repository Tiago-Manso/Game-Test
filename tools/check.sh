#!/usr/bin/env bash
# Run every check from CLAUDE.md, in order, stopping at the first failure:
# import, lint, format check, GUT tests. Exits non-zero and names the failing
# step; exits 0 when all pass. Used locally and by CI (.github/workflows/ci.yml).
# Assumes Godot and gdtoolkit are installed (tools/install-godot.sh).
set -uo pipefail

cd "$(dirname "$0")/.."

run_step() {
  local name="$1"
  shift
  echo "==> $name: $*"
  if ! "$@"; then
    echo "check.sh: step '$name' failed" >&2
    exit 1
  fi
}

run_step import godot --headless --path . --import
run_step lint gdlint scenes scripts test
run_step format gdformat --check scenes scripts test
run_step test godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit

echo "check.sh: all checks passed"
