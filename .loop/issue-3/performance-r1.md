Status: done

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
(none)

## Notes (not findings)
- Call frequency per the architecture and specs #4-#8: `block_hp`/`block_gold` run once per block spawn (at most ~10/s with 5 slots and 0.5 s respawn); `tap_upgrade_cost`/`unit_cost` run on purchases and on `gold_changed` for button enable state (3-4 calls per event); `unit_dps` only inside `Team`'s cached `total_dps()` recompute on `unit_level_changed` (spec #7 forbids per-step recompute); `unit_by_id` is a linear scan over 3 units, called on buy. Nothing is per-frame, nothing allocates (all return float or an existing reference), nothing grows with play time (`pow` is O(1) regardless of `n`).
- `load_default()` uses `load()`, which returns the ResourceLoader-cached instance: no disk IO after the first call. It is shared, so callers that mutate it would affect every other user; current tests use `BalanceConfig.new()` / `duplicate()` for mutation, so fine. Later issues building `Game` with a test config should keep doing that.
- Float overflow of `pow` (e.g. `block_hp` reaches INF near n ~ 14,500) is unreachable in practice: DPS grows linearly with levels while HP grows exponentially, so progression stalls orders of magnitude earlier. The big-number swap is already planned (A-06, D-021).

## What I ran
- Own worktree at HEAD d898a9c (removed afterwards).
- `godot --headless --path . --import`: exit 0.
- `gdlint scenes scripts test`: no problems.
- `gdformat --check scenes scripts test`: 7 files unchanged.
- GUT full suite: 32/32 tests passing.
- Micro-benchmark (headless desktop, untracked script in the worktree): `block_hp` + `unit_cost` 0.74 us per pair; `unit_by_id(&"rocket")` (worst case, last of 3) 0.40 us; `load_default()` (cached) 1.2 us. Even at 10x slower on a phone these are a few microseconds per event-driven call, far below a 16.7 ms frame.
