# Notation setting

- Issue: #9
- Status: ready

## Context

Players can switch big numbers between suffixes and scientific notation
(D-016). The toggle lives in a settings panel behind a gear button (D-025),
which is also where future settings go.

## Requirements

- A gear button in a top corner of the HUD opens a settings panel (modal, with a close button). Tapping outside it or the close button closes it.
- The panel has one option: Number format - Suffix (`1.23K`) / Scientific (`1.23e3`). Default Suffix.
- `GameState` gains `notation: NumberFormat.Notation` and signal `notation_changed`.
- Changing it updates **every** number on screen immediately: gold, DPS, tap upgrade button, unit rows.
- The setting is saved and loaded with the game (extend #8's save; a file without the field loads as Suffix).
- While the panel is open, taps don't reach blocks behind it.

## Acceptance criteria

- [ ] [test] Gear button opens the panel; close button closes it.
- [ ] [test] Selecting Scientific sets `GameState.notation` and every number label in HUD and shop re-renders in scientific notation (check gold label and one unit row with values >= 1000).
- [ ] [test] The setting survives save and load; an old save without it loads as Suffix.
- [ ] [test] A click on a block position while the panel is open does not damage the block.
- [ ] [manual] The gear button and panel are usable with a thumb on a phone-sized window.

## Assets

Placeholder OK (text "⚙" or a simple icon).

## Out of scope

- Other settings (sound, language).

## Notes

D-016, D-025. Depends on #8.
