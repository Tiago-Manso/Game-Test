Status: done

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
- [S1-m1] scripts/core/block_field.gd:25 - `initial_destroyed_count` is used without any bounds check, and it is the value #8 will read from the player-editable `user://save.json`. Spec #8 only falls back to defaults for negative or non-numeric values. A large positive count (an edited save, e.g. 100000) gives `block_hp = pow(1.05, 100000) = INF`. `damage()` then never breaks the block (INF - x > 0), so the save is soft-locked: every block is unbreakable. A huge negative count gives HP 0 and gold 0 (tested: one damage of 1e-300 breaks the block and pays 0). Nothing in this PR reads a save, so it can't happen yet and this is Minor. It would become a data-integrity issue (higher than Minor) once #8 connects it. Suggested fix: clamp the count in `_init` to 0 .. a max where `block_hp`/`block_gold` stay finite, or have #8 reject counts whose `block_hp` isn't finite (`is_finite`). Also note it in #8's tech debt so that issue's reviewers check it.
- [S1-m2] scripts/core/block_field.gd:48 - `hp()`, `max_hp()` (:53) and `gold()` (:58) index the packed arrays with no guard, unlike `has_block()`. A negative index wraps around without an error: `hp(-1)` silently returns slot 4's HP (tested). An index >= slot_count is an out-of-bounds script error. The team in #7 gets `lowest_hp_slot()`, which can return -1, so a caller that reads `hp(target)` before checking for -1 gets a wrong value rather than 0. This is not a crash: Godot logs the error and goes on. Suggested fix: return 0.0 when `not (slot >= 0 and slot < slot_count())`, matching `has_block`'s range check.

## Earlier findings (round 2+)
n/a (round 1)

## Sweep (nothing found)
- No FileAccess/DirAccess, no `user://` writes, no OS.execute/shell_open, no Expression/str_to_var, no network, no secrets in the diff.
- The only loads are constant paths: BalanceConfig.load_default() (shipped res:// data, trusted) and the test scene paths. The config is obtained only through load_default() (tech debt #21 respected).
- damage() rejects NaN, 0 and negative amounts. tick() rejects NaN and non-positive delta. An INF delta respawns cleanly.
- No dependency changes.

## What I ran
- Own worktree at HEAD: `godot --headless --path . --import`: ok. `gdlint scenes scripts test`: exit 0. `gdformat --check scenes scripts test`: exit 0. GUT full suite: exit 0, 55/55 passing.
- Throwaway GUT probe (not committed, worktree removed): BlockField(default, 100000) -> hp inf, still has_block after damage 1e308. hp(-1) == hp(4) == 7.0 after damaging slot 4. BlockField(default, -100000) -> hp 0.0, gold 0.0.
- grep sweep of the diff for file/OS/network/eval APIs and secrets: nothing found.
