# Tap damage upgrade

- Issue: #6
- Status: ready

## Context

First thing gold can buy: stronger taps (D-011).

## Requirements

- A tap-upgrade button in the lower part of the screen (shop area) showing the current tap damage, the current level and the cost of the next level, all via `NumberFormat`. e.g. `Tap Lv 3 - 3 dmg - Upgrade: 5.72`.
- Pressing it when `GameState.can_afford(tap_upgrade_cost(tap_level))`: spends the cost and raises `tap_level` by 1. New taps use the new damage immediately.
- When gold is not enough, the button is disabled; it re-enables as soon as gold reaches the cost (react to `gold_changed`).
- `GameState` emits `tap_level_changed(level: int)`.
- One press buys one level.

## Acceptance criteria

- [ ] [test] Buying at level 1 with enough gold costs `tap_upgrade_cost(1)` (5 with default config) and sets level 2; tap damage becomes `tap_damage(2)`.
- [ ] [test] With less gold than the cost, pressing does nothing (gold and level unchanged) and the button is disabled.
- [ ] [test] The button becomes enabled the moment gold reaches the cost and disabled again after buying if the next level is unaffordable.
- [ ] [test] The button text shows level, damage and next cost formatted with `NumberFormat`.
- [ ] [test] Integration: after an upgrade, a tap on a block deals the new tap damage.
- [ ] [manual] The button is easy to hit with a thumb in portrait.

## Assets

Placeholder OK.

## Out of scope

- Buy x10 / buy max.
- Milestone multipliers (D-011: none in the prototype).

## Notes

D-011, D-020. Depends on #5.
