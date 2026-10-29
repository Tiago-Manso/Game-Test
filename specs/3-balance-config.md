# Balance config

- Issue: #3
- Status: ready

## Context

Every balance number lives in data so we can tune without touching code
(D-008). Curves are exponential (D-020). Later issues read only from here.

## Requirements

- `scripts/core/balance_config.gd`, `class_name BalanceConfig extends Resource`, all fields `@export`, statically typed.
- `scripts/core/unit_config.gd`, `class_name UnitConfig extends Resource`: `id: StringName`, `display_name: String`, `base_cost: float`, `cost_growth: float`, `base_dps: float`.
- Default values in `data/balance.tres` (starting numbers, tuned later):

| Field | Value |
|-------|-------|
| `slot_count` | 5 |
| `respawn_delay` | 0.5 (seconds) |
| `autosave_interval` | 10.0 (seconds) |
| `block_base_hp` | 10.0 |
| `block_hp_growth` | 1.05 |
| `block_base_gold` | 1.0 |
| `block_gold_growth` | 1.045 |
| `tap_base_damage` | 1.0 |
| `tap_base_cost` | 5.0 |
| `tap_cost_growth` | 1.07 |
| `units` | Pistol (`pistol`, cost 10, growth 1.07, dps 1), Shotgun (`shotgun`, cost 100, growth 1.08, dps 8), Rocket (`rocket`, cost 1000, growth 1.09, dps 60) |

- Formula methods on `BalanceConfig` (`n` = blocks destroyed so far, `level` as described):
  - `block_hp(n: int) -> float` = `block_base_hp * block_hp_growth ^ n`
  - `block_gold(n: int) -> float` = `block_base_gold * block_gold_growth ^ n`
  - `tap_damage(level: int) -> float` = `tap_base_damage * level` (level starts at 1)
  - `tap_upgrade_cost(level: int) -> float` = `tap_base_cost * tap_cost_growth ^ (level - 1)` (cost to go from `level` to `level + 1`)
  - `unit_dps(unit: UnitConfig, level: int) -> float` = `unit.base_dps * level` (level 0 = not owned = 0 dps)
  - `unit_cost(unit: UnitConfig, level: int) -> float` = `unit.base_cost * unit.cost_growth ^ level` (cost to go from `level` to `level + 1`)
  - `unit_by_id(id: StringName) -> UnitConfig` (null if unknown)
- `BalanceConfig.load_default() -> BalanceConfig` loads `res://data/balance.tres`.

## Acceptance criteria

- [ ] [test] `load_default()` returns a config whose values match the table, including the 3 units in order Pistol, Shotgun, Rocket.
- [ ] [test] Each formula returns the expected value for n/level 0, 1 and 10 using the default values (e.g. `block_hp(10)` ≈ 16.29, `unit_cost(pistol, 0)` = 10).
- [ ] [test] `tap_damage(1)` = 1, `unit_dps(any, 0)` = 0.
- [ ] [test] Changing a value on a config instance changes the formula result (no constants hidden in code).
- [ ] [test] `unit_by_id(&"shotgun")` returns Shotgun; an unknown id returns null.

## Assets

None.

## Out of scope

- Using the config in gameplay (issues #4-#8).
- An in-game balance editor.

## Notes

D-008, D-010, D-014, D-015, D-017, D-018, D-019, D-020, D-024. Depends on #1.
