# PO review r1 - issue #13 CI workflow (PR #22)
Status: done
Head reviewed: c6d4ba6

DECISION: GO

## Acceptance criteria
| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | check.sh exits 0 on head, output names all four steps | met | test_check_sh.CheckPassesOnHead.test_exits_zero_and_names_every_step (asserts rc 0, "==> import/lint/format/test", "all checks passed"); passed in my worktree at c6d4ba6 |
| 2 | check.sh exits non-zero and names the step when one fails | met | test_lint_error_fails_lint_step, test_failing_gut_test_fails_test_step: throwaway copy with a lint error / failing GUT test; asserts rc != 0, "step '<name>' failed", later steps not run. Passed. |
| 3 | ci.yml valid YAML with triggers, job name, steps | met | test_ci_workflow.CiWorkflow (5 tests): pull_request + push to main, single job `checks` on ubuntu-latest, checkout -> setup-python -> install-godot.sh -> check.sh in order, cache keyed by hashFiles('.godot-version') before install, no continue-on-error. Passed. |
| 4 | [manual] `checks` runs on this PR and is green before merge | met by inspection | check-runs for head c6d4ba6: `checks completed success`. Orchestrator re-verifies on final head in Step 10 item 4. |
| 5 | CLAUDE.md lists check.sh; Step 10 requires green `checks` | met | test_loop_docs (3 tests) incl. ordering test: wait comes after last push, before merge_pull_request. Passed. |

Import in worktree: exit 0. Full tools/tests suite: 11 tests OK (22 s).

## Requirements / scope
- check.sh runs the exact four CLAUDE.md commands in order, stops at first failure, names the failing step. Met.
- Godot version from .godot-version (install-godot.sh), cache path ~/.local/bin/godot matches install dest. Met.
- Out of scope respected: no required-status-check config, no export/release, no CodeQL.
- Assets: none required, none added.

## Deferred and minor findings
None reach a player; this issue is tooling only. T1-I1 (tools/tests not run in CI) is a soundly deferred gap in guarding the CI config itself; the spec fixes the ci.yml steps. G2-m1 (red CI at item 4 leaves state.md saying merged) is a loop-bookkeeping risk worth fixing in the tech-debt issue.

## Manual checks (non-blocking)
- Before merge: confirm `checks` is success on the final head SHA (gh api .../commits/<sha>/check-runs).
- After merge: confirm the push-to-main run of `checks` is green and that the Godot cache hits on a second run.
- Later: user makes `checks` a required status check in repository rules (out of scope here).
- Follow-ups: G2-m1, S2-m1 (cap the wait / missing run), T1-I1 (run tools/tests in CI) via the tech-debt issue.
