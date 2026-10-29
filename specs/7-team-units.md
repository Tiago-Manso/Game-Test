# Team units

- Issue: #7
- Status: ready

## Context

The idle part: units bought with gold damage blocks on their own (D-010,
D-011, D-013). Three units: Pistol, Shotgun, Rocket (D-019).

## Requirements

- `GameState` gains `unit_levels: Dictionary` (unit id -> level, all 0 at start), `unit_level(id) -> int`, `set_unit_level(id, level)` and signal `unit_level_changed(id: StringName, level: int)`.
- Total team DPS = sum of `unit_dps(unit, level)` over all units.
- Every physics frame, `total_dps * delta` damage goes to `BlockField.lowest_hp_slot()`. If it is -1 (all slots empty) the damage is lost. Breaking a block this way pays gold exactly like a tap.
- Put the DPS step in testable logic (e.g. a `Team` class with `step(delta)`), not only in a scene callback.
- Shop rows (below the tap upgrade), one per unit in config order: name, level, current DPS, cost of next level, buy button. Same enable/disable rules as the tap upgrade (#6): affordable -> enabled; buying spends `unit_cost(unit, level)` and raises the level by 1.
- HUD shows total team DPS (e.g. `DPS: 9.00`... via `NumberFormat`) under the gold.

## Acceptance criteria

- [ ] [test] All units start at level 0 and total DPS is 0.
- [ ] [test] Buying a Pistol at level 0 with 10 gold spends 10, sets level 1 and total DPS 1; buying is refused without enough gold.
- [ ] [test] Total DPS sums every unit (e.g. Pistol 2 + Shotgun 1 = 2 + 8 = 10).
- [ ] [test] With total DPS 10, stepping 1.0 s (in several frames) removes 10 HP from the lowest-HP block and nothing from the others.
- [ ] [test] When the lowest-HP block breaks, team damage moves to the next lowest-HP block from the next step on; overkill is not carried over.
- [ ] [test] With every slot empty, a step does nothing and causes no error.
- [ ] [test] A block broken by the team pays its gold into `GameState`.
- [ ] [test] Integration: shop rows show the 3 units in config order with level, DPS and cost via `NumberFormat`; buttons enable/disable with gold.
- [ ] [manual] With a few units bought, blocks visibly lose HP on their own and gold climbs without tapping.

## Assets

Placeholder OK (no unit sprites or projectiles).

## Out of scope

- Shot visuals, projectiles, unit sprites.
- Choosing targets manually (D-013: always lowest HP).
- Buy x10 / buy max, milestone multipliers.

## Notes

D-010, D-011, D-013, D-019, D-020. Depends on #5.
