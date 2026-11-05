Status: in progress
Issue: #3 Balance config   Attempt: 1/2
Branch: loop/issue-3-balance-config

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | load_default() values match the table, units Pistol, Shotgun, Rocket in order | green | 9290bc2 | (this commit) |
| 2 | Each formula at n/level 0, 1, 10 with default values | green | 6451499 | (this commit) |
| 3 | tap_damage(1) = 1, unit_dps(any, 0) = 0 | green (no red possible) | - | (this commit, test only) |
| 4 | Changing a value on an instance changes the formula result | green (no red possible) | - | (this commit, test only) |
| 5 | unit_by_id(&"shotgun") returns Shotgun; unknown id returns null | todo | - | - |

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
