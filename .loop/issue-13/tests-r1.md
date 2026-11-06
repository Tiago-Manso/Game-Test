Status: done

# Test review r1 - issue #13 CI workflow

VERDICT: BLOCKING ISSUES

## Criterion -> test map
| # | Criterion | Tests | Verdict |
|---|-----------|-------|---------|
| 1 | check.sh exits 0 on head, output names all four steps | test_check_sh.py CheckPassesOnHead.test_exits_zero_and_names_every_step | covered (order only indirectly, via criterion 2's "later steps not printed") |
| 2 | check.sh exits non-zero, names failing step | test_check_sh.py CheckFailsAndNamesStep.test_lint_error_fails_lint_step, test_failing_gut_test_fails_test_step (throwaway copy of the project in a temp dir, removed in tearDown) | covered; also checks it stops at the first failure |
| 3 | ci.yml valid YAML, triggers, job `checks`, steps, cache, no continue-on-error | test_ci_workflow.py (5 tests) | covered; cache-path check is loose (T1-m3) |
| 4 | [manual] `checks` green on the PR | - | orchestrator / PO |
| 5 | CLAUDE.md lists check.sh; Step 10 needs green `checks` | test_loop_docs.py (2 tests) | covered; one assertion vacuous (T1-m2) |

## TDD history
- fcc4974 [red] crit 1 (check.sh stub exit 1) -> 57950fe [green]
- crit 2: no red commit (af04ecc test-only, passed first run). 57950fe's failure branch was not required by crit 1's test (T1-m1). Implementer's mutation claim checked: confirmed.
- ecc68ac [red] crit 3 (placeholder ci.yml, so fails on assertions) -> 82b3768 [green]
- b53ce03 [red] crit 5 -> 23e6b87 [green]
- Red commits only contain tests + stubs. No tests weakened, skipped or deleted.

## Critical
None.

## Important
- [T1-I1] general - Nothing runs `tools/tests` automatically. check.sh runs exactly the four CLAUDE.md steps, ci.yml runs only check.sh, and CLAUDE.md Commands doesn't list `python3 -m unittest discover -s tools/tests` (the command is only in .loop/issue-13/implementer.md). So the loop's "run every check from CLAUDE.md" and CI never run these 10 tests. If someone adds `continue-on-error` to ci.yml or removes the Step 10 wait tomorrow, nothing catches it. This is the missing-coverage case in the reviewer guide: the tests exist but nothing runs them. Suggested fix: list the tools-tests command in CLAUDE.md Commands, and run at least test_ci_workflow.py and test_loop_docs.py from ci.yml (they are fast and don't recurse). test_check_sh.py can't run inside check.sh. This could be deferred, because the spec fixes check.sh at four steps, but it needs a stated reason and a follow-up issue.

## Minor
- [T1-m1] general - Criterion 2 has no [red] commit. In 57950fe, the `if ! "$@"; then ... exit 1` branch was written without a failing test that required it: with that branch removed, crit 1's test still passes (I verified this). The later tests do pin it now (mutation gives `AssertionError: 0 == 0` in both). This is a process deviation with evidence that the gap is closed. It might count as Important under "no production code without a test that demanded it", but history can't usefully be rewritten now, so I logged it as Minor.
- [T1-m2] tools/tests/test_loop_docs.py:33 - `assertRegex(merge, "(?i)implementer")` can never fail: Step 10 item 1 on main already says "the implementer fixes it". The `wait` and `succeeded` asserts also aren't tied to `checks`. Suggest asserting one phrase that links them, e.g. a regex over "`checks` ... succeeded".
- [T1-m3] tools/tests/test_ci_workflow.py:86 - The cache path check is only `"godot" in path`. It doesn't check that the path is where install-godot.sh puts the binary (`~/.local/bin/godot`), or that ~/.local/bin is added to PATH before install. If either is wrong, the cache silently never hits (install-godot.sh decides via `command -v godot`). Suggest asserting the path equals `~/.local/bin/godot`.
- [T1-m4] tools/tests/test_check_sh.py:15 - Failures in the import and format steps aren't exercised, and import-before-lint order isn't asserted. The spec only asks for one failing step, so this is just a suggestion: e.g. a test with a mis-formatted .gd file -> `step 'format' failed`.

## What I ran (own worktree at scratchpad/wt, removed afterwards)
- ecc68ac (red, crit 3): `python3 -m unittest tools.tests.test_ci_workflow` -> 5 failures, all on assertions (`on` not a mapping, no job `checks`).
- b53ce03 (red, crit 5): test_loop_docs -> 2 failures on assertions (regex not found, '`checks`' not in Step 10).
- Head c0e9fa8: `python3 -m unittest discover -s tools/tests -v` -> 10/10 OK (24.7 s); no leftover temp dirs or untracked files.
- Head: `tools/check.sh` -> exit 0, prints `==> import/lint/format/test`, GUT 33/33 passing, "all checks passed".
- Mutation: removed the failure branch from run_step -> both CheckFailsAndNamesStep tests fail (`0 == 0`), CheckPassesOnHead still passes.
