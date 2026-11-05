Status: done

Security review, round 2, issue #2 "Number formatting" (PR #18, HEAD 2c0e621).

VERDICT: NO BLOCKING ISSUES

## Critical
None.

## Important
None.

## Minor
None.

## Earlier findings (round 2+)
- Security round 1 raised none.
- T1-C1, T1-I1, T1-I2 (tests): the fixes in 1e8d2a3, 55e8d17 and ed3e881 change only tests. `git diff a39cdff HEAD -- scripts/` is empty, so production code is the same as in round 1. The new tests add no attack surface: `_previous_float` encodes and decodes a double in a local 8-byte buffer, with no file or network I/O.

## Notes (no finding)
- Reviewed the whole change again: `scripts/core/number_format.gd` is a pure static formatter. It has no file, network, `Expression`, `load()`, `OS.*`, `str_to_var` or `bytes_to_var` use, and adds no dependencies.
- Hostile input still holds up. NAN is checked first, so `-NAN` cannot recurse. Negative input recurses at most once. ±INF print `∞` / `-∞`, and ±DBL_MAX print `179dt` / `1.79e308`. `_suffix` group tops out at 102 (`dt`). The clamp holds the digits string at exactly 3 characters. Passing an out-of-range `Notation` int (7) falls through to suffix notation safely.
- `.loop/` logs: no secrets, tokens, local filesystem paths or email addresses. The only URLs are the session attribution lines the loop requires.

## What I ran
- `git diff main...HEAD` grepped for token/secret/password/api key/http/OS./Expression/str_to_var/bytes_to_var/load(/FileAccess/DirAccess/user:///HTTPRequest. The only hits were the round-1 security log's own prose.
- `git diff main...HEAD -- .loop` grepped for /home, /root, /tmp and email patterns: no hits.
- In a private worktree at 2c0e621:
  - `godot --headless --path . --import`: exit 0.
  - `gdlint scenes scripts test`: no problems.
  - `gdformat --check scenes scripts test`: 4 files unchanged.
  - GUT: 19/19 tests, 4212 asserts, all pass.
- A throwaway fuzz probe (deleted with the worktree) made 900,033 calls, covering 300,000 random 64-bit patterns plus 11 specials across SUFFIX, SCIENTIFIC and an invalid enum value. No engine errors, every output matched the expected shape regex, and the longest output was 9 characters.
- Worktree removed.
