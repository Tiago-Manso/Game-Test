Status: done
Reviewer: tests   Round: 1   PR: #23   Issue: #4

VERDICT: NO BLOCKING ISSUES

## Coverage map ([test] criteria -> tests)
1. 5 blocks, HP 10, gold 1 (default config) -> test_block_field.gd: test_new_field_has_five_blocks_with_hp_10_and_gold_1 (slot_count, has_block, hp, max_hp, gold per slot). Full.
2. Damage below HP / reaching 0 -> test_damage_below_hp_lowers_hp_and_emits_block_damaged (hp 7, block_damaged [1, 7.0] once, no block_broken); test_damage_reaching_zero_breaks_the_block_once (4 + 6 = exactly 0: empty, destroyed_count 1, block_broken [2, 1.0] once, no block_damaged for the breaking hit); test_overkill_breaks_the_block_and_spares_the_others (no carry-over). Full.
3. Empty / invalid slot / amount <= 0 -> test_damage_to_an_empty_slot_changes_nothing, test_damage_to_an_invalid_slot_changes_nothing (-1, 5, 100), test_zero_negative_or_nan_damage_changes_nothing (0, -5, -INF, NAN); snapshot + no signals. Full (see T1-m1 for the hidden countdown).
4. Respawn after exactly respawn_delay, not before, block_spawned, HP = block_hp(destroyed_count) at that moment -> test_broken_slot_respawns_after_exactly_respawn_delay (0.25 not yet, 0.5 yes, block_spawned [0] once); test_respawn_is_not_early_and_not_late_with_uneven_steps (0.49 / +0.01); test_respawn_takes_30_steps_at_60_hz (29 no, 30 yes); test_respawned_block_uses_destroyed_count_at_spawn_time (count 2 at spawn, hp/max_hp/gold, tougher than 10). Full. respawn_delay = 0.5 is pinned by test_balance_config.gd:19, so hard-coded 0.5 steps are consistent.
5. lowest_hp_slot -> test_lowest_hp_slot_returns_the_block_with_the_lowest_hp, _picks_the_lowest_index_on_ties (all-full -> 0; 2 and 4 tie, damaged in order 4 then 2 -> 2), _skips_empty_slots, _is_minus_one_when_every_slot_is_empty. Full.
6. Integration field scene -> test_field_scene.gd: test_shows_a_block_with_a_full_hp_bar_per_slot, test_damaging_slot_0_updates_only_its_hp_bar, test_broken_block_is_hidden_until_tick_respawns_it (hidden at 0, still hidden at 0.25, back at 0.5 with bar max/value = block_hp(1)). Synchronous asserts (no frame awaited) also prove the bar is signal-driven, not polled. Full.
7. No _process/_physics_process calling tick -> test_field_scene_never_advances_time_itself (every node: not processing, no _process/_physics_process in script, no ".tick(" in source). Full.
Requirement "Added to the main scene" -> test_main_scene.gd: test_main_scene_contains_the_field_in_its_upper_part. Extra: test_initial_destroyed_count_sets_the_first_blocks, test_tick_without_empty_slots_or_with_non_positive_delta_does_nothing.

## TDD
Red/green pairs exist for criteria 1-6 and the main-scene requirement. Red commits add declaration-only stubs (signatures returning 0/pass) next to the tests, needed so GDScript parses and the failure is on the assertion; no behaviour in them. Criterion 7 (b96716c) is a test-only commit that passed first time: a negative constraint already satisfied by criterion 6, so no red is possible; the implementer logged a mutation check (adding _physics_process calling tick fails 3 asserts). Accepted.
Red checked this round: a1fae0e (criterion 4) -> 5 failing tests, all on assertions ("respawned after 0.5 s", "emit count of [0] to equal [1]", "[0.0] expected to equal [11.025]: hp uses count 2", ...), no script errors.
No test weakened, skipped, deleted or made pending across the branch.

## Critical
(none)

## Important
(none)

## Minor
- [T1-m1] test/unit/test_block_field.gd:55 - test_damage_to_an_empty_slot_changes_nothing compares the public snapshot, which doesn't include the respawn countdown; an implementation that restarts (or advances) the countdown when an empty slot is hit would pass. Suggest: break slot 3, tick(0.3), damage it again, then tick(0.2) and assert it respawned (and tick(0.19) not yet).
- [T1-m2] test/unit/test_block_field.gd:134 - test_tick_without_empty_slots_or_with_non_positive_delta_does_nothing covers two behaviours (full field ignores tick; non-positive/NaN delta keeps the countdown) and ends asserting a respawn; it has more than one reason to fail and its name says "does nothing". Suggest splitting into two tests.

## What I ran
- Worktree at a1fae0e (red, criterion 4): import, then full GUT suite -> exit 1, 46 tests, 5 failing, 4361/4373 asserts, all failures on assertions.
- Worktree at HEAD (71cbf7f): godot --import -> exit 0; full GUT suite -> exit 0, 55/55 passing, 4458 asserts, no failures/pending; gdlint scenes scripts test -> no problems; gdformat --check -> 11 files unchanged.
- git show --stat on every red commit to confirm contents.
