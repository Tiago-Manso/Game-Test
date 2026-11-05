Status: done

General review, issue #1 "Project skeleton", round 1, HEAD 1f08893 (PR #15).

VERDICT: NO BLOCKING ISSUES

## Solved findings check
No finding in state.md has status `fixed`: all 7 (Q1-m1, S1-m1, T1-m1, T1-m2, P1-m1, P1-m2, P1-m3) are Minor and `logged`. No fix commits exist, and every commit after 981d7cf/d8452fd changed only `.loop/`. So nothing can have regressed.
- Q1-m1 logged - scenes/main/main.tscn:3 unchanged (root mouse_filter default STOP)
- S1-m1 logged - export filters out of scope, export_presets.cfg git-ignored
- T1-m1 logged - name/features/plugin still untested
- T1-m2 logged - Background mouse_filter = 2 still present, untested
- P1-m1 logged - ColorRect background unchanged
- P1-m2 logged - no renderer set
- P1-m3 logged - same as S1-m1 (export filters); duplicate, can be merged into one tech-debt line
Severities checked: all correctly Minor. Q1-m1 matters even less than stated, because architecture section 5 uses `gui_input` on block Controls, and children get it before a STOP parent.

## Critical
(none)

## Important
(none)

## Minor
- [G1-m1] general - With `emulate_touch_from_mouse = true` (this PR, D-022) and the default `emulate_mouse_from_touch = true`, one physical click reaches a Control's `gui_input` twice. Verified under Xvfb: `Input.parse_input_event(<left press>)` gave a block Control `["InputEventScreenTouch pressed", "InputEventMouseButton pressed"]`. A touch on a phone also arrives twice, as ScreenTouch plus an emulated MouseButton. Spec #5 ("one tap = one hit") and architecture section 5 ("each block is a Control with `gui_input`") don't say which event to handle. A handler that accepts both deals double damage. Spec #5's integration tests would probably not catch it: `Viewport.push_input` / a direct `gui_input` call skip `Input`'s emulation, so one synthetic event gives one hit. This PR is correct as it stands. It could become a real bug in #5, which is the case for rating it higher. Fix (for #5): handle exactly one event type, e.g. `InputEventScreenTouch` with `pressed`, which arrives on both desktop and mobile with these settings. Add a test that sends a click through `Input.parse_input_event` and asserts exactly one hit, or note this in spec #5.
- [G1-m2] general (PR #15 body, "Manual checks") - The body says "resizing taller/wider keeps the layout portrait (more vertical space, never side bars)". With aspect `keep_width`, a taller window gets more vertical space. A window wider than 9:16 is pillarboxed, so it does get side bars. Probe: root resized to 800x960 -> visible rect stays 540x960. The spec only promises "never horizontal bars" (top/bottom). If the user tries the manual check as written, they will report a false failure. Fix: reword to "taller: more vertical space; wider: side bars, never top/bottom bars".

## Fit with architecture / design
- main.tscn root `Control` `Main` at scenes/main/ matches architecture section 3. Display settings match D-007/D-022 and section 5. No autoloads (D-030). Physics rate is left at the 60 Hz default (D-031). `config/features` "4.5" matches `.godot-version` 4.5.1-stable. Nothing here will have to be undone by #2-#14. #13 can wrap the CLAUDE.md commands unchanged.

## What I ran
Own worktree at 1f08893 (Godot 4.5.1.stable.official.f62fdbde1, gdtoolkit from ~/.local/bin), removed afterwards:
- `godot --headless --path . --import`: exit 0 (only the usual "ObjectDB instances leaked at exit" warning)
- `gdlint scenes scripts test`: exit 0, no problems
- `gdformat --check scenes scripts test`: exit 0, 2 files unchanged
- GUT command from CLAUDE.md: exit 0, 2 scripts, 8/8 passing, 11 asserts
- `git status` in the worktree after the runs: clean
- Probe (xvfb-run, opengl3): one `Input.parse_input_event` left click on a Control under Main -> gui_input got ScreenTouch + MouseButton (G1-m1)
- Probe (xvfb-run): main scene starts at window 540x960, root content_scale mode canvas_items / aspect keep_width / size 540x960, Background fills 540x960; root resized to 800x960 -> visible 540x960 (pillarbox, G1-m2)
- Read: spec #1, #4, #5, #13, #14, architecture.md, game-design.md, all specialist logs, implementer.md, state.md, PR #15 body, reviews and inline comments
