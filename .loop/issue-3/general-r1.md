Status: done

General review round 1, issue #3 "Balance config", branch loop/issue-3-balance-config @ 4a0dab9 (up to date with origin/main 4d112a2).

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
- [G1-m1] scripts/core/balance_config.gd:20 - The Q1-I1 fix only holds on the `load_default()` path. Any other way of getting `res://data/balance.tres` (`preload`/`load` in `game.gd`, or an `@export var config: BalanceConfig` on `Game` pointing at the .tres in `main.tscn`, which spec #14 suggests as the "smallest seam") returns the shared cached instance again. Probe: `load(DEFAULT_PATH)` and `load_default()` give different objects with the same `resource_path`, so nothing shows which one you have. #5 builds `Game` and #14 builds `Main` twice with a tweaked test config, so the trap comes up in two issues soon. Fix: add one line to the class doc comment: "Get the default config only through load_default(); loading or referencing data/balance.tres any other way returns the shared cached instance." Then #5 and #14 reviewers can point to it.

## Solved findings check
- [Q1-I1] still fixed. Fix 55ce5cc (red 42148f7). At HEAD `load_default()` is still `ResourceLoader.load(DEFAULT_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as BalanceConfig` (balance_config.gd:23). No later commit touches balance_config.gd: f575f7d and 4a0dab9 change only .loop/ logs. The test `test_load_default_returns_an_independent_copy_each_time` is present and unchanged: it checks identity of the config and units[0] and reads 0.5 / 1.0 after mutating the first copy. It passes at HEAD. Mutation check: reverting to `load(DEFAULT_PATH)` makes it fail again, with the leak also showing in test_unit_dps_grows_linearly_from_the_defaults.
- No other findings are marked fixed. Q1-m1, S1-m1, S1-m2, T1-m1 and T2-m1 are logged Minors, and no code has touched them since they were logged.

## Finding record
- Severities are right. S1-m1 (INF / negative results for out-of-range n/level) is correctly Minor for this PR: the formulas match the spec and D-021, and no player-controlled input reaches them yet. It only becomes a softlock once #8 loads `destroyed_count` / levels from user://save.json. Spec #8 rejects negatives but not huge values. Recommend the orchestrator name S1-m1 when #8 starts, so it doesn't stay buried in tech debt until after #8 ships.
- No Important was deferred, so there are no deferral reasons to judge.

## Fit with architecture and later specs (checked, no finding)
- A-01/A-05/A-06: plain Resources under scripts/core/, data only in data/balance.tres. All growth and linear maths go through BalanceConfig, which leaves a seam for the later big-number swap. The script defaults are zero, so no balance number is duplicated in code.
- #4: 5 slots, HP 10, gold 1 at n=0, `respawn_delay` 0.5. Matches `BlockField` criteria. `BlockField.slot_count()` (method) vs `BalanceConfig.slot_count` (field) are on different classes, so no clash.
- #5: `tap_damage(1)` = 1. #6: `tap_upgrade_cost(1)` = 5. The example "Upgrade: 5.72" = `tap_upgrade_cost(3)` = 5.7245, which is consistent. Showing that decimal is still #2's deferred G1-I1 (NumberFormat prints whole numbers below 1000); this PR adds nothing new to it.
- #7: units in config order Pistol/Shotgun/Rocket, `unit_cost(pistol, 0)` = 10, `unit_dps(pistol, 1)` = 1. Matches its criteria. `unit_dps` takes a UnitConfig while GameState keys levels by StringName id, so `unit_by_id` bridges the two (null case: S1-m2).
- #8: `autosave_interval` 10.0; unknown ids map to null through `unit_by_id`.
- #14: "test BalanceConfig with small numbers" works now. `load_default()` gives a private copy to tweak, and probe shows `duplicate(true)` is independent too. A bare `BalanceConfig.new()` is degenerate (slot_count 0, growth 0, so block_hp(n>=1) = 0), which is acceptable because the defaults live in data (A-05). Tests should start from `load_default()`.
- Spec status `in-review` with criteria ticked follows the lifecycle in specs/_template.md. #2 went to `done` at merge.
- Nothing out of scope; no dead code or leftovers from the fix round.

## What I ran
- Own worktree at 4a0dab9 (removed afterwards; shared checkout untouched).
- `godot --headless --path . --import`: exit 0 (only the GUT class-update lines and the usual ObjectDB leak warning at exit).
- `gdlint scenes scripts test`: Success, no problems found (exit 0).
- `gdformat --check scenes scripts test`: 7 files would be left unchanged (exit 0).
- Full GUT suite: exit 0, 4 scripts, 33/33 passing, 4287 asserts, no errors or warnings in the output.
- Mutation: load_default -> `load(DEFAULT_PATH)`: test_balance_config.gd fails (identity, 99.0 vs 0.5, 77.0 vs 1.0, leak into pistol dps). Restored.
- Probe (temporary GUT test, deleted): cached `load()` vs `load_default()` are distinct objects with the same resource_path, and their unit sub-resources share the path `balance.tres::Resource_75r0e`. `BalanceConfig.new()`: slot_count 0, block_hp(0) = block_hp(1) = 0, no units. `duplicate(true)` copy is independent. `tap_upgrade_cost(0)` = 4.67, `tap_damage(0)` = 0. Unit ids in order pistol, shotgun, rocket.
- `git log HEAD..origin/main`: empty (branch current).
