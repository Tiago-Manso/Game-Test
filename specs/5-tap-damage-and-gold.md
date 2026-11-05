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
- `scripts/core/simulation.gd`, `class_name Simulation extends RefCounted` (architecture section 4.4):
  - `_init(state: GameState, field: BlockField, config: BalanceConfig)` (#7 adds the team).
  - `step(dt: float)` advances time: calls `field.tick(dt)`. It is the **only** place time moves.
  - `tap(slot: int)` deals `tap_damage(state.tap_level)` to that slot via `BlockField.damage`.
  - Connects `block_broken` once and adds the block's gold to `GameState` - the single path for gold from any break.
- Tapping (touch, or mouse click via touch emulation) a block calls `simulation.tap(slot)`. One tap = one hit; holding does not repeat. Presentation never changes state directly.
- HUD (`scenes/hud/hud.tscn`, in the main scene) shows the gold amount at the top of the screen, formatted with `NumberFormat` (suffix notation), updated on `gold_changed`.
- `scenes/main/game.gd` (the `Game` node in the main scene) builds `BalanceConfig`, `GameState`, `BlockField` and `Simulation`, calls `setup(...)` on the field scene and HUD, and calls `simulation.step(delta)` from `_physics_process` (60 Hz, D-031). No gameplay autoloads; tests can build `Game` with their own config.

## Acceptance criteria

- [ ] [test] `GameState`: starts with 0 gold and tap level 1; `add_gold`, `can_afford` and `spend` behave as described, including refusing to overspend and ignoring amounts <= 0; `gold_changed` emits on each change.
- [ ] [test] `Simulation`: `tap(slot)` deals `tap_damage(tap_level)` to that slot only; `step(dt)` respawns broken blocks after `respawn_delay`; a break adds exactly the block's gold to `GameState`, once.
- [ ] [test] Integration: `Game` calls `simulation.step` from `_physics_process` with the frame's delta, and no other node advances time.
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
- The team (#7): `Simulation` gets `Team` there.

## Notes

D-005, D-011, D-016, D-022, D-029, D-030, D-031. Architecture: A-01 to A-04, sections 4.4 and 5. Depends on #2 and #4.
