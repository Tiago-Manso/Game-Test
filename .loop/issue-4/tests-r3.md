Status: done
Reviewer: tests   Round: 3   PR: #23   Issue: #4

VERDICT: NO BLOCKING ISSUES

## Coverage map ([test] criteria -> tests)
1. 5 blocks, HP 10, gold 1 -> test_block_field.gd: test_new_field_has_five_blocks_with_hp_10_and_gold_1. Full.
2. Damage below HP / reaching 0 / block_broken with the block's gold -> test_damage_below_hp_lowers_hp_and_emits_block_damaged, test_damage_reaching_zero_breaks_the_block_once, test_overkill_breaks_the_block_and_spares_the_others, test_block_broken_carries_the_gold_set_when_the_block_spawned (new, dda7171). Full now: spawn-time vs break-time gold is distinguished.
3. Empty / invalid / amount <= 0 -> test_damage_to_an_empty_slot_changes_nothing, test_damage_to_an_invalid_slot_changes_nothing, test_zero_negative_or_nan_damage_changes_nothing. Full.
4. Respawn after exactly respawn_delay -> test_broken_slot_respawns_after_exactly_respawn_delay, test_respawn_is_not_early_and_not_late_with_uneven_steps, test_respawn_takes_30_steps_at_60_hz, test_respawned_block_uses_destroyed_count_at_spawn_time. Full.
5. lowest_hp_slot -> four test_lowest_hp_slot_* tests. Full.
6. Integration field scene -> test_field_scene.gd: test_shows_a_block_with_a_full_hp_bar_per_slot, test_damaging_slot_0_updates_only_its_hp_bar, test_broken_block_is_hidden_until_tick_respawns_it. Full.
7. No _process/_physics_process calling tick -> test_field_scene_never_advances_time_itself. Full.
Requirement "Added to the main scene" -> test_main_scene_contains_the_field_in_its_upper_part.

## TDD
Red/green pairs for criteria 1-6 and the main scene; criterion 7 and the T2-I1 test are test-only (behaviour already present; accepted).
Red checked this round: 87f0d69 (criterion 2; rounds 1-2 checked a1fae0e, 61c6a26, 252ce42). Only tests plus an empty `damage()` stub so the file compiles. 3 failing tests, 4317/4327 asserts, all failures on assertions ("[10.0] expected to equal [7.0]", "did not emit signal [block_broken]", "slot 2 is empty", ...), no script errors.
No test weakened, skipped, deleted or made pending across the branch.

## Critical
(none)

## Important
(none)

## Minor
(none)

## Earlier findings (round 2+)
- [T2-I1] fixed in dda7171 - verified: mutation `block_broken.emit(slot, _config.block_gold(destroyed_count - 1))` now fails the new test ([1, 1.045] != [1, 1.0]); a second mutation `block_gold(maxi(destroyed_count - 2, 0))` is caught by its second half ([0, 1.045] != [0, 1.092025]).
- [T1-m1], [T1-m2], [T2-m1] logged as tech debt (not re-raised).

## What I ran
- Worktree at 87f0d69 (red, criterion 2): import exit 0; full GUT suite exit 1, 37 tests, 3 failing, all on assertions.
- Worktree at HEAD (3c4dfd1): import exit 0; full GUT suite exit 0, 56/56 passing, 4460 asserts; gdlint scenes scripts test -> no problems; gdformat --check scenes scripts test -> 11 files unchanged.
- Mutations at HEAD (reverted after each): M1 emit block_gold(destroyed_count - 1) -> 1 failing (new test); M2 emit block_gold(destroyed_count - 2) -> 1 failing (new test).
- Worktrees removed; shared checkout untouched.
