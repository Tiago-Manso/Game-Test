Status: done
Issue: #1 Project skeleton   Attempt: 1/2
Branch: loop/issue-1-project-skeleton

## Setup (bootstrap, before any test can run)
- GUT 9.5.0 (Godot 4.5.x line, tag v9.5.0 = 8255c6305761754748f9fd641da5fd8f51c1708a) vendored in `addons/gut/`.
- Minimal `project.godot`: name "Game-Test", features 4.5, GUT plugin enabled. No display/input settings yet (those are demanded by tests).
- `scripts/.gitkeep` so `gdlint scenes scripts test` has a directory to read.

## [test] criteria
| # | Criterion | Status | Red | Green | Refactor |
|---|-----------|--------|-----|-------|----------|
| 1 | test_project_settings.gd: viewport, stretch, aspect, orientation, emulate touch, main scene | green (no refactor needed) | c48cf6f | 4dff6df | - |
| 2 | test_main_scene.gd: root is Control named Main | green (no refactor needed) | 586d2e0 | 97aa6b7 | - |
| 3 | import, lint, format check, test commands exit 0 | green | (observed, no commit: lint exit 1 'Cannot open file scenes') | 97aa6b7 (scenes/ exists; scripts/.gitkeep in 9fc93ad) | - |

## Manual criteria
- [manual] window 540x960 with placeholder background, resizing stays portrait: implemented in 981d7cf - full-rect ColorRect `Background`, colour (0.12, 0.13, 0.18), mouse_filter ignore. Headless smoke run `--quit-after 30` exits 0.

## Findings
(none yet)

## Red 1 failures seen
- viewport_width [1152] expected [540]; height [648] expected [960]; stretch mode ["disabled"]; aspect ["keep"]; orientation [0] expected [1]; emulate touch false; main scene [""]. Resizable passes already (Godot default true) - kept as a guard for the requirement.

## Red 2 failure seen
- Expected [<null>] to be anything but NULL: main scene loads as a PackedScene (plus GUT 'Unexpected Errors' from load of the missing file).

## Last checks (fresh worktree at 97aa6b7, re-run after background)
- import: exit 0
- lint: exit 0
- format: exit 0
- test: exit 0, 8/8 passed
- Final run in a fresh worktree after 981d7cf: import 0, lint 0, format 0, test 0 (8/8).

## Notes
- CLAUDE.md commands work unchanged with Godot 4.5.1 + gdtoolkit 4.5.0; no gdlintrc/.gdformatrc needed (commands only list scenes/scripts/test, so addons/ is never linted).
- Spec status set to in-review; [test] criteria ticked; [manual] left for the PO.
