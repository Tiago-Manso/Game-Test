Status: done
Issue: #3 Balance config   Round: 1   Reviewer: security
Reviewed: git diff main...d898a9c (whole change)

VERDICT: NO BLOCKING ISSUES

## Critical
None.

## Important
None.

## Minor
- [S1-m1] scripts/core/balance_config.gd:27 - The exponential formulas silently overflow to INF with plain floats (D-021): probed block_hp(14548) = inf, tap_upgrade_cost(10493) = inf, unit_cost(pistol, 10500) = inf; negative inputs give 0 or negative results (block_hp(-2147483648) = 0.0, tap_damage(-5) = -5.0). Not reachable in normal play, but `destroyed_count` / levels will come from user://save.json (#8), whose spec rejects negatives but not huge values; an edited save with destroyed_count = 1e6 would spawn an INF-HP block that can never die (softlock, would be Critical in #8). Suggest: no change here; carry into #8 (clamp loaded counts/levels to a sane maximum or reject non-finite formula results) and the big-number issue.
- [S1-m2] scripts/core/balance_config.gd:47 - unit_dps / unit_cost dereference `unit` without a null check, while unit_by_id (line 55) returns null by design; a caller that maps a save-file unit id through unit_by_id and passes the result straight on crashes with "Invalid access to property on a null instance". Likewise unit_by_id would crash on a null entry in `units`. Data is res:// only today, so low risk. Suggest: document the non-null precondition (or assert) and make #7/#8 consumers skip null.

## What I ran
- Own worktree at HEAD d898a9c (removed afterwards).
- gdlint scenes scripts test: no problems (exit 0).
- gdformat --check scenes scripts test: exit 0.
- godot --headless --path . --import: exit 0.
- GUT full suite plus a temporary probe test (not committed): 33/33 passing, 4284 asserts, exit 0; probe output as cited in S1-m1.
- Sweeps over the diff: only load() is of the constant res://data/balance.tres (no data-driven paths); no Expression, str_to_var/bytes_to_var, OS.execute/shell_open, network, file writes, user:// access, secrets or new dependencies.
