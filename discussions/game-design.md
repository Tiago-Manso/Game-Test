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
- **5** blocks on screen at once, in **fixed slots** (D-009, D-014, D-017).
- A broken block is replaced in the same slot after **0.5 s** (D-014, D-018).
- Each block shows an **HP bar**; no other hit effects yet (D-023).
- Each block has HP; it breaks at 0 and pays gold.
- HP and gold reward of new blocks scale with **total blocks destroyed** (D-015).

### Tapping
- Tapping a block deals **tap damage** to it.
- Tap damage has a level that the player raises with gold (D-011).

### Team (auto-damage)
- **3 unit types** - Pistol, Shotgun, Rocket - each costlier and stronger than the last (D-010, D-019).
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
- Progress auto-saves locally every 10 s and on pause/quit, and loads on start (D-012, D-024).

### Not in milestone 1
Levels and boss timers, prestige / Time Warp, active abilities, offline
earnings, milestone multipliers, real art, sound, monetisation.

## Decisions from refining milestone 1 (2026-10-29)

- D-017 5 block slots (was Q-001).
- D-018 Respawn delay 0.5 s (was Q-002).
- D-019 Units are Pistol, Shotgun, Rocket (was Q-003).
- D-020 Block HP, gold and upgrade costs grow exponentially (`base * growth^n`); damage per level grows linearly.
- D-021 Numbers are plain `float` behind `NumberFormat` / `BalanceConfig`, swappable for a big-number type later (was Q-006).
- D-022 Desktop: 540x960 resizable window; mouse click acts as tap (was Q-007).
- D-023 Hit feedback in the prototype is an HP bar per block only - no damage numbers, flashes or break effects (was Q-004).
- D-024 Auto-save every 10 s and on pause, focus-out and quit (was Q-005).
- D-025 Settings live in a panel behind a gear button on the HUD; notation is its only option for now (was Q-008).
- D-026 Milestone 1 is split into issues #1-#9, all labelled `ready`; the loop waits until an issue's `Depends on #n` issues are closed.

## Open questions

None for milestone 1.

## Milestone 1 issues

| # | Issue | Spec | Depends on |
|---|-------|------|------------|
| 1 | Project skeleton | `specs/1-project-skeleton.md` | - |
| 2 | Number formatting | `specs/2-number-formatting.md` | #1 |
| 3 | Balance config | `specs/3-balance-config.md` | #1 |
| 4 | Blocks and slots | `specs/4-blocks-and-slots.md` | #3 |
| 5 | Tap damage and gold | `specs/5-tap-damage-and-gold.md` | #2, #4 |
| 6 | Tap damage upgrade | `specs/6-tap-damage-upgrade.md` | #5 |
| 7 | Team units | `specs/7-team-units.md` | #5 |
| 8 | Save and load | `specs/8-save-and-load.md` | #6, #7 |
| 9 | Notation setting | `specs/9-notation-setting.md` | #8 |

## Later milestones (parked)

- Levels with a boss and timer every few levels.
- Prestige (Time Warp) with a permanent currency.
- Active abilities on cooldown.
- Offline earnings.
- Milestone multipliers on unit levels.
- Real art (Blender pre-renders or pixel art), sound.
- Steam build.
