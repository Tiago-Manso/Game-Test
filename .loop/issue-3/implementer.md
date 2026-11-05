Status: done
Issue: #3 Balance config   Attempt: 1/2
Branch: loop/issue-3-balance-config

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | load_default() values match the table, units Pistol, Shotgun, Rocket in order | refactored | 9290bc2 | 88aa8ae |
| 2 | Each formula at n/level 0, 1, 10 with default values | refactored | 6451499 | 54ba622 |
| 3 | tap_damage(1) = 1, unit_dps(any, 0) = 0 | refactored (no red possible) | - | 6d83380 (test only) |
| 4 | Changing a value on an instance changes the formula result | refactored (no red possible) | - | e62e1c7 (test only) |
| 5 | unit_by_id(&"shotgun") returns Shotgun; unknown id returns null | refactored | 3d2e850 | d2c21d4 |

## Findings
None yet.

## Last checks
Baseline (before any change): import 0, lint 0, format 0, tests exit 0 (19/19, 4212 asserts).
Criterion 1 red: tests exit 1; failures are assertions ([0] expected to equal [5], [0] expected to equal [3] "three units").
The red commit adds declaration-only stubs (exported fields with zero defaults, load_default() returning BalanceConfig.new()) so the failure is the assertion, not a missing class.
Criterion 1 green: data/balance.tres (saved once with ResourceSaver so the format is Godot's own, script uids added to the ext_resources); load_default() loads DEFAULT_PATH. import 0, lint 0, format 0, tests exit 0 (21/21, 4242 asserts).
Criterion 2 red: 27 failed asserts, e.g. [0.0] expected to equal [16.2889462678] +/- [1.6e-8] "block_hp(10)". Red commit adds the six formula methods as stubs returning 0.0. Lint 0, format 0.
Interpretation: tap level starts at 1 (spec), so the tap formulas are checked at levels 1, 2 and 10 rather than 0. unit_dps level 0 is criterion 3's own test. Expected values come from Python doubles, compared with a relative tolerance of 1e-9.
Criterion 2 green: formulas with pow(); import 0, lint 0, format 0, tests exit 0 (27/27, 4269 asserts).
Criterion 3: passes on first run - criterion 2's green formulas already satisfy it, so no red commit is possible without writing deliberately wrong code. Verified the test can fail with mutations (unit_dps uses maxi(level, 1): "[1.0] expected to equal [0.0] pistol dps at level 0"; tap_damage + 0.5: "[1.5] expected to equal [1.0]"), then restored. Tests exit 0 (29/29, 4274 asserts), lint 0, format 0.
Criterion 4: passes on first run - criterion 2's formulas already read every field. Verified by mutation: replacing each field in the six formulas with its default literal makes all six asserts fail (e.g. "[2.205] expected to equal [18.0] block_hp uses block_base_hp and block_hp_growth"), then restored. Tests exit 0 (30/30, 4280 asserts), lint 0, format 0.
Criterion 5 red: "Expected [<null>] to be anything but NULL: shotgun found". Red commit adds a unit_by_id stub returning null (so the unknown-id half already passes; the shotgun half is the red). Lint 0, format 0.
Criterion 5 green: linear search over units by id. Tests exit 0 (32/32, 4283 asserts), import 0, lint 0, format 0.
Refactor: the load_default tests use the before_each config instead of loading it again. Tests exit 0 (32/32, 4283 asserts), import 0, lint 0, format 0.
Spec set to in-review, all five [test] criteria ticked (docs commit). Final checks: import exit 0, lint exit 0, format check exit 0, tests exit 0 (32/32, 4283 asserts).
