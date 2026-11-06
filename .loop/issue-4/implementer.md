Status: in progress
Issue: #4 Blocks and slots   Attempt: 1/2
Branch: loop/issue-4-blocks-and-slots

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | New BlockField (default config): 5 blocks, HP 10, gold 1 | green (no refactor needed) | 9ee435a | e41c75a |
| 2 | Damage below HP -> block_damaged; reaching 0 -> break, destroyed_count+1, block_broken once | green (no refactor needed) | 87f0d69 | 3f54b4d |
| 3 | Empty/invalid slot or amount <= 0: no change, no signal | green | 61c6a26 | (this commit) |
| 4 | Respawn after exactly respawn_delay of tick, block_spawned, HP = block_hp(destroyed_count) | todo | | |
| 5 | lowest_hp_slot: lowest HP, lowest index on ties, -1 when empty | todo | | |
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
