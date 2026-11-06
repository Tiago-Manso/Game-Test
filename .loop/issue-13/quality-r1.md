Status: done

# Quality review - issue #13 CI workflow, round 1 (PR #22, head c0e9fa8)

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
- [Q1-m1] general - The Python suite in tools/tests/ (which guards ci.yml, check.sh and the loop docs) is run by neither tools/check.sh nor the CI workflow, and CLAUDE.md "Commands" doesn't mention it. A later edit to ci.yml or SKILL.md can break these tests without anyone noticing. Suggest a CI step (or a check.sh step) running `python3 -m unittest tools.tests.test_ci_workflow tools.tests.test_loop_docs`. Leave test_check_sh out: it runs check.sh, so including it would recurse. Also list the command in CLAUDE.md. This is Minor because the spec doesn't require it.
- [Q1-m2] .github/workflows/ci.yml:14 - The `checks` job has no `timeout-minutes`. If Godot or GUT hangs (e.g. a test that never lets `-gexit` fire), the run sits there until GitHub's 6 h default, and Step 10 now waits for that run. Suggest `timeout-minutes: 20`.
- [Q1-m3] tools/check.sh:20 - The import step can't fail on a broken resource. I tried a scene whose ext_resource points to a missing script: `godot --headless --path . --import` printed no error and exited 0. CLAUDE.md says import "catches broken resources", but that's not true for this case. This is pre-existing behaviour of the CLAUDE.md command and outside this spec, so it should be a follow-up issue, e.g. a step that loads every .tscn/.tres headless and fails on errors.

## What I ran
- gdlint scenes scripts test: Success, no problems
- gdformat --check scenes scripts test: 7 files unchanged
- git ls-files -s tools/: check.sh and install-godot.sh are mode 100755
- Own worktree at HEAD: `python3 -m unittest discover -s tools/tests` -> 10/10 OK (includes check.sh exit 0 on head plus the lint and GUT failure cases)
- Own worktree, unformatted script: tools/check.sh -> "step 'format' failed", exit 1, stopped before test
- Own worktree, broken scenes/broken/broken.tscn (missing script ext_resource): `godot --headless --path . --import` -> exit 0, no error output (Q1-m3)
- Read ci.yml against install-godot.sh: PATH step comes before the cache restore and install, so a cached ~/.local/bin/godot is detected; setup-python puts pip-installed gdlint on PATH. Order and keys are correct.
- actionlint/shellcheck: not installed
