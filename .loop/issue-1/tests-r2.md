Status: done
Issue: #1 Project skeleton   Round: 2   Branch: loop/issue-1-project-skeleton @ facc4d6

VERDICT: NO BLOCKING ISSUES

## Criterion -> test map
| # | Criterion | Test(s) | Covered |
|---|-----------|---------|---------|
| 1 | [test] viewport 540 x 960 | test/unit/test_project_settings.gd `test_viewport_is_540_by_960` | yes (both numbers) |
| 1 | [test] stretch mode canvas_items | `test_stretch_mode_is_canvas_items` | yes |
| 1 | [test] aspect keep_width | `test_stretch_aspect_is_keep_width` | yes |
| 1 | [test] orientation portrait | `test_handheld_orientation_is_portrait` (DisplayServer.SCREEN_PORTRAIT) | yes |
| 1 | [test] emulate touch from mouse on | `test_mouse_emulates_touch` | yes (mutation: removing the line fails) |
| 1 | [test] main scene is res://scenes/main/main.tscn | `test_main_scene_is_main_tscn` | yes (mutation: a uid:// for the same scene passes, an unknown uid fails) |
| - | requirement: window resizable | `test_window_is_resizable` | yes (mutation: resizable=false fails) |
| 2 | [test] main scene root is a Control named Main | test/integration/test_main_scene.gd `test_main_scene_root_is_control_named_main` | yes (mutations: root type Node2D fails, root name "Root" fails, missing file fails) |
| 3 | [test] import/lint/format/test exit 0 | reviewer run (below) | yes, all 0 |
| 4 | [manual] window + placeholder background | n/a (PO) | manual |
| - | name / features / GUT plugin; Background mouse_filter | none | already logged as T1-m1 / T1-m2 |

## TDD
- c48cf6f [red] -> 4dff6df [green]: verified in round 1 (6/7 fail on assertions).
- 586d2e0 [red] -> 97aa6b7 [green]: verified this round (below). Red commit touches only test/integration/test_main_scene.gd + implementer log; green adds main.tscn (+ test .gd.uid files).
- Criterion 3 red was observed but not committed (lint failed for lack of `scenes/`); acceptable, nothing to commit for a command check.
- No test weakened, skipped, deleted or made pending anywhere on the branch. Only change since round 1 is `.loop/` logs.

## Critical
(none)

## Important
(none)

## Minor
(none new)

## Earlier findings
- [T1-m1] logged as tech debt (Minor), not fixed in this PR - as agreed.
- [T1-m2] logged as tech debt (Minor), not fixed in this PR - as agreed.

## What I ran
- Red check (own worktree at 586d2e0): import exit 0; test command exit 1 - 8 tests, 7 passing, 1 failing: `test_main_scene_root_is_control_named_main` fails on the assertion "Expected [<null>] to be anything but NULL: main scene loads as a PackedScene" (plus GUT "Unexpected Errors" from loading the missing file). Not a parse/load error of the test script.
- Head (own worktree at facc4d6): import exit 0; `gdlint scenes scripts test` exit 0 ("no problems found"); `gdformat --check scenes scripts test` exit 0 (2 files unchanged); GUT test command exit 0, 8/8 tests passing, 11 asserts. No stray files after the run (only ignored .godot/).
- Mutation checks at head (each reverted): root type Node2D -> fails "root is a Control"; root name "Root" -> fails eq Main; resizable=false -> fails; emulate_touch line removed -> fails; main_scene = uid of main.tscn -> passes (correct); main_scene = unknown uid -> fails. Failure output for assert_true without a message still shows test name and line, so diagnosable.
- Worktrees removed; `git worktree list` shows only the shared checkout.
