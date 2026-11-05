Status: done
Issue: #2 Number formatting   Round: 2   Reviewed: 2c0e621 (whole change origin/main..HEAD; round-2 fixes 1e8d2a3, 55e8d17, ed3e881)

VERDICT: NO BLOCKING ISSUES

## Coverage map
| # | Criterion | Test(s) | Proves it? |
|---|-----------|---------|------------|
| 1 | Below 1000 -> truncated integers (0, 7, 999.9 -> 999) | test_values_below_1000_print_as_truncated_integers | Yes, in both notations now (M3 fails). A capped round still survives (logged T1-m1) |
| 2 | Suffix examples exact | test_suffix_examples_produce_exact_strings, test_suffix_digits_are_truncated_never_rounded_up, test_value_just_below_a_power_of_1000_does_not_print_1000k | Yes: all listed strings, and truncation proven (floori->roundi fails 6 asserts) |
| 3 | Suffix boundaries 1e12 T, 1e15 aa, 1e18 ab, 1e15*1000^26 ba | test_suffix_sequence_is_right_at_its_boundaries | Yes, plus B, az, bb, dr. The ba input is now pow(10.0, 93); probe confirms 1e15 * pow(1000.0, 26) == pow(10.0, 93) (same float, prints 1.00ba), so the spec's input is still what is tested |
| 4 | Scientific examples exact | test_scientific_examples_produce_exact_strings, test_scientific_digits_are_truncated_never_rounded_up, sweep in test_no_power_of_ten_... | Yes: listed strings, truncation, exact exponent e3..e300 |
| 5 | Negative, INF, NAN | test_negative_values_format_the_absolute_value_with_a_minus, test_infinity_prints_as_infinity_sign, test_nan_prints_as_question_mark | Yes |
| 6 | No mantissa >= 1000, 1e3..1e300, powers of 10 and just below | test_no_power_of_ten_or_value_just_below_it_reaches_a_mantissa_of_1000 | Yes: k = 3..300, both notations, 1 ulp below; scientific now pinned to exact strings. Removing the clamp fails 339 asserts |

## Mutation probes (HEAD worktree, scripts/core/number_format.gd mutated, then reverted)
- M6 floori -> roundi in _leading_digits: FAIL (2 tests, 6 asserts)
- M1 "B" -> "G": FAIL
- M4 second letter shifted for index > 26: FAIL
- M5 suffix group +1 above 1e100: FAIL
- M2 scientific exponent % 100: FAIL (401 asserts)
- M3 scientific applied below 1000: FAIL
- M8 clamp removed: FAIL (339 asserts)
- M9 negative recursion drops the notation: FAIL
- M10 no decimal point for 2 integer digits (12.3K -> 123K): FAIL (3 tests)
- M7 below 1000 roundi capped at 999: PASS (survives; this is logged T1-m1, not re-raised)

## Critical
None.

## Important
None.

## Minor
None new.

## Earlier findings
- [T1-C1] fixed (1e8d2a3) - 1239/1999/12399/199999 suffix and 1239/1999 scientific; floori->roundi now fails 2 tests, 6 asserts.
- [T1-I1] fixed (55e8d17) - B, az, ba, bb, dr asserted; B->G, wrong second letter and wrong group above 1e100 all fail. The ba input change to pow(10.0, 93) is not a weakening: it is the same float as the spec's 1e15 * pow(1000.0, 26) (probed). The implementer's note that 1e15 * pow(1000.0, 27) is 1 ulp below 10^96 is correct (probe: 999ba), so pow(10.0, k) is the right input for bb.
- [T1-I2] fixed (ed3e881) - sweep asserts "1.00e%d" and "9.99e%d" for k = 3..300; SCIENTIFIC 0, 7, 999.9 asserted. exponent % 100 and scientific-below-1000 mutations fail.
- [T1-m1], [T1-m2] logged, not re-raised.

## Other checks (no finding)
- The round-2 commits are test-only (test file + implementer log), add asserts only, and delete, skip or weaken nothing. They passed on existing code because they pin behaviour that was already right; the mutation probes above show each new assert can fail.
- Reliability unchanged: static pure calls, no nodes, files, time or randomness.

## What I ran
- Own worktree at 2c0e621: `godot --headless --path . --import` exit 0; `gdlint scenes scripts test` clean; `gdformat --check scenes scripts test` clean (4 unchanged); full GUT suite 19/19 pass, 4212 asserts, exit 0.
- Red commit a3328de (criterion 6; round 1 checked 704388b), own worktree: commit touches only the test file and implementer log; suite exit 1, 1 failing test (16 passing), 3335/3604 asserts, failing on the assertions ("9.9ae starts with 1", "[2] expected to equal [3]: 3 significant digits in 9.9ae", "99.ae ..."), no parse or script errors.
- Probe script: 1e15*pow(1000,26) == pow(10,93) true -> 1.00ba; 1e15*pow(1000,25) == pow(10,90) true -> 1.00az; 1e15*pow(1000,27) == pow(10,96) false -> 999ba; literal 1e93 -> 999az; 7.6 -> 7; 1e300 sci -> 1.00e300.
- Mutation probes M1-M10 above. All reverted; both worktrees removed and pruned.
