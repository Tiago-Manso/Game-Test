# Project skeleton

- Issue: #1
- Status: ready

## Context

First issue of milestone 1 (see `discussions/game-design.md`). Creates the
Godot project and test setup every later issue builds on. Implements D-007
(portrait) and D-022 (desktop window, mouse acts as tap).

## Requirements

- `project.godot` at the repo root, Godot version from `.godot-version`, project name "Game-Test".
- Main scene `scenes/main/main.tscn` (root `Control` named `Main`), set as the run scene. Empty apart from a placeholder background.
- Display settings:
  - viewport 540 x 960, window resizable;
  - stretch mode `canvas_items`, aspect `keep_width` (taller phones get more vertical space, never horizontal bars);
  - handheld orientation `portrait`;
  - mouse emulates touch (`input_devices/pointing/emulate_touch_from_mouse = true`).
- GUT vendored in `addons/gut/` (a release compatible with the pinned Godot version), plugin enabled.
- The commands in `CLAUDE.md` (import, lint, format check, test) work unchanged; add `gdlintrc` / `.gdformatrc` only if needed for GUT or Godot conventions. Exclude `addons/` from lint/format.
- If a command in `CLAUDE.md` turns out to be wrong for the pinned versions, fix it in `CLAUDE.md`.

## Acceptance criteria

- [ ] [test] `test/unit/test_project_settings.gd` asserts: viewport 540 x 960, stretch mode `canvas_items`, aspect `keep_width`, orientation portrait, emulate touch from mouse on, main scene is `res://scenes/main/main.tscn`.
- [ ] [test] `test/integration/test_main_scene.gd` instantiates the main scene and asserts its root is a `Control` named `Main`.
- [ ] [test] The import, lint, format check and test commands from `CLAUDE.md` all exit with code 0 (reviewer and PO run them).
- [ ] [manual] `godot --path .` opens a 540 x 960 window with the placeholder background; resizing keeps the layout portrait.

## Assets

None (placeholder background colour).

## Out of scope

- Any gameplay, HUD or blocks.
- Export presets / builds for mobile or desktop.
- CI workflow (separate issue later).

## Notes

D-007, D-022. Depends on nothing.
