# Game design - current state

Consolidated from the discussion logs in this folder. Decision IDs point to the
session where they were made. Last updated: 2026-10-29.

## Concept

An incremental / idle clicker in the style of **Time Clickers**: the player
taps blocks to break them for gold, and spends gold on a team of guns that
damage blocks automatically. Abstract "shooting blocks" theme (D-006).

- Platforms: mobile first (portrait, D-007), desktop too; maybe Steam later (D-003).
- Art: placeholder shapes until the loop is fun (D-004).

## Milestone 1 - prototype (D-002, D-005)

Goal: prove the core loop is fun. In scope:

### Blocks
- Several blocks on screen at once, in **fixed slots** (D-009, D-014).
- A broken block is replaced in the same slot after a short delay (D-014).
- Each block has HP; it breaks at 0 and pays gold.
- HP and gold reward of new blocks scale with **total blocks destroyed** (D-015).

### Tapping
- Tapping a block deals **tap damage** to it.
- Tap damage has a level that the player raises with gold (D-011).

### Team (auto-damage)
- **3 unit types**, each costlier and stronger than the last (D-010).
- Each unit type has a level, bought with gold; cost grows each level and
  damage per second grows with level (D-011).
- All units always shoot the block with the **lowest current HP** (D-013).

### Economy and UI
- Gold balance shown on screen.
- Numbers formatted with short suffixes (K, M, B, T, aa, ab, ...), with a setting
  for scientific notation (D-016).
- Every balance number (HP curve, gold curve, costs, damage, slot count,
  respawn delay) lives in config data, not in code (D-008).

### Saving
- Progress auto-saves locally and loads on start (D-012).

### Not in milestone 1
Levels and boss timers, prestige / Time Warp, active abilities, offline
earnings, milestone multipliers, real art, sound, monetisation.

## Open questions

- Q-001 How many block slots? (Proposal: 5.)
- Q-002 Respawn delay? (Proposal: 0.5 s, in config.)
- Q-003 Unit names and look (proposal: Pistol, Rifle, Cannon as placeholder names).
- Q-004 Feedback on tap/hit/break: damage numbers, flash, shake? (Proposal: floating damage number + flash.)
- Q-005 When to auto-save: on interval, on purchase, on quit? (Proposal: every 10 s and on quit/pause.)
- Q-006 Number type: plain `float` reaches ~1e308, enough for the prototype; a
  big-number type may be needed later. (Proposal: `float` now, behind one
  formatting/maths helper so it can be swapped.)
- Q-007 Desktop window size and input (mouse click = tap). (Proposal: 540x960 window, resizable, keeping aspect.)
- Q-008 Where is the settings toggle for scientific notation? (Proposal: a small settings button on the HUD.)

## Proposed issue breakdown for milestone 1

Ready to spec once the open questions above are answered or the proposals accepted.
Order is the build order; each should be one reviewable PR.

1. **Project skeleton** - Godot project, portrait stretch settings, GUT vendored, main scene, one passing test.
2. **Number formatting** - suffix and scientific formatting helper (pure logic).
3. **Balance config** - one config resource with every tunable number and the scaling formulas.
4. **Blocks and slots** - slots, block HP, break, respawn delay, scaling by blocks destroyed.
5. **Tap damage and gold** - tapping damages a block; breaking pays gold; gold HUD.
6. **Tap damage upgrade** - buy tap-damage levels.
7. **Team units** - 3 unit types, buy/level up, DPS, lowest-HP targeting.
8. **Save and load** - local auto-save and load on start.
9. **Settings: number notation** - toggle between suffix and scientific.

## Later milestones (parked)

- Levels with a boss and timer every few levels.
- Prestige (Time Warp) with a permanent currency.
- Active abilities on cooldown.
- Offline earnings.
- Milestone multipliers on unit levels.
- Real art (Blender pre-renders or pixel art), sound.
- Steam build.
