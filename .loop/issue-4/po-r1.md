Status: done

DECISION: GO

## Acceptance criteria
| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | New BlockField (default config): 5 blocks, HP 10, gold 1 | met | test_new_field_has_five_blocks_with_hp_10_and_gold_1 (data/balance.tres slot_count 5, respawn_delay 0.5) |
| 2 | Damage lowers HP + block_damaged; reaching 0 breaks, empties, count+1, block_broken once with gold, no block_damaged | met | test_damage_below_hp_lowers_hp_and_emits_block_damaged, test_damage_reaching_zero_breaks_the_block_once, test_overkill_breaks_the_block_and_spares_the_others, test_block_broken_carries_the_gold_set_when_the_block_spawned |
| 3 | Empty / invalid slot / amount <= 0: no change, no signal | met | test_damage_to_an_empty_slot_changes_nothing, test_damage_to_an_invalid_slot_changes_nothing (-1, 5, 100), test_zero_negative_or_nan_damage_changes_nothing |
| 4 | Respawn after exactly respawn_delay of tick, not before; block_spawned; HP = block_hp(count at that moment) | met | test_broken_slot_respawns_after_exactly_respawn_delay, test_respawn_is_not_early_and_not_late_with_uneven_steps, test_respawn_takes_30_steps_at_60_hz, test_respawned_block_uses_destroyed_count_at_spawn_time |
| 5 | lowest_hp_slot: lowest HP, lowest index on ties, -1 all empty | met | test_lowest_hp_slot_* (4 tests, incl. skips empty slots) |
| 6 | Integration: 5 blocks with HP bars; damage slot 0 updates its bar; break hides until tick respawns | met | test/integration/test_field_scene.gd: test_shows_a_block_with_a_full_hp_bar_per_slot, test_damaging_slot_0_updates_only_its_hp_bar, test_broken_block_is_hidden_until_tick_respawns_it |
| 7 | Field scene has no _process/_physics_process calling tick | met | test_field_scene_never_advances_time_itself (checks processing flags, method lists and ".tick(" in sources for every node) |
| 8 | [manual] Five blocks with HP bars visible/readable at 540x960 and taller | met by inspection | field.gd builds 3+2 centred rows of 120 px ColorRects with 14 px ProgressBar under each (408 px wide row fits 540; 292 px tall fits 45% of 960 = 432); Field anchored to top 45% of Main. Only visible once #5 calls setup(); implementer listed the steps. |

Requirements also honoured: RefCounted BlockField with no scene deps; gold/HP fixed at spawn time; overkill not carried; setup(field) injection; bars update only on signals; empty slots keep their place (fixed-size cells); Field added to main.tscn (test_main_scene_contains_the_field_in_its_upper_part). Out of scope respected: no tap input, gold economy, team, effects or saving. Placeholder coloured squares as allowed. No issue comments.

Checks run in own worktree at HEAD: import exit 0 (no errors), GUT 56/56 passing (4460 asserts), gdlint clean, gdformat --check clean.

Deferred/minor findings: none is reachable by a player in this feature (out-of-range hp(), double setup(), save-fed huge counts, listener re-entrancy are all for #5/#7/#8 callers). S1-m1 and S1-m2 should be re-rated when #8 / #7 wire them up.

## NO-GO reasons
(none)

## Manual checks (non-blocking)
- After #5 (Game calls Field.setup): run at 540x960, then resize taller: 3 blocks above 2, centred in the upper part, each with a readable HP bar; break a block and see its place stay empty (others don't shift) and reappear after 0.5 s with a full, longer bar.
- Default ProgressBar theme: check the bar fill contrasts with the dark background and the orange block; adjust in a UI pass if not.
- Follow-ups to keep in mind: #7 must not call hp(lowest_hp_slot()) when it returns -1 (S1-m2); #8 must cap destroyed_count from saves (S1-m1).
