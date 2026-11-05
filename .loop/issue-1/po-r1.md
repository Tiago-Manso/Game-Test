Status: done

DECISION: GO

## Acceptance criteria
| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | [test] test_project_settings.gd asserts viewport 540x960, stretch canvas_items, aspect keep_width, orientation portrait, emulate touch from mouse on, main scene res://scenes/main/main.tscn | met | test/unit/test_project_settings.gd: one test per setting (plus resizable), exact values from the spec; orientation compared with DisplayServer.SCREEN_PORTRAIT; main scene resolved through uid:// if stored that way. 7/7 pass. Red run c48cf6f failed on the default values (1152x648, disabled, keep, 0, false, ""). |
| 2 | [test] test_main_scene.gd instantiates the main scene, root is a Control named Main | met | test/integration/test_main_scene.gd::test_main_scene_root_is_control_named_main loads, instantiates (add_child_autofree), asserts `is Control` and name == &"Main". Passes; red run 586d2e0 failed on null scene. |
| 3 | [test] import, lint, format check, test commands from CLAUDE.md exit 0 | met | Run by PO in a fresh worktree at cea7a62 with Godot 4.5.1.stable: import 0 (only the stock "ObjectDB instances leaked at exit" warning), `gdlint scenes scripts test` 0, `gdformat --check scenes scripts test` 0, GUT 0 (2 scripts, 8 tests, 11 asserts, all passed, no errors/orphans). Import left the tree clean. |
| 4 | [manual] `godot --path .` opens a 540x960 window with the placeholder background; resizing keeps the layout portrait | met by inspection | project.godot: viewport 540x960, no window size override (so window opens at 540x960), resizable, canvas_items + keep_width. scenes/main/main.tscn: full-rect anchored Control root and full-rect ColorRect `Background` (0.12, 0.13, 0.18), so it fills the expanded area. keep_width: taller window -> more vertical space; wider -> side bars only. Implementer listed the steps. |

## Requirements, scope, assets
- project.godot at root, name "Game-Test", config/features "4.5" matching .godot-version 4.5.1-stable: yes.
- Main scene set as run scene; empty apart from the placeholder background: yes.
- GUT 9.5.0 (4.5 line) vendored in addons/gut/, plugin enabled in [editor_plugins]: yes.
- CLAUDE.md commands unchanged and working; no gdlintrc/.gdformatrc needed; addons/ excluded because the commands only list scenes/scripts/test: yes. CLAUDE.md not modified (no fix needed).
- Out of scope respected: no gameplay/HUD/blocks, no export_presets.cfg, no CI workflow.
- Assets: none required; placeholder colour as the spec allows.
- Issue comments: only the loop pickup comment; nothing to honour.

## Deferred and minor findings
All 9 Minors (Q1-m1, S1-m1, T1-m1, T1-m2, P1-m1, P1-m2, P1-m3, G1-m1, G1-m2) reviewed: none is something a player hits in this feature (there is no input handling or export yet). Q1-m1 (root mouse_filter STOP) and G1-m1 (touch + emulated mouse double events) matter for the first input issue (#5) and should be picked up there; S1-m1/P1-m3 and P1-m2 belong to the export/mobile issue.

## NO-GO reasons
None.

## Manual checks (non-blocking)
- `godot --path .`: window opens at 540x960, filled with dark blue-grey (no grey default clear colour visible).
- Drag the window taller: the background still fills it, content gets more vertical space, no top/bottom bars.
- Drag it wider: side bars (pillarbox) appear, never top/bottom bars.
- Risk: on a screen shorter than 960 px (e.g. a 768 px laptop) the window may open taller than the screen; if so, consider a window size override (e.g. 405x720) in a follow-up, not in this issue.
- Click inside the window: nothing happens and no errors print (no input handling yet).
- Follow-ups already in tech debt: root mouse_filter and touch/mouse double-event handling before #5; export filters and renderer choice in the export issue.

## What I ran
- Fresh worktree at cea7a62 (removed afterwards): `godot --headless --path . --import` 0; `gdlint scenes scripts test` 0; `gdformat --check scenes scripts test` 0; GUT command 0 (8/8 passed).
