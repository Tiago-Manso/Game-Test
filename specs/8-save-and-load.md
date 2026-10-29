# Save and load

- Issue: #8
- Status: ready

## Context

Progress must survive closing the game, including mobile apps being killed in
the background (D-012, D-024).

## Requirements

- `scripts/core/save_game.gd`, `class_name SaveGame`, path injectable (default `user://save.json`) so tests use a temp path.
- JSON content: `version: 1`, `gold`, `tap_level`, `unit_levels` (by unit id), `destroyed_count`. Settings added in #9 go in the same file.
- `save(state, destroyed_count)` writes atomically: write to `save.json.tmp`, then rename over `save.json`.
- `load()`:
  - no file -> new game defaults;
  - valid file -> restore all fields;
  - unreadable or invalid JSON / wrong types -> rename it to `save.json.bad`, start a new game, `push_warning`;
  - unknown unit ids are ignored; units missing from the file get level 0;
  - negative or non-numeric values fall back to defaults for that field.
- On start the game loads before the field is created, so `BlockField` starts from the saved `destroyed_count` (blocks spawn fresh at full HP; current block HP is not saved).
- Auto-save every `autosave_interval` seconds (10), and on `NOTIFICATION_APPLICATION_PAUSED`, `NOTIFICATION_APPLICATION_FOCUS_OUT` and `NOTIFICATION_WM_CLOSE_REQUEST`.

## Acceptance criteria

- [ ] [test] Saving then loading restores gold, tap level, every unit level and destroyed count exactly.
- [ ] [test] Loading with no file gives a new game (0 gold, tap level 1, units 0, destroyed 0).
- [ ] [test] A corrupt file (invalid JSON) and a file with wrong types each give a new game, are renamed to `.bad`, and don't crash.
- [ ] [test] Unknown unit ids are ignored; missing units load as level 0.
- [ ] [test] Save is atomic: after a save, no `.tmp` file remains and `save.json` parses.
- [ ] [test] Auto-save fires after `autosave_interval` seconds of game time and on the pause/focus-out/close notifications (simulate via `notification()`).
- [ ] [test] Integration: a game started with a save of `destroyed_count = 10` spawns blocks with HP `block_hp(10)`.
- [ ] [manual] On desktop: play, close the window, reopen - gold, levels and block toughness are back.

## Assets

None.

## Out of scope

- Offline earnings (later milestone).
- Cloud saves, multiple slots, save migration beyond version 1.

## Notes

D-012, D-024. Depends on #6 and #7.
