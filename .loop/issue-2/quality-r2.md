Status: done
Issue: #2 Number formatting   Round: 2   Reviewed: 2c0e621

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
- [Q2-m1] test/unit/test_number_format.gd:77 - In the sweep, the SCIENTIFIC branch of `_assert_mantissa` (leading digit, 3 digits, mantissa < 10) is now fully implied by the exact `"1.00e%d"` / `"9.99e%d"` asserts on lines 78 and 82-85, so scientific is checked twice per sample and `_assert_mantissa` loops over a notation it no longer needs to. Suggest: call the mantissa check for SUFFIX only (drop the notation loop and `limit` ternary in `_assert_mantissa`), which also shortens the helper's doc comment.

## Earlier findings
- [Q1-m1] logged (Minor, tech debt) - unchanged; -0.5 still prints "-0" (re-probed).
- [Q1-m2] logged (Minor, tech debt) - unchanged.
- [Q1-m3] logged (Minor, tech debt) - unchanged.
- [T1-C1] fixed (1e8d2a3) - truncation cases 1239/1999/12399/199999 and SCIENTIFIC 1239/1999 differ under rounding; they would fail a floori->roundi mutation.
- [T1-I1] fixed (55e8d17) - B, az, ba, bb, dr asserted. Using pow(10.0, k) is sound: probe confirms 1e15 * pow(1000.0, 26) == pow(10.0, 93) (the spec's own expression and the test's input are the same float), and the comment on lines 34-36 is accurate (literal 1e93 -> "999az", 1e15 * pow(1000.0, 27) -> "999ba").
- [T1-I2] fixed (ed3e881) - exact scientific strings across 1e3..1e300 and 1 ulp below; SCIENTIFIC 0/7/999.9 below 1000.

## Review notes (no finding)
- Production code (scripts/core/number_format.gd) unchanged since round 1 (git diff 4971288..HEAD -- scripts/ empty); my round-1 correctness read stands.
- New test code is statically typed, helpers are small and named for what they do, no scope creep, nothing outside the spec.

## What I ran
- gdlint scenes scripts test: Success, no problems found.
- gdformat --check scenes scripts test: 4 files would be left unchanged.
- git diff 4971288..HEAD -- scripts/: empty (only tests and loop logs changed).
- Own worktree at 2c0e621: godot --headless --path . --import exit 0; full GUT suite 19/19 tests, 4212 asserts, exit 0.
- Probe script in the worktree: 1e15*pow(1000,26) == pow(10,93) -> true, formats "1.00ba"; 1e93 -> "999az"; 1e15*pow(1000,27) -> "999ba"; 7.6 -> "7"; -0.5 -> "-0". Worktree removed.
