Status: done

# Test review - issue #3 Balance config - round 2 (HEAD f575f7d)

VERDICT: NO BLOCKING ISSUES

## Criterion -> test map
| # | Criterion | Test(s) (test/unit/test_balance_config.gd) | Complete? |
|---|-----------|--------------------------------------------|-----------|
| 1 | load_default() values match the table, 3 units Pistol, Shotgun, Rocket in order | test_load_default_values_match_the_spec_table (all 10 scalars), test_load_default_has_pistol_shotgun_rocket_in_order (size 3, id/name/cost/growth/dps per index) | yes |
| 2 | Each formula at n/level 0, 1, 10 with defaults (block_hp(10) ~ 16.29, unit_cost(pistol, 0) = 10) | test_block_hp_*, test_block_gold_*, test_tap_damage_grows_*, test_tap_upgrade_cost_*, test_unit_dps_grows_*, test_unit_cost_grows_* | yes (tap at 1/2/10 since level starts at 1; unit_dps level 0 in crit 3 test) |
| 3 | tap_damage(1) = 1, unit_dps(any, 0) = 0 | test_tap_damage_at_level_1_is_1, test_unit_dps_at_level_0_is_0_for_any_unit | yes |
| 4 | Changing a value on an instance changes the formula result | test_changing_instance_values_changes_every_formula | yes |
| 5 | unit_by_id(&"shotgun") returns Shotgun; unknown id -> null | test_unit_by_id_finds_shotgun, test_unit_by_id_returns_null_for_unknown_id | yes (T1-m1 logged) |
| - | Behaviour change Q1-I1: load_default returns an independent copy | test_load_default_returns_an_independent_copy_each_time (identity of config and units[0], plus values 0.5 / 1.0 after mutating the first copy) | yes |

## TDD
- Q1-I1 red 42148f7 (test only + implementer log) -> green 55ce5cc (load_default uses CACHE_MODE_IGNORE + doc comment). Red fails on the assertions, as reported.
- Crit 1 red 9290bc2 (picked this round; r1 checked 6451499) fails on the assertions.
- Crit 3/4 have no red (implied by crit 2's formulas); accepted in r1 with mutation evidence.
- No test weakened, skipped, deleted or made pending across main..HEAD (no removed test lines in the diff).

## Reliability
- New test only mutates its own `first` copy; at HEAD each load_default is fresh, so no leak. At the red (or on a regression) the mutation leaks into test_unit_dps_grows_linearly_from_the_defaults - that is the bug itself showing, and the new test fails first with a clear message. Test passes alone (-gunit_test_name) and in the full suite.
- No time, randomness, files or nodes.

## Critical
None.

## Important
None.

## Minor
- [T2-m1] test/unit/test_balance_config.gd:46 - the identity checks on lines 46-47 use `assert_ne`, which passes only because GDScript `==` on Objects is identity, and reports "expected to not equal". The same file uses `assert_same` for identity (line 138); `assert_not_same(second, first, ...)` / `assert_not_same(second.units[0], first.units[0], ...)` would say what is proved. Cosmetic.

## Earlier findings
- [Q1-I1] fixed - 55ce5cc; covered by the new test, which catches every wrong variant I tried (see What I ran).
- [T1-m1] logged (tech debt), not re-raised.
- [Q1-m1], [S1-m1], [S1-m2] logged, not my area.

## What I ran
- Worktree at red 42148f7: import 0; full suite exit 1, 31/33 passing, 4281/4287 asserts. Failures all assertions: "expected to not equal ... a different config object", "... a different unit object", "[99.0] expected to equal [0.5]: respawn_delay from the file", "[77.0] expected to equal [1.0]: pistol base_dps from the file", plus the leak into test_unit_dps_grows_linearly_from_the_defaults ("[77.0] expected to equal [1.0] pistol dps(1)", "[770.0] ... pistol dps(10)"). Matches the implementer's report.
- Worktree at red 9290bc2: import 0; full suite exit 1, 19/21, failures all assertions ("[0] expected to equal [5]", ..., "[0] expected to equal [3]: three units"); no script errors.
- Worktree at HEAD f575f7d: import 0; gdlint "Success: no problems found"; gdformat --check "7 files would be left unchanged"; full suite exit 0, 33/33, 4287 asserts; test_balance_config.gd alone exit 0, 14/14, 75 asserts; new test alone exit 0, 1/1, 4 asserts.
- Mutations of load_default at HEAD (restored after each): `load(...).duplicate()` (shallow) -> fails (shared unit object, base_dps 77); `load(...).duplicate(true)` -> passes (correct alternative); CACHE_MODE_REPLACE -> fails on the identity asserts (values reload, so the identity asserts are what catch it); CACHE_MODE_REUSE (original bug) -> fails.
- Worktrees removed; shared checkout untouched.
