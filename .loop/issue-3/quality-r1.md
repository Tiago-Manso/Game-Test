Status: done

Quality review round 1, issue #3 "Balance config", branch loop/issue-3-balance-config @ d898a9c.

VERDICT: BLOCKING ISSUES

## Critical
(none)

## Important
- [Q1-I1] scripts/core/balance_config.gd:21 - `load_default()` returns `load(DEFAULT_PATH)`, which is the ResourceLoader-cached instance: every caller in the process gets the *same* object (and the same UnitConfig sub-resources). Verified with a probe in Godot 4.5.1: after `var a := BalanceConfig.load_default(); a.respawn_delay = 99.0; a.units[0].base_dps = 77.0`, a second `load_default()` returns `same=true respawn=99.0 pistol_dps=77.0`. This is hidden shared global state, against A-04 ("no globals; dependencies are passed in, so tests build their own instances with their own config") and A-05 (data in balance.tres is the source of truth). Specs #4-#8 will build `Game`/`BlockField`/`Simulation` from `load_default()` and their tests will tweak values (e.g. `respawn_delay = 0` for a deterministic step); any such tweak silently leaks into every later test in the same GUT run and into the shipped `balance.tres` values seen by the rest of the process - order-dependent failures that are hard to trace. Not Critical only because no consumer mutates it yet. Fix: return a private copy, e.g. `return ResourceLoader.load(DEFAULT_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as BalanceConfig` (verified: fresh object and fresh UnitConfig sub-resources, values 0.5 / 1.0 unaffected by the earlier mutation), and add a GUT test that mutating one `load_default()` result (including a unit) does not change a second one. Alternatively document "shared, read-only" in the doc comment - but a copy is simpler and safer.

## Minor
- [Q1-m1] scripts/core/balance_config.gd:57 - `unit_by_id` dereferences `unit.id` without a null check; a `units` array with an empty slot (easy to create in the inspector when tuning balance.tres, which is the point of D-008) crashes with "Invalid access to property or key 'id' on a base object of type 'Nil'" (verified). Consider `if unit != null and unit.id == id:`.

## What I ran
- `gdlint scenes scripts test`: Success, no problems.
- `gdformat --check scenes scripts test`: 7 files unchanged (pass).
- Private worktree at HEAD: `godot --headless --path . --import`: OK (only GUT class-update lines; ObjectDB leak warning at exit is pre-existing/GUT).
- GUT full suite: 4 scripts, 32 tests, 32 passing, 4283 asserts.
- Probe script (SceneTree, in the worktree, not committed) checking cache sharing of `load_default()`, `CACHE_MODE_IGNORE` / `CACHE_MODE_IGNORE_DEEP` behaviour, and `unit_by_id` with a null entry. Worktree removed.

## Notes
- Code otherwise matches the spec exactly: field names/types, defaults in balance.tres, formulas, unit order, `unit_by_id` returns the same instance. Static typing throughout; no magic numbers in code (zero defaults in the script, real values only in the .tres). `.uid` files committed. Spec status change to `in-review` matches the lifecycle in specs/_template.md.
- Nothing built beyond scope.
