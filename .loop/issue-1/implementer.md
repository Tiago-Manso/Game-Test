Status: in progress
Issue: #1 Project skeleton   Attempt: 1/2
Branch: loop/issue-1-project-skeleton

## Setup (bootstrap, before any test can run)
- GUT 9.5.0 (Godot 4.5.x line, tag v9.5.0 = 8255c6305761754748f9fd641da5fd8f51c1708a) vendored in `addons/gut/`.
- Minimal `project.godot`: name "Game-Test", features 4.5, GUT plugin enabled. No display/input settings yet (those are demanded by tests).
- `scripts/.gitkeep` so `gdlint scenes scripts test` has a directory to read.

## [test] criteria
| # | Criterion | Status | Red | Green | Refactor |
|---|-----------|--------|-----|-------|----------|
| 1 | test_project_settings.gd: viewport, stretch, aspect, orientation, emulate touch, main scene | todo | - | - | - |
| 2 | test_main_scene.gd: root is Control named Main | todo | - | - | - |
| 3 | import, lint, format check, test commands exit 0 | todo | - | - | - |

## Manual criteria
- [manual] window 540x960 with placeholder background, resizing stays portrait: todo

## Findings
(none yet)

## Last checks
- import: exit 0 (setup)
- lint: exit 0 (setup)
- format: exit 0 (setup)
- test: exit 0, nothing run yet (setup)
