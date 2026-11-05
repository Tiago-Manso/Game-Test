Status: done
Issue: #1 Project skeleton   Round: 1   Branch: loop/issue-1-project-skeleton @ 2e6aeff

VERDICT: NO BLOCKING ISSUES

## Criterion -> test map
| # | Criterion | Test(s) | Covered |
|---|-----------|---------|---------|
| 1 | [test] viewport 540x960 | test/unit/test_project_settings.gd `test_viewport_is_540_by_960` | yes (both numbers) |
| 1 | [test] stretch mode canvas_items | `test_stretch_mode_is_canvas_items` | yes |
| 1 | [test] aspect keep_width | `test_stretch_aspect_is_keep_width` | yes |
| 1 | [test] orientation portrait | `test_handheld_orientation_is_portrait` (DisplayServer.SCREEN_PORTRAIT) | yes |
| 1 | [test] emulate touch from mouse on | `test_mouse_emulates_touch` | yes |
| 1 | [test] main scene is res://scenes/main/main.tscn | `test_main_scene_is_main_tscn` (resolves uid:// too) | yes |
| - | requirement: window resizable (not in criterion 1 list) | `test_window_is_resizable` | yes (passes in red too: Godot default is true; still fails if set false) |
| 2 | [test] main scene root is Control named Main | test/integration/test_main_scene.gd `test_main_scene_root_is_control_named_main` | yes (load, instantiate, type, name) |
| 3 | [test] import/lint/format/test exit 0 | reviewer run (below) | yes, all 0 |
| 4 | [manual] window + placeholder background | n/a (PO) | manual |
| - | requirement: project name "Game-Test", features from .godot-version, GUT plugin enabled | none | see T1-m1 |

## TDD
- c48cf6f [red] touches only test/unit/test_project_settings.gd (+ implementer log); 4dff6df [green] only project.godot.
- 586d2e0 [red] touches only test/integration/test_main_scene.gd (+ log); 97aa6b7 [green] adds main.tscn (+ .gd.uid files).
- 981d7cf (background) is production code without a test; it is demanded by the [manual] criterion, so acceptable.
- No test weakened, skipped, deleted or made pending across the branch.

## Critical
(none)

## Important
(none)

## Minor
- [T1-m1] general - Spec requirements with no test: project name "Game-Test", `config/features` matching the pinned `.godot-version` (4.5), and the GUT plugin listed in `editor_plugins/enabled`. Not [test] criteria and not runtime behaviour, so Minor; a cheap guard would catch drift when Godot is bumped. Suggested: add `test_project_name_is_game_test`, `test_features_match_godot_version` (read `res://.godot-version`, compare major.minor) and `test_gut_plugin_enabled` to test_project_settings.gd.
- [T1-m2] scenes/main/main.tscn:18 - The placeholder `Background` sets `mouse_filter = 2` (ignore) so it won't swallow taps meant for later UI; nothing tests it. Harmless now (no input yet), but a regression to STOP would silently eat input in later issues. Suggested: in test_main_scene.gd assert the Background child exists and has `mouse_filter == Control.MOUSE_FILTER_IGNORE`, or leave to the first issue that adds input.

## What I ran
- Red check (own worktree at c48cf6f): import exit 0; test command exit 1 - 6/7 tests fail on assertions ([1152] expected [540], [648] expected [960], "disabled" vs "canvas_items", "keep" vs "keep_width", 0 vs 1, emulate touch false, "" vs main.tscn path); resizable passes (Godot default). Failure is on the assertions, not a parse/load error.
- Head (own worktree at 2e6aeff): import exit 0 (only "ObjectDB instances leaked at exit" warning from the import run); `gdlint scenes scripts test` exit 0; `gdformat --check scenes scripts test` exit 0; GUT test command exit 0, 2 scripts, 8/8 tests, 11 asserts, all passed. Worktree clean after the run (no stray files outside .godot/).
- Next round: check red 586d2e0.
