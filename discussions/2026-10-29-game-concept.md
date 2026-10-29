# 2026-10-29 - Game concept, round 1

Participants: Tiago, Claude

## Asked and answered

| Question | Answer |
|----------|--------|
| What kind of 2D game? | Similar to **Time Clickers**, for mobile first; maybe Steam later. |
| First version size? | **Small prototype** - one core loop, prove it's fun first. |
| Platforms? | **Desktop** (Windows/Mac/Linux) and **Mobile**. |
| Visual style? | **Placeholder** shapes for now. |

## Reference: Time Clickers (Claude's recollection - to confirm)

An incremental / idle clicker shooter:

- You tap/click targets (blocks) to destroy them and earn gold.
- Gold buys and upgrades a **team** of guns that deal damage automatically (idle DPS).
- Levels have a fixed number of targets; every few levels is a **boss level**
  with a time limit - fail it and you drop back to farm.
- **Active abilities** on cooldown (e.g. more gold, more damage, auto-fire).
- **Time Warp** prestige: reset progress for a permanent currency that boosts
  the next run.
- **Offline earnings** while the game is closed.
- Numbers grow huge, so they're shown in short / scientific notation.

## Decisions

- D-001 Genre: incremental / idle clicker in the style of Time Clickers.
- D-002 First milestone is a small prototype of the core loop.
- D-003 Targets: mobile first, desktop too; Steam is a possible later step.
- D-004 Placeholder art until the loop is fun.

---

# Round 2 - prototype scope

| Question | Answer |
|----------|--------|
| What's in the first prototype? | **Tap to damage + gold** and the **auto-damage team with upgrades**. Levels/bosses, prestige, abilities and offline earnings are later. |
| Theme? | **Same idea as Time Clickers: shooting blocks.** |
| Mobile orientation? | **Portrait.** |
| Session length / pacing? | **Tune later** - every number lives in config, balance once playable. |

- D-005 Prototype = tap damage + gold + auto-damage team with upgrades. Nothing else.
- D-006 Theme: shooting blocks, abstract, Time Clickers-like.
- D-007 Portrait orientation (desktop shows a tall window).
- D-008 All balance numbers in data/config, no hard-coded values; tune once playable.

# Round 3 - core loop details

| Question | Answer |
|----------|--------|
| How do targets keep coming without levels? | **Several blocks on screen** at once. |
| How many unit types? | **3.** |
| What can gold buy? | **Tap damage levels** and **unit levels**. No milestone multipliers yet. |
| Save between sessions? | **Yes, local save.** |

- D-009 Several blocks are on screen at the same time.
- D-010 Three auto-damage unit types, each costlier and stronger than the last.
- D-011 Gold buys tap-damage levels and unit levels; costs grow per level. No milestone multipliers in the prototype.
- D-012 Progress auto-saves locally and loads on start.

# Round 4 - targeting, layout, scaling, numbers

| Question | Answer |
|----------|--------|
| Which block do units shoot? | **Lowest HP first.** |
| Block layout? | **Fixed slots**; a broken block is replaced after a short delay. |
| What makes blocks tougher? | **Total blocks destroyed** - each break slightly raises HP and gold of new blocks. |
| Big number display? | **Short suffixes by default, with a setting for scientific notation.** |

- D-013 Units always target the block with the lowest current HP.
- D-014 Blocks sit in fixed slots and respawn after a short delay.
- D-015 Block HP and gold reward scale with the total number of blocks destroyed.
- D-016 Numbers show as suffixes (K, M, B, T, then aa, ab, ...); a setting switches to scientific.
