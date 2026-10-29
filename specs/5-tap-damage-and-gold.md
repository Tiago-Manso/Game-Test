# Tap damage and gold

- Issue: #5
- Status: ready

## Context

The core clicker loop: tap a block to damage it, break it, earn gold, see
your gold go up (D-005).

## Requirements

- `scripts/core/game_state.gd`, `class_name GameState extends RefCounted`: holds `gold: float` (starts 0) and `tap_level: int` (starts 1). Later issues add fields.
  - `add_gold(amount: float)`, `can_afford(cost: float) -> bool`, `spend(cost: float) -> bool` (returns false and changes nothing if not affordable). Amounts <= 0 are ignored by `add_gold`.
  - Signal `gold_changed(gold: float)` on every change.
- Tapping (touch, or mouse click via touch emulation) a block deals `tap_damage(tap_level)` to that slot via `BlockField.damage`. One tap = one hit; holding does not repeat.
- When a block breaks, its gold is added to `GameState`.
- HUD (`scenes/hud/hud.tscn`, in the main scene) shows the gold amount at the top of the screen, formatted with `NumberFormat` (suffix notation), updated on `gold_changed`.
- A `Game` node (main scene script or `scenes/main/game.gd`) wires `BalanceConfig`, `GameState`, `BlockField`, field scene and HUD together. Gameplay nodes get their dependencies from it, not via global autoloads, so tests can build them with their own config.

## Acceptance criteria

- [ ] [test] `GameState`: starts with 0 gold and tap level 1; `add_gold`, `can_afford` and `spend` behave as described, including refusing to overspend and ignoring amounts <= 0; `gold_changed` emits on each change.
- [ ] [test] Integration: a simulated click on block slot 2 lowers that block's HP by `tap_damage(1)` and leaves the others unchanged.
- [ ] [test] Integration: tapping a block until it breaks adds exactly its gold to `GameState` and the HUD label shows the new amount via `NumberFormat`.
- [ ] [test] Integration: a click on an empty (respawning) slot or outside any block does nothing.
- [ ] [manual] Clicking blocks with the mouse and tapping on a touch screen both work and feel responsive.

## Assets

Placeholder OK.

## Out of scope

- Buying tap upgrades (#6) and units (#7).
- Saving (#8). Notation setting (#9).
- Hit effects (D-023: HP bar only).

## Notes

D-005, D-011, D-016, D-022. Depends on #2 and #4.
