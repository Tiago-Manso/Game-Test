Status: done
Issue: #3 Balance config   Round: 2   Reviewer: security
Reviewed: git diff main...f575f7d (whole change, including the new load path from 55ce5cc)

VERDICT: NO BLOCKING ISSUES

## Critical
None.

## Important
None.

## Minor
None new.

## Earlier findings (round 2+)
- [S1-m1] logged (Minor, not re-raised) - formulas still overflow to INF / go negative for out-of-range n/level; still for #8 to clamp loaded counts and levels.
- [S1-m2] logged (Minor, not re-raised) - unit_dps / unit_cost still dereference `unit` unchecked; consumers in #7/#8 must skip null from unit_by_id.
- [Q1-I1] (quality's, checked for security impact) fixed in 55ce5cc - load_default uses ResourceLoader.load(DEFAULT_PATH, "", CACHE_MODE_IGNORE). The path is the constant res://data/balance.tres, so nothing data-driven reaches the loader. Probe confirmed each call returns a distinct config and distinct unit sub-resources, while the external script is still shared (dependencies use CACHE_MODE_REUSE, which is correct). resource_path is still res://data/balance.tres. A missing file returns null with engine errors and no crash; the file ships inside the pck and isn't player-editable save data, so no finding.

## What I ran
- Own worktrees at HEAD f575f7d, both removed afterwards.
- gdlint scenes scripts test: no problems (exit 0).
- gdformat --check scenes scripts test: 7 files unchanged (exit 0).
- godot --headless --path . --import: exit 0.
- GUT full suite (clean worktree): 33/33 passing, 4287 asserts, exit 0.
- Temporary probe test (not committed, in a separate worktree): load_default twice versus load() -> all three config objects distinct, units[0] distinct, script shared, resource_path kept; CACHE_MODE_IGNORE on a missing path -> null plus engine errors, no crash. (GUT counted the probe as failing only because it raised those engine errors on purpose.)
- grep sweep over the diff for Expression, str_to_var/bytes_to_var, OS., FileAccess/DirAccess, user://, HTTP, load/ResourceLoader: the only hit is the constant-path ResourceLoader.load in load_default. No network, file writes, secrets or new dependencies.
