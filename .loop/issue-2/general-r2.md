Status: done
Issue: #2 Number formatting   Round: 2   Reviewed: 2db4bd5 (whole change main..HEAD)

VERDICT: NO BLOCKING ISSUES

## Critical
None.

## Important
None.

## Minor
- [G2-m1] general (PR #18 body) - "Checks run" in the PR body still says "GUT: 17/17 passing (3604 asserts)". At HEAD it is 19/19 with 4212 asserts, after the T1-C1/T1-I1/T1-I2 fix commits. Merge step 3 of implement-next refreshes the TDD log and the review table but not "Checks run", so the stale numbers would end up on the merged record. Fix: when the PR body is updated at merge, refresh "Checks run" with the numbers from the merge-step check run. Optionally list the fix commits (1e8d2a3, 55e8d17, ed3e881) under the TDD log.

## Solved findings check
Production and test code are unchanged since ed3e881 (`git diff ed3e881 HEAD -- scripts test scenes` is empty). 9d10791..HEAD touches only `.loop/` files. Each fix was re-checked by mutation at HEAD:
- [T1-C1] still fixed - `floori` -> `roundi` in `_leading_digits`: 2 tests fail.
- [T1-I1] still fixed - "B" -> "G": 1 test fails. Second letter `posmod(index + 1, ...)`: 1 test fails.
- [T1-I2] still fixed - exponent printed as `exponent % 100`: 1 test fails. SCIENTIFIC applied below 1000: 1 test fails.
- Logged Minors (T1-m1, T1-m2, Q1-m1, Q1-m2, Q1-m3, Q2-m1, G1-m1, G1-m2) were not re-raised.

## Earlier findings
- [T1-C1] fixed (1e8d2a3), still fixed.
- [T1-I1] fixed (55e8d17), still fixed.
- [T1-I2] fixed (ed3e881), still fixed.
- [G1-I1] deferred: the reason is sound.
  - The conflict is between approved specs. Only the user can settle it, and changing `NumberFormat` here would break spec #2's own criterion 1 (999.9 -> `999`).
  - Round 1 asked for the conflict to reach the issues #6 and #7 themselves, not only the tech-debt list. That was done: orchestrator comments on #6 and #7 (2026-11-05 18:41) ask numbered questions and request `/refine-issue` before implementation.
  - That flag will be acted on. implement-next Step 5 reads "the issue body and all comments", and its ambiguity gate sends an issue whose spec "contradicts ... another spec" to `needs-spec`.
  - #6 and #7 both depend on #5, which is still open, so neither can start before then.
  - Spec #5, the only earlier spec that shows a number via `NumberFormat` (gold on the HUD), has no decimal example, so nothing before #6 depends on the decision.
  - #6/#7 keep the `ready` label, so the user is not prompted until the loop reaches them. This costs at most one claimed-then-stopped run, which is not enough to re-raise.
- G1-m1, G1-m2: logged.

## Fit and cross-cutting (no finding)
- Nothing new since round 1: the code is unchanged and the round-1 notes on fit (A-01, A-06/4.6, D-016, D-021, the enum order becoming part of the #9 save format) still hold.
- Edge cases re-checked by reading the code:
  - `-0.0` -> "0" (`value < 0.0` is false).
  - The largest float gives exponent 308, group 102, suffix "dt", which matches the comment on line 11.
  - `pow(10, 309)` = INF does not move the exponent.
- No dead code, and no patterns left inconsistent across files. All fix-round changes were test-only.

## What I ran
- Own worktree at 2db4bd5 (removed and pruned afterwards):
  - `godot --headless --path . --import`: exit 0.
  - `gdlint scenes scripts test`: no problems, exit 0.
  - `gdformat --check scenes scripts test`: 4 files unchanged, exit 0.
  - GUT full suite: 19/19 passing, 4212 asserts, exit 0.
  - 5 mutation probes (above): each makes the suite fail. Source restored with `git checkout`.
- `git diff ed3e881 HEAD -- scripts test scenes` (empty), `git diff 9d10791 HEAD --stat` (only `.loop/`).
- Read via REST:
  - issues #6 and #7 (labels, body, comments);
  - PR #18 (body, issue comments, review comments).
- Read implement-next Steps 3-5 and 10, specs #5/#6/#7, architecture 4.6, and game-design.md.
