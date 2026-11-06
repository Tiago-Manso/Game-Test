Status: done
Reviewer: tests   Round: 2   PR: #23   Issue: #4

VERDICT: BLOCKING ISSUES

## Coverage map ([test] criteria -> tests)
1. 5 blocks, HP 10, gold 1 -> test_block_field.gd: test_new_field_has_five_blocks_with_hp_10_and_gold_1. Full.
2. Damage below HP / reaching 0 -> test_damage_below_hp_lowers_hp_and_emits_block_damaged, test_damage_reaching_zero_breaks_the_block_once, test_overkill_breaks_the_block_and_spares_the_others. Partial on "block_broken ... with the block's gold": only checked for a block spawned and broken at the same destroyed_count, so spawn-time gold vs break-time gold is not distinguished (T2-I1).
3. Empty / invalid / amount <= 0 -> test_damage_to_an_empty_slot_changes_nothing, test_damage_to_an_invalid_slot_changes_nothing, test_zero_negative_or_nan_damage_changes_nothing. Full (T1-m1 already logged).
4. Respawn after exactly respawn_delay -> test_broken_slot_respawns_after_exactly_respawn_delay, test_respawn_is_not_early_and_not_late_with_uneven_steps, test_respawn_takes_30_steps_at_60_hz, test_respawned_block_uses_destroyed_count_at_spawn_time. Full.
5. lowest_hp_slot -> four test_lowest_hp_slot_* tests (lowest, ties, skips empty, -1). Full.
6. Integration field scene -> test_field_scene.gd: test_shows_a_block_with_a_full_hp_bar_per_slot, test_damaging_slot_0_updates_only_its_hp_bar, test_broken_block_is_hidden_until_tick_respawns_it. Full.
7. No _process/_physics_process calling tick -> test_field_scene_never_advances_time_itself. Full.
Requirement "Added to the main scene" -> test_main_scene_contains_the_field_in_its_upper_part.
Requirement "fixed positions" (blocks don't move) -> no test (T2-m1).

## TDD
Red/green pairs for criteria 1-6 and main scene; criterion 7 test-only (accepted in round 1).
Red checked this round (different from a1fae0e of round 1):
- 61c6a26 (criterion 3): 3 failing tests, 4334/4343 asserts. Failures on assertions (snapshot differs, "Expected ... to NOT emit signal [block_broken]/[block_damaged]", "invalid slot -1 has no block"); slots 5 and 100 additionally raise out-of-bounds script errors in the stub (expected for a stub without bounds checks; the test still fails on its assertions).
- 252ce42 (criterion 6): 3 failing tests, all "[0] expected to equal [5]: five block nodes". On the assertion, no script errors.
No test weakened, skipped, deleted or made pending.

## Critical
(none)

## Important
- [T2-I1] test/unit/test_block_field.gd:41 - The spec says gold is `block_gold(destroyed_count)` **at spawn time** and `block_broken` carries "the block's gold" (criterion 2). Every test that checks the emitted gold breaks a block spawned at count 0 while count is still 0, so spawn-time and break-time gold are indistinguishable. Mutation run: replacing `block_broken.emit(slot, _gold[slot])` (scripts/core/block_field.gd:75) with `block_broken.emit(slot, _config.block_gold(destroyed_count - 1))` -> all 55 tests still pass. This is the value #5 pays the player, so a regression here would go unnoticed. Fix: add a test that breaks slot 0 (count 1), then breaks slot 1 (still the original block, spawned at count 0) and asserts block_broken [1, block_gold(0)]; and/or let slot 0 respawn at count 2 and break it, asserting block_broken [0, block_gold(2)]. Could be argued Minor because the current code is correct, but it is a stated edge case of a [test] criterion with a concrete surviving mutation.

## Minor
- [T2-m1] scenes/field/field.gd:58 - The spec's "fixed positions" (and the code's "a hidden block leaves its place empty instead of shifting the others") have no test: hiding the whole cell instead of the block/bar would pass. Suggest an integration test that records block_view(1..4).get_global_rect() after a layout frame, breaks slot 0, and asserts the rects are unchanged (and that slots 0-2 share one y and 3-4 another).

## Earlier findings (round 2+)
- [T1-m1] logged as tech debt (not re-raised).
- [T1-m2] logged as tech debt (not re-raised).

## What I ran
- Worktree at 61c6a26 (red, criterion 3): import exit 0; full GUT suite exit 1, 40 tests, 3 failing, failures on assertions (plus out-of-bounds errors for slots 5/100 in the stub).
- Worktree at 252ce42 (red, criterion 6): import exit 0; full GUT suite exit 1, 53 tests, 3 failing, all on "five block nodes" assertion.
- Worktree at HEAD (cecb96b): import exit 0; full GUT suite exit 0, 55/55 passing, 4458 asserts; gdlint scenes scripts test -> no problems; gdformat --check -> 11 files unchanged.
- Mutation in a throwaway worktree (block_broken emits block_gold(destroyed_count - 1)): 55/55 still pass -> T2-I1.
- All worktrees removed.
