# Blocks and slots

- Issue: #4
- Status: in-review

## Context

The playfield: several blocks in fixed slots that break and respawn, getting
tougher as more are destroyed (D-009, D-014, D-015). This issue builds the
logic and the on-screen blocks; tapping comes in #5, the team in #7.

## Requirements

- Logic in `scripts/core/block_field.gd`, `class_name BlockField extends RefCounted`, no scene dependencies:
  - Created with a `BalanceConfig` and an initial `destroyed_count` (default 0).
  - Holds `slot_count` slots. Each slot is either a block (`hp`, `max_hp`, `gold`) or empty with a respawn countdown.
  - On creation every slot has a block.
  - A new block's `max_hp = block_hp(destroyed_count)` and `gold = block_gold(destroyed_count)`, using the count **at spawn time**.
  - `damage(slot: int, amount: float) -> void`: lowers HP; at HP <= 0 the block breaks: slot empties, `destroyed_count += 1`, respawn countdown starts at `respawn_delay`, signal `block_broken(slot: int, gold: float)` is emitted once.
  - Damage to an empty slot, an invalid slot index, or a zero/negative amount does nothing. Overkill damage is not carried to other blocks.
  - Every HP change that doesn't break the block emits `block_damaged(slot: int, hp: float)`.
  - `tick(delta: float) -> void`: advances respawn countdowns; when one reaches 0 a new block spawns in that slot and `block_spawned(slot: int)` is emitted.
  - `lowest_hp_slot() -> int`: slot with the lowest current HP among slots that have a block; ties -> lowest index; -1 if all are empty.
  - Read access: `slot_count()`, `has_block(slot)`, `hp(slot)`, `max_hp(slot)`, `destroyed_count`.
- Scene `scenes/field/field.tscn` (root `Control`, script `field.gd`) owning a `BlockField`:
  - Shows `slot_count` placeholder blocks (coloured squares) in fixed positions in the upper part of the portrait screen (e.g. a row of 3 above a row of 2), each with an **HP bar** under it (D-023).
  - Empty slots show nothing; the HP bar updates on `block_damaged`, `block_broken` and `block_spawned` - never by polling in `_process`.
  - The scene **never** calls `tick` itself: time is advanced only by the simulation clock (architecture A-03, section 4.4; added in #5). Until then, tests call `tick` directly.
  - Receives its `BlockField` through a `setup(field: BlockField)` method (architecture section 5).
  - Added to the main scene.

## Acceptance criteria

- [ ] [test] A new `BlockField` with the default config has 5 blocks, each with HP 10 and gold 1.
- [ ] [test] Damage below HP lowers HP and emits `block_damaged` with the new HP; damage reaching 0 breaks the block, empties the slot, increments `destroyed_count` and emits `block_broken` once with the block's gold (no `block_damaged`).
- [ ] [test] Damaging an empty or invalid slot, or with amount <= 0, changes nothing and emits nothing.
- [ ] [test] A broken slot respawns after exactly `respawn_delay` seconds of `tick` (not before), emitting `block_spawned`; the new block's HP equals `block_hp(destroyed_count)` at that moment.
- [ ] [test] `lowest_hp_slot()` returns the lowest-HP block, the lowest index on ties, and -1 when every slot is empty.
- [ ] [test] Integration: the field scene, set up with a `BlockField`, shows 5 block nodes with HP bars; damaging slot 0 through that `BlockField` updates slot 0's HP bar value; breaking it hides that block until `tick` respawns it.
- [ ] [test] The field scene has no `_process` / `_physics_process` that calls `tick`.
- [ ] [manual] Five blocks with HP bars are visible and readable at 540 x 960 and on a taller window.

## Assets

Placeholder OK (coloured squares).

## Out of scope

- Tap input and gold (issue #5); team damage (issue #7).
- Damage numbers, flashes, break effects (D-023: HP bar only).
- Saving current block HP (blocks start fresh after load, see #8).

## Notes

D-009, D-013, D-014, D-015, D-017, D-018, D-023. Architecture: A-01, A-02, A-03, sections 4.2 and 5. Depends on #3.
