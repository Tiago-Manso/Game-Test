Status: done

# Test review - issue #3 Balance config - round 1

VERDICT: NO BLOCKING ISSUES

## Criterion -> test map
| # | Criterion | Test(s) (test/unit/test_balance_config.gd) | Complete? |
|---|-----------|--------------------------------------------|-----------|
| 1 | load_default() values match the table, 3 units Pistol, Shotgun, Rocket in order | test_load_default_values_match_the_spec_table (all 10 scalars), test_load_default_has_pistol_shotgun_rocket_in_order (size 3, id/name/cost/growth/dps per index) | yes - every table value asserted; non-exported fields would also fail here since script defaults are 0 |
| 2 | Each formula at n/level 0, 1, 10 with defaults (block_hp(10) ~ 16.29, unit_cost(pistol, 0) = 10) | test_block_hp_*, test_block_gold_*, test_tap_damage_grows_*, test_tap_upgrade_cost_*, test_unit_dps_grows_*, test_unit_cost_grows_* | yes - tap formulas at 1/2/10 (level starts at 1, documented); unit_dps level 0 is in crit 3's test; expected values re-derived in Python, all match |
| 3 | tap_damage(1) = 1, unit_dps(any, 0) = 0 | test_tap_damage_at_level_1_is_1, test_unit_dps_at_level_0_is_0_for_any_unit (3 defaults + a custom unit with base_dps 123) | yes |
| 4 | Changing a value on an instance changes the formula result | test_changing_instance_values_changes_every_formula (all 6 numeric formulas, non-default values) | yes |
| 5 | unit_by_id(&"shotgun") returns Shotgun; unknown id -> null | test_unit_by_id_finds_shotgun (assert_same with units[1]), test_unit_by_id_returns_null_for_unknown_id | yes, literally; see T1-m1 |

## TDD
- Red/green pairs: crit 1 9290bc2 -> 88aa8ae, crit 2 6451499 -> 54ba622, crit 5 3d2e850 -> d2c21d4. Red commits carry zero-value declaration stubs (needed in GDScript so the failure is an assertion, not a parse error); no behaviour in them.
- Crit 3 and 4 have no red commit: they are implied by crit 2's formulas, so a red would need deliberately wrong code. I reproduced the implementer's mutation checks (below) - the tests do fail when the behaviour breaks. Accepted, not a finding.
- No test weakened, skipped, deleted or pending across the branch (refactor 264f9b6 only swaps local loads for the before_each config).

## Reliability
- No time, randomness, files or scene nodes; Resources are RefCounted. load_default() returns the cached shared resource, but no test mutates it (crit 4 test uses BalanceConfig.new(); crit 3 test duplicates the array before appending). File passes alone and in the full suite.

## Critical
None.

## Important
None.

## Minor
- [T1-m1] test/unit/test_balance_config.gd:126 - unit_by_id is only checked with the middle entry. A mutant that returns units[1] whenever any id matches (e.g. a hard-coded index) passes all 13 tests (I ran it). Adding assert_same for &"pistol" -> units[0] and &"rocket" -> units[2] would prove the lookup is by id, not by position.

## What I ran
- python3 recomputation of every expected value (1.05^10*10, 1.045^10, 5*1.07^9, 10*1.07^10, 100*1.08^10, 1000*1.09^10, 5.35): all match the test constants.
- Red commit 6451499 in own worktree: import 0; tests exit 1; 27 failures, all assertions ("[0.0] expected to equal [16.2889462678] +/- ... block_hp(10)" etc.), no script errors.
- HEAD d898a9c in own worktree: import 0; gdlint "no problems found"; gdformat --check "7 files would be left unchanged"; full suite exit 0, 32/32 tests, 4283 asserts; test_balance_config.gd alone exit 0, 13/13, 71 asserts.
- Mutations at HEAD (restored after each): unit_dps uses maxi(level,1) -> 4 crit-3 failures; block_hp uses literal 1.05 -> crit-4 failure; tap_upgrade_cost exponent level -> 4 failures; unit_cost uses literal 1.07 -> 5 failures; tap_damage * level^2 -> 3 failures; unit_by_id returns units[1] on any match -> 0 failures (T1-m1).
- Worktrees removed.
