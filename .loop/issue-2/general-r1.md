Status: done
Issue: #2 Number formatting   Round: 1   Reviewed: 9d10791 (whole change main..HEAD)

VERDICT: BLOCKING ISSUES

## Critical
None.

## Important
- [G1-I1] general - Spec #2's "below 1000: whole number" rule conflicts with the approved specs that call `NumberFormat` next. Spec #6 requires the button text "all via `NumberFormat`. e.g. `Tap Lv 3 - 3 dmg - Upgrade: 5.72`", and spec #7 says "HUD shows total team DPS (e.g. `DPS: 9.00`... via `NumberFormat`)". With this PR (probed at HEAD), `tap_upgrade_cost(3)` = 5.7245 -> "5", 5.35 (level 2 cost) -> "5", and DPS 9.0 -> "9". Both examples assume 3 significant digits below 1000, which spec #2 rules out. It also costs gameplay early on. Gold is always fractional (block_gold = 1.045^n; after 5 blocks gold is 5.47 -> "5"), so a player can see "Gold: 5" and "Upgrade: 5" while the button is disabled (5.2 < 5.35). The code follows spec #2 and its tests are right; the problem is that the specs disagree. Either #6/#7 can't meet their examples, or their implementer changes `NumberFormat` and breaks #2's tests: a design that a later issue has to undo. Fix: don't change code in this PR. Defer with that reason, and have the orchestrator flag the conflict on issues #6 and #7 (comment, or `needs-spec`) so `/refine-issue` decides before #6 starts. The choice is either a spec #2 note giving 3 significant digits below 1000 (5.72, 9.00), or new examples in #6/#7 ("5", "9"). A deferral that only adds this to the tech-debt issue is not enough, because #6's implementer reads spec #6, not the tech-debt issue.

## Minor
- [G1-m1] general - The float-parsing caveats from the implementer log (Godot's parser is not correctly rounded above ~1e22; 118 of 10^0..10^308 parse 1 ulp low) appear only in implementer.md, not in the tech-debt list in state.md. Save/load (#8, JSON) is where they show: at HEAD, `JSON.parse_string(JSON.stringify(pow(10.0, k)))` != the original for 115 of k = 3..300, even with `full_precision`. For 14 of them the display changes after a reload because truncation exposes the 1-ulp drop (10^23 "100ac" -> "99.9ac", 10^40 "10.0ai" -> "9.99ai"). Random values almost never flip (0 in 20,000), but the default stringify keeps only about 14 significant digits (0.1 + 0.2 -> "0.3"), so gold drifts on every save/load cycle. Fix: add the caveat to the tech-debt issue and to #8's notes. #8 should save floats losslessly (e.g. `var_to_str`, or the bytes/hex of the double) and test the round trip.
- [G1-m2] general - The spec lifecycle (`specs/README.md`: in-review -> done on merge) is never completed. Spec #1 on `main` still says `Status: in-review` after "Project skeleton (#1)" merged, and Step 10 of implement-next never sets `done`. Spec #2 will end up the same way. Fix: in the merge step, set `Status: done` in the issue's spec before squash-merging, and do it in this PR's final commit.

## Solved findings check
Production code (`scripts/core/number_format.gd`) is unchanged since a39cdff. Test file unchanged since ed3e881 (`git diff ed3e881 HEAD -- scripts test` empty). The diffs of 55e8d17 and ed3e881 only add asserts; the removed lines are the old `1e15 * pow(1000.0, 26)` ba input, now `pow(10.0, 93)` (the same float, confirmed by tests r2), and a one-line `_assert_mantissa(_previous_float(...))` split into a variable. Each mutation was re-run at HEAD:
- [T1-C1] still fixed - floori -> roundi in `_leading_digits`: 2 tests fail (truncation tests at lines 22-26 and 48-50).
- [T1-I1] still fixed - "B" -> "G": fails. Wrong second letter for index > 26: fails. Group +1 above e100: fails (lines 30, 37-40).
- [T1-I2] still fixed - scientific exponent printed `% 100`: fails. SCIENTIFIC applied below 1000: fails (lines 9-11, 78, 82-85).
- Minors T1-m1, T1-m2, Q1-m1, Q1-m2, Q1-m3, Q2-m1: logged, not re-raised.

## Earlier findings
- [T1-C1] fixed (1e8d2a3), still fixed.
- [T1-I1] fixed (55e8d17), still fixed.
- [T1-I2] fixed (ed3e881), still fixed.

## Fit and cross-cutting (no finding)
- Matches architecture A-01 (pure static, `scripts/core/`), A-06 / 4.6 (single helper, typed `Notation` for `GameState.notation` in #9), and D-016. The enum order SUFFIX=0, SCIENTIFIC=1 matches the spec; #9 saves it, so the order is now part of the save format. That's fine as long as nobody reorders it.
- The `float` signature is what the spec asks for. The big-number swap (D-021) will change it, and the "zz" limit with it; the code comment on line 11 records the dt ceiling.
- No dead code or patterns left inconsistent by the fix rounds; all fixes were test-only.

## What I ran
- Own worktree at 9d10791 (removed and pruned afterwards):
  - `godot --headless --path . --import`: exit 0.
  - `gdlint scenes scripts test`: no problems, exit 0.
  - `gdformat --check scenes scripts test`: 4 files unchanged, exit 0.
  - GUT full suite: 19/19 passing, 4212 asserts, exit 0.
  - 6 mutation probes for T1-C1/I1/I2 (above): every one fails the suite. Source restored.
  - Probe script: 5.7245 -> "5", 5.35 -> "5", 9.0 -> "9", gold after 5 blocks 5.47 -> "5". JSON round trip of powers of ten and of 20,000 random values, results as in G1-m1.
- `git diff` checks above. Read specs #3, #5, #6, #7, #8, #9, #14, architecture.md, game-design.md and the concept discussion log. Read PR #18 comments via REST.
