Status: done

Security review, round 1, issue #2 "Number formatting" (PR #18, HEAD a39cdff).

VERDICT: NO BLOCKING ISSUES

## Critical
None.

## Important
None.

## Minor
None.

## Notes (no finding)
- Attack surface: `scripts/core/number_format.gd` is a pure static formatter with no file, network, `Expression`, `load()`, `OS.*` or `str_to_var` use; nothing read from `user://`. No new dependencies; the `.uid` files are ordinary Godot UIDs.
- Hostile float input (relevant later when values come from a save file): NAN is checked first, so `-NAN` cannot recurse; the negative branch recurses at most once; `-0.0` prints `0`; INF/-INF print `∞`/`-∞`; DBL_MAX prints `179dt` / `1.79e308` (`pow(10, 309)` = INF is handled by the comparison); `_suffix` group tops out at 102 (`dt`), so `char()` stays in `a..z`; `clampi(…, 100, 999)` bounds the digit string so `left`/`substr` never see an unexpected length. Output length is at most 9 characters.
- No secrets or personal data in the diff or the `.loop/` logs.

## What I ran
- `git diff main...HEAD` and grep of the diff for token/secret/http/OS./Expression/str_to_var/bytes_to_var/load(/FileAccess/DirAccess/user://: no hits.
- In a private worktree: `godot --headless --path . --import`: exit 0; `gdlint scenes scripts test`: no problems; `gdformat --check scenes scripts test`: 4 files unchanged; GUT: 17/17 tests, 3604 asserts, pass.
- Throwaway fuzz probe (`-s` script, deleted with the worktree): 200,000 random 64-bit patterns decoded as doubles (NaN payloads, subnormals, huge and negative values) plus specials (0, -0, ±DBL_MAX, smallest subnormal, NaN payload, previous float of 1000), both notations = 400,022 calls. No engine errors; every output matched `^-?(\?|∞|\d{1,3}|d.dd<suffix>|dd.d<suffix>|ddd<suffix>|d.dde<exp>)$`; max length 9.
- Worktree removed.
