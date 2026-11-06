Status: in progress
Issue: #4 Blocks and slots   Attempt: 1/2
Branch: loop/issue-4-blocks-and-slots

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | New BlockField (default config): 5 blocks, HP 10, gold 1 | green | 9ee435a | (this commit) |
| 2 | Damage below HP -> block_damaged; reaching 0 -> break, destroyed_count+1, block_broken once | todo | | |
| 3 | Empty/invalid slot or amount <= 0: no change, no signal | todo | | |
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
