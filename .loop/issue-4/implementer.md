Status: in progress
Issue: #4 Blocks and slots   Attempt: 1/2
Branch: loop/issue-4-blocks-and-slots

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | New BlockField (default config): 5 blocks, HP 10, gold 1 | green (no refactor needed) | 9ee435a | e41c75a |
| 2 | Damage below HP -> block_damaged; reaching 0 -> break, destroyed_count+1, block_broken once | green (no refactor needed) | 87f0d69 | 3f54b4d |
| 3 | Empty/invalid slot or amount <= 0: no change, no signal | green (no refactor needed) | 61c6a26 | bae1485 |
| 4 | Respawn after exactly respawn_delay of tick, block_spawned, HP = block_hp(destroyed_count) | green (no refactor needed) | a1fae0e | 2c8cb60 |
| 5 | lowest_hp_slot: lowest HP, lowest index on ties, -1 when empty | refactored | acc5a9f | 2b4bfe6 |
| 6 | Integration: field scene shows 5 blocks with HP bars; damage updates bar; break hides until tick respawns | todo | | |
| 7 | Field scene has no _process/_physics_process calling tick | todo | | |
| - | Field added to the main scene (requirement) | todo | | |

## Findings
(none yet)

## Last checks
Baseline: import 0, lint 0, format 0, tests exit 0 (33/33, 4287 asserts).
Criterion 1 red: declaration-only stub BlockField (signals, accessors returning 0) so the failure is the assertion: "[0] expected to equal [5]: slot count", "[0.0] expected to equal [10.0]: slot 0 hp". A gold(slot) accessor is added because the criterion checks gold per block. Lint 0, format 0.
Criterion 1 green: slots stored as parallel arrays, each spawned from block_hp/block_gold(destroyed_count). Import 0, lint 0, format 0, tests exit 0 (34/34, 4309 asserts).
Criterion 2 red: damage() stub does nothing. Failures: "[10.0] expected to equal [7.0]: hp after 3 damage", "Expected the signal [block_broken] emit count of [0] to equal [1]". Overkill test included (no carry to other slots). Lint 0, format 0.
Criterion 2 green: damage() subtracts, emits block_damaged while HP > 0, otherwise empties the slot, increments destroyed_count and emits block_broken with the block's gold. Respawn countdown left for criterion 4. Import 0, lint 0, format 0, tests exit 0 (37/37, 4327 asserts).
Criterion 3 red: 3 failing tests. Empty slot: snapshot differs (destroyed_count 2 != 1), "Expected ... to NOT emit signal [block_broken]". Invalid slot: "invalid slot -1 has no block" (negative index wraps to slot 4) and out-of-bounds script errors for 5 and 100. Amount <= 0 / NaN: "Expected ... to NOT emit signal [block_damaged]", snapshot differs (0 damage then -INF... slot 0 broken). NaN added to the amounts since `amount <= 0` alone lets NaN through. Lint 0, format 0.
Criterion 3 green: has_block() returns false outside the slot range; damage() returns early unless amount > 0 (rejects NaN) and the slot has a block. Import 0, lint 0, format 0, tests exit 0 (40/40, 4342 asserts).
Criterion 4 red: tick() stub does nothing. Failures: "respawned after 0.5 s", "Expected the signal [block_spawned] emit count of [0] to equal [1]", "respawned on step 30", "[10.0] expected to equal [11.025]: max hp uses count 2". Extra tests cover uneven steps (0.49 + 0.01), 30 steps at 60 Hz, and non-positive/NaN delta. test_initial_destroyed_count_sets_the_first_blocks already passes (criterion 1's constructor reads the count); it pins the 'initial destroyed_count' requirement. Lint 0, format 0.
Criterion 4 green: breaking sets the slot's countdown to respawn_delay; tick() ignores delta that isn't > 0, lowers each empty slot's countdown and spawns at <= TIME_EPSILON (1e-9) with block_spawned. Mutation check: TIME_EPSILON = 0 fails "respawned on step 30" and "respawned after 0.49 + 0.01 s" (float residue), so the epsilon is needed. Import 0, lint 0, format 0, tests exit 0 (46/46, 4373 asserts).
Criterion 5 red: stub returns -2 (no valid answer, so every case is red). Failures: "[-2] expected to equal [3]: slot 3 has 4 hp", "[-2] expected to equal [2]: slots 2 and 4 tie at 7 hp", "[-2] expected to equal [-1]". Empty-slot test guards against picking a broken slot (its stored hp is 0). Lint 0, format 0.
Criterion 5 green: one pass over occupied slots, strict < keeps the lowest index on ties. Import 0, lint 0, format 0, tests exit 0 (50/50, 4378 asserts).
Refactor (criteria 1-5): doc comments on destroyed_count, _init and the read accessors; no behaviour change. Import 0, lint 0, format 0, tests exit 0 (50/50, 4378 asserts).
