Status: done

# Test review r2 - issue #13 CI workflow

VERDICT: NO BLOCKING ISSUES

## Earlier findings
| ID | Status |
|----|--------|
| T1-I1 | Deferred - reason accepted. The spec lists the ci.yml job's steps (checkout, Python, install-godot.sh, check.sh) and the one CLAUDE.md line exactly, so a step that runs tools/tests is a spec decision. The reason is stated and names a concrete follow-up (wire test_ci_workflow.py + test_loop_docs.py into CI, list `python3 -m unittest discover -s tools/tests` in CLAUDE.md). It goes to tech debt; not raised again. |
| T1-m1..m4 | Logged (Minor), unchanged. |

## Change since r1
`git diff --stat c0e9fa8 91f321d` touches only `.loop/issue-13/*`. No code or test changed.

## Criterion -> test map (unchanged from r1)
| # | Criterion | Tests | Verdict |
|---|-----------|-------|---------|
| 1 | check.sh exits 0, names all four steps | test_check_sh.py CheckPassesOnHead.test_exits_zero_and_names_every_step | covered |
| 2 | check.sh exits non-zero and names the failing step | test_check_sh.py CheckFailsAndNamesStep (lint, GUT) | covered |
| 3 | ci.yml YAML, triggers, job, steps, cache, no continue-on-error | test_ci_workflow.py (5 tests) | covered (cache path loose, T1-m3) |
| 4 | [manual] `checks` green on the PR | - | check run `checks` on 91f321d: completed/success (REST check-runs API) |
| 5 | CLAUDE.md lists check.sh; Step 10 waits for green `checks` | test_loop_docs.py (2 tests) | covered (one vacuous assert, T1-m2) |

## TDD
- r1 checked ecc68ac and b53ce03. This round: fcc4974 [red] crit 1 -> `AssertionError: 1 != 0 : check.sh: not implemented` (fails on the assertion, check.sh is a stub that exits 1).

## Critical
None.

## Important
None.

## Minor
None new.

## What I ran (own worktree in scratchpad, removed afterwards)
- fcc4974: `python3 -m unittest tools.tests.test_check_sh` -> 1 failure on assertion.
- 91f321d (head): `tools/check.sh` -> exit 0; import/lint/format/test named; GUT 33/33 passing; "all checks passed".
- 91f321d: `python3 -m unittest discover -s tools/tests -v` -> 10/10 OK (23.2 s); worktree clean afterwards, no leftover /tmp/check-sh-* dirs.
- `gh api .../commits/91f321d/check-runs` -> `checks completed success`.
