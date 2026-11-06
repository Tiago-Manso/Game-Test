Status: done

Quality review round 2, issue #3 "Balance config", branch loop/issue-3-balance-config @ f575f7d.

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
(none)

## Earlier findings (round 2+)
- [Q1-I1] fixed - 55ce5cc: `load_default()` now uses `ResourceLoader.load(DEFAULT_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)`; doc comment states why (A-04). Probe at HEAD: two calls give different configs and different UnitConfig sub-resources, neither is the cached `load()` instance, the script is shared and `units` stays typed. Covered by red test 42148f7 `test_load_default_returns_an_independent_copy_each_time` (mutates config and unit, checks a second load is a different object holding 0.5 / 1.0); passes at HEAD.
- [Q1-m1] logged as tech debt (not re-raised).

## What I ran
- `gdlint scenes scripts test`: Success, no problems found.
- `gdformat --check scenes scripts test`: 7 files would be left unchanged.
- Private worktree at HEAD: `godot --headless --path . --import`: OK (no errors; ObjectDB leak warning at exit is GUT/pre-existing).
- GUT full suite: 4 scripts, 33 tests, 33 passing, 4287 asserts.
- Probe (SceneTree script in the worktree, not committed): `ab_same=false units_same=false a_vs_cache=false script_same=true units_typed=true`. Worktree removed.

## Notes
- Re-read the whole change: fields, defaults in data/balance.tres, formulas, unit order and `unit_by_id` match the spec; static typing throughout; no numbers in code (A-05); nothing beyond scope. Re-loading from disk per call is fine for a startup-time loader.
