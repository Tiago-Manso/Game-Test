Status: done

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
(none)

## Earlier findings (round 2+)
- Round 1 (performance): no findings.
- Q1-I1 (quality): fixed in 55ce5cc. Its performance cost was checked this round (notes below); acceptable.

## Notes (not findings)
- `load_default()` now uses `ResourceLoader.load(..., CACHE_MODE_IGNORE)`, so every call re-reads and parses
  `data/balance.tres` (main resource + 3 unit sub-resources; the two scripts are external dependencies and still
  come from the cache, confirmed: `units[0].get_script()` is the cached `unit_config.gd`). Measured on headless
  desktop: ~150 us per call (first call 225 us), against 1.4 us for the cached `load()`. On a phone, assume ~1-2 ms.
- Where it is called: per architecture section 5 and spec #5, `Game._ready` builds the config once and injects it into
  `GameState`/`BlockField`/`Team`/`Simulation`; formulas run on the instance, never through `load_default()`.
  So it is a one-off boot cost, not in any per-frame, per-tap or per-spawn path. Tests call it per test
  (before_each); at ~150 us that adds well under 0.1 s even for hundreds of tests.
- No leak: holding 2000 copies raised static memory by ~14 MB (~7 KB each) and releasing them returned it fully;
  20,000 transient loads afterwards left memory flat. Each copy is RefCounted with no cycles.
- `duplicate(true)` of a loaded config costs ~23 us, so caching + deep duplicate would be ~6x cheaper, but for a
  single call at boot the difference is irrelevant; not worth a finding. If a later issue ever calls
  `load_default()` in a loop or per event, that would be the place to flag it.
- Formulas unchanged since round 1: O(1), no allocations, event-driven (spawn, purchase, gold_changed), not per frame.

## What I ran
- Own worktree at HEAD f575f7d (removed afterwards).
- `godot --headless --path . --import`: exit 0.
- `gdlint scenes scripts test`: Success, no problems found.
- `gdformat --check scenes scripts test`: 7 files would be left unchanged.
- GUT full suite: 33/33 passing (4287 asserts, 0.49 s).
- Micro-benchmark (untracked SceneTree script in the worktree, 2000 iterations): cached `load()` 1.38 us/call;
  `load_default()` with CACHE_MODE_IGNORE 151 us/call (first 225 us); `duplicate(true)` 23 us/call;
  static memory 20.6 MB -> 34.5 MB holding 2000 copies -> 20.6 MB after release -> 20.6 MB after 20,000 transient loads.
