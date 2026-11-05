Status: done

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
- [Q1-m1] scripts/core/number_format.gd:22 - Small negative fractions print as "-0": format(-0.5) -> "-0" in both notations (the recursion formats 0.5 as "0" and prefixes "-"). Literally what the spec says ("format the absolute value and prefix -"), but "-0" is an odd thing to show once negative deltas reach a label. Suggest: format the absolute value first and only prefix "-" when the result is not "0" (would need a one-line spec note). Could be Important if a later issue displays negative fractional rates.
- [Q1-m2] scripts/core/number_format.gd:48 - The clamp bounds 100 and 999 are hard-coded while the divisor uses SIGNIFICANT_DIGITS, and _suffixed (line 58-61) only lays out correctly for 3 digits (groups of 1000). SIGNIFICANT_DIGITS reads like a tunable but isn't one. Suggest: derive the bounds (pow(10, SIGNIFICANT_DIGITS - 1) .. pow(10, SIGNIFICANT_DIGITS) - 1) or name them as constants next to SIGNIFICANT_DIGITS with a comment that 3 is fixed by the suffix layout.
- [Q1-m3] scripts/core/number_format.gd:2 - Header comment cites the decisions the wrong way round: "so the notation can be switched in one place (D-021)" - switching notation is D-016; D-021 is "plain float behind NumberFormat, swappable for a big-number type". Suggest: "...so the notation can be switched (D-016) and a big-number type swapped in later (D-021)".

## What I ran
- gdlint scenes scripts test: Success, no problems.
- gdformat --check scenes scripts test: 4 files unchanged.
- Own worktree at HEAD a39cdff: godot --headless --import (ok); GUT full suite: 17/17 tests, 3604 asserts passing.
- Probe script (in the worktree, deleted): -0.5 -> "-0"; -0.0 -> "0"; 1e308 -> "100dt"/"1.00e308"; max float -> "179dt"/"1.79e308" (matches the "dt" comment on line 11); 1.23e100 -> "12.3bc"; 123456789012345 -> "123T".
- Every m*10^k with m in 100..999, k in 1..13 (exactly representable): all print the exact digits in scientific notation (0 mismatches).
- Decimal literals "<m>e<k>" for k in 1..305 (39345 samples): 1721 print one digit low (e.g. 485e19 -> "4.84e21"). Not a finding: the nearest double is below the literal (4849999999999999475712), so truncation is correct per spec; exact mathematical truncation would differ on 18468 of them. Noted only so the PO knows the last digit of huge values is float noise, as D-021 accepts.
- Correctness read: NaN/INF ordering, -INF -> "-∞", log() off-by-one guard in _decimal_exponent, pow(10, 309) -> INF at the top end handled, suffix arithmetic (aa at group 5, ba at group 31) all correct. No scope creep; statically typed throughout.
