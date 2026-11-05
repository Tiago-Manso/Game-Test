Status: done

Quality review, issue #1 "Project skeleton", round 1, HEAD 2e6aeff (PR #15).

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
- [Q1-m1] scenes/main/main.tscn:3 - The root `Main` Control keeps the default `mouse_filter = STOP` (only `Background` is set to ignore). Once gameplay nodes rely on `_unhandled_input` for taps (mouse emulates touch, D-022), a full-rect STOP root takes the mouse events in the GUI pass first, so they never reach `_unhandled_input`. Nothing reads input yet, so nothing breaks today. Suggestion: set the root to `mouse_filter = 2` (ignore) or `1` (pass), either now or in the first input issue, so the first gameplay PR doesn't hit this.

## What I ran
(in a private worktree at 2e6aeff, Godot 4.5.1, gdtoolkit from ~/.local/bin)
- `godot --headless --path . --import`: exit 0 (only the usual "ObjectDB instances leaked at exit" warning from the editor plugin on import, not an error)
- `gdlint scenes scripts test`: exit 0, "no problems found"
- `gdformat --check scenes scripts test`: exit 0, 2 files unchanged
- GUT command from CLAUDE.md: exit 0, 2 scripts, 8/8 tests, 11 asserts
- `godot --headless --path . --quit-after 30`: exit 0, no errors
- `godot --headless --editor --path . --quit`: exit 0; `git status` clean afterwards, so the editor does not rewrite project.godot / main.tscn / .import / .uid files
- Checked project.godot against the spec (540x960, resizable, canvas_items, keep_width, orientation=1 == SCREEN_PORTRAIT, emulate touch, main scene, GUT plugin enabled, features 4.5); main.tscn has a Control root `Main` with a full-rect placeholder ColorRect
- GUT 9.5.0 vendored only under addons/gut/ (with LICENSE.md, .uid and .import files, as Godot 4.4+ expects). No .gutconfig.json needed because the CLI flags are in the command. addons/ is outside the lint/format paths, so leaving out gdlintrc/.gdformatrc is in line with the spec ("only if needed")
