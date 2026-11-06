Status: done

VERDICT: NO BLOCKING ISSUES

## Solved findings check
- T2-I1 (tests, important, fix dda7171): still fixed - test_block_broken_carries_the_gold_set_when_the_block_spawned is present at HEAD (test/unit/test_block_field.gd:44), asserts [1, block_gold(0)] and [0, block_gold(2)], passes. No later commit touches scripts/ or test/ (only .loop/ logs after dda7171).

## Critical
(none)

## Important
(none)

## Minor
- [G1-m1] scripts/core/block_field.gd:14 - `destroyed_count` is a public writable `var`; the spec lists it as read access and A-02 says presentation never changes state, but any caller (e.g. a future Game/HUD/save code) can assign it and desync HP scaling from actual breaks. #8 already feeds it through the constructor. Fix: keep a private `_destroyed_count` with a read-only getter (or a property with a setter that asserts), when the field API is next touched.

## Earlier findings
- T2-I1 fixed (dda7171), still fixed.
- Q1-m1, Q1-m2, Q1-m3, S1-m1, S1-m2, T1-m1, T1-m2, Q2-m1, T2-m1: logged minors; ratings checked against #5/#7/#8 and still fair (S1-m1 correctly flagged to re-rate in #8; spec #8 already requires negative/invalid values fall back to defaults, but not a cap on huge counts - #8 must handle it). Not re-raised.

## Holistic notes (no finding)
- Fits architecture 4.2/4.4/5: plain RefCounted core, scene updates only on signals, no _process, setup() binding, field in Main's upper 45 %.
- Forward-compat with #5: block nodes are ColorRects (mouse_filter STOP by default) while cells/rows/bars are IGNORE, so per-block gui_input can be added; hidden (empty) blocks get no input, matching #5's "click on empty slot does nothing".
- Forward-compat with #7: lowest_hp_slot() returns -1 for all-empty and damage() guards invalid slots, so Team needs no extra checks; tick ordering (team then respawns) is Simulation's job.
- Running game shows an empty field until #5's Game calls setup(); documented in implementer log Manual section - PR should keep the manual check listed as "try after #5".
- "ObjectDB instances leaked at exit" warning is pre-existing (implementer verified on 1bd95b6).

## What I ran (own worktree at ca8e50a)
- godot --headless --path . --import: exit 0
- gdlint scenes scripts test: exit 0, no problems
- gdformat --check scenes scripts test: exit 0, 11 files unchanged
- GUT full suite: exit 0, 56/56 tests, 4460 asserts
