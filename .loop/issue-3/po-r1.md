Status: done

PO round 1, issue #3 "Balance config", branch loop/issue-3-balance-config @ 6e0e343 (origin/main has no newer commits).

DECISION: GO

## Acceptance criteria
| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | `load_default()` returns a config whose values match the table, including the 3 units in order Pistol, Shotgun, Rocket | met | `test_load_default_values_match_the_spec_table` checks all 10 scalar fields against the table. `test_load_default_has_pistol_shotgun_rocket_in_order` checks size 3 and id, display_name, cost, growth and dps for units[0..2]. data/balance.tres matches the spec table field by field. `test_load_default_returns_an_independent_copy_each_time` covers Q1-I1. |
| 2 | Each formula returns the expected value for n/level 0, 1 and 10 using the defaults (e.g. `block_hp(10)` ~ 16.29, `unit_cost(pistol, 0)` = 10) | met | `test_block_hp_*`, `test_block_gold_*`, `test_unit_cost_*` (all 3 units) at 0/1/10, and `test_unit_dps_*` at 1/10 (level 0 in crit 3's test). The tap formulas are checked at 1/2/10 because the spec says tap level starts at 1, so 0 is outside the domain. That reading is sound. I recomputed the expected values: 10*1.05^10 = 16.2889, 1.045^10 = 1.55297, 5*1.07^9 = 9.1923, 10*1.07^10 = 19.6715, 100*1.08^10 = 215.892, 1000*1.09^10 = 2367.36. Relative tolerance is 1e-9. |
| 3 | `tap_damage(1)` = 1, `unit_dps(any, 0)` = 0 | met | `test_tap_damage_at_level_1_is_1`; `test_unit_dps_at_level_0_is_0_for_any_unit` (all 3 defaults plus a custom unit with dps 123). The implementer showed by mutation that the test can fail. |
| 4 | Changing a value on a config instance changes the formula result (no constants hidden in code) | met | `test_changing_instance_values_changes_every_formula` sets non-default values on a fresh instance and unit, then checks all six formulas against hand-computed results (18, 40, 21, 36, 18, 48). The script defaults are all 0, so no balance number is duplicated in code. |
| 5 | `unit_by_id(&"shotgun")` returns Shotgun; an unknown id returns null | met | `test_unit_by_id_finds_shotgun` (assert_same against units[1]); `test_unit_by_id_returns_null_for_unknown_id`. |

## Requirements, scope, assets
- balance_config.gd / unit_config.gd: class names, `extends Resource`, every field `@export` and statically typed, and the field names and types match the spec. The 7 methods and `load_default()` have the spec's signatures and formulas. `load_default()` loads `res://data/balance.tres`; it bypasses the cache, which still satisfies "loads".
- Out of scope respected: nothing in scenes/ or other scripts uses the config, and there is no editor.
- Assets: none required, none added.
- Issue thread: only the loop's pickup comment, so there are no clarifications to honour.

## Deferred and minor findings
Q1-m1, S1-m1, S1-m2, T1-m1, T2-m1 and G1-m1 are all logged Minors. This issue adds no gameplay, so a player can't hit any of them here. S1-m1 (INF/negative results from out-of-range counts or levels in an edited save) and S1-m2 (a null unit passed to unit_dps/unit_cost) become reachable once #7/#8 load saves. See the follow-ups below.

## Manual checks (non-blocking)
- None: the spec has no [manual] criteria and this issue has no visible behaviour.
- Follow-up: when #8 (save/load) starts, make sure its implementer and reviewers see S1-m1 (clamp or reject huge loaded counts and levels) and S1-m2/Q1-m1 (null units).
- Follow-up: when #5 and #14 start, point at G1-m1. Get the default config only through `load_default()`; a `preload` or `@export` reference to balance.tres returns the shared cached instance.

## What I ran
- Own worktree at HEAD 6e0e343, removed afterwards.
- `godot --headless --path . --import`: exit 0, no errors.
- `gdlint scenes scripts test`: no problems. `gdformat --check`: 7 files unchanged.
- GUT full suite: exit 0, 4 scripts, 33/33 passing, 4287 asserts.
- grep for balance usage in scenes/ and scripts/: only the new core scripts.
