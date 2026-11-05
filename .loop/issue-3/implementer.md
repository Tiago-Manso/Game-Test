Status: in progress
Issue: #3 Balance config   Attempt: 1/2
Branch: loop/issue-3-balance-config

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | load_default() values match the table, units Pistol, Shotgun, Rocket in order | red | (this commit) | - |
| 2 | Each formula at n/level 0, 1, 10 with default values | todo | - | - |
| 3 | tap_damage(1) = 1, unit_dps(any, 0) = 0 | todo | - | - |
| 4 | Changing a value on an instance changes the formula result | todo | - | - |
| 5 | unit_by_id(&"shotgun") returns Shotgun; unknown id returns null | todo | - | - |

## Findings
None yet.

## Last checks
Baseline (before any change): import 0, lint 0, format 0, tests exit 0 (19/19, 4212 asserts).
Criterion 1 red: tests exit 1; failures are assertions ([0] expected to equal [5], [0] expected to equal [3] "three units").
The red commit adds declaration-only stubs (exported fields with zero defaults, load_default() returning BalanceConfig.new()) so the failure is the assertion, not a missing class.
