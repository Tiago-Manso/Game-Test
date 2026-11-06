Status: done
Issue: #2 Number formatting   Round: 1   Reviewed: a39cdff (later b2399fa adds only review logs)

VERDICT: BLOCKING ISSUES

## Coverage map
| # | Criterion | Test(s) | Proves it? |
|---|-----------|---------|------------|
| 1 | Below 1000 -> truncated integers (0, 7, 999.9 -> 999) | test_values_below_1000_print_as_truncated_integers | Yes, for the listed values (default notation only; see T1-I2, T1-m1) |
| 2 | Suffix examples exact | test_suffix_examples_produce_exact_strings, test_value_just_below_a_power_of_1000_does_not_print_1000k | Partly: every listed string is asserted, but the "truncated (never rounded up)" rule is no longer proven by anything: 999999 -> 999K only showed truncation before the clamp was added (T1-C1) |
| 3 | Suffix boundaries T, aa, ab, ba | test_suffix_sequence_is_right_at_its_boundaries | Yes for the 4 points. B, az and everything after ba untested (T1-I1) |
| 4 | Scientific examples exact | test_scientific_examples_produce_exact_strings | Partly: the strings are asserted, but truncation is not proven (1234 rounds to 1.23 too) and exponents above 6 are never checked (T1-C1, T1-I2) |
| 5 | Negative, INF, NAN | test_negative_values_format_the_absolute_value_with_a_minus, test_infinity_prints_as_infinity_sign, test_nan_prints_as_question_mark | Yes |
| 6 | No mantissa >= 1000, 1e3..1e300, powers of 10 and just below | test_no_power_of_ten_or_value_just_below_it_reaches_a_mantissa_of_1000 | Yes: k = 3..300, both notations, 1 ulp below. It checks the leading digit, 3 digits and mantissa < limit. It does not check the exponent or suffix (T1-I1, T1-I2) |

## Mutation probes (HEAD worktree, scripts/core/number_format.gd mutated, then reverted)
- M6 floori -> roundi in _leading_digits (line 47): 17/17 PASS. 1239 -> "1.24K"/"1.24e3", 1999 -> "2.00K"
- M1 "B" -> "G" in NAMED_SUFFIXES: 17/17 PASS
- M4 second letter shifted for index > 26 (bb.. wrong): 17/17 PASS
- M5 suffix group +1 for exponent > 100: 17/17 PASS
- M2 scientific exponent printed as exponent % 100: 17/17 PASS
- M3 scientific notation applied below 1000 (7 -> "7.00e0"): 17/17 PASS
- M7 below 1000 roundi capped at 999: 17/17 PASS (contrived)

## Critical
- [T1-C1] test/unit/test_number_format.gd:11 - The core rule "3 significant digits, truncated (never rounded up)" (issue goal; criteria 2 and 4) has no test that can fail. If `floori` becomes `roundi` in `_leading_digits` (number_format.gd:47), the suite still passes 17/17 while 1239 -> "1.24K", 1999 -> "2.00K", 1239 SCIENTIFIC -> "1.24e3". The spec's own witness, 999999 -> 999K, stopped proving truncation once the 100..999 clamp went in (round gives 1000 and the clamp turns it into 999), and the criterion-6 sweep is masked the same way. Fix: add non-edge truncation cases where rounding gives a different answer, e.g. 1239 -> "1.23K", 1999 -> "1.99K", 12399 -> "12.3K", 199999 -> "199K", and in SCIENTIFIC 1239 -> "1.23e3", 1999 -> "1.99e3".

## Important
- [T1-I1] test/unit/test_number_format.gd:19 - Most of the suffix sequence the spec requires (K, M, B, T, aa..az, ba..zz) is untested. "B" is never asserted. Nothing after "ba" is checked, and the sweep checks only the leading digits, not the suffix. Mutations M1 (B -> G), M4 (wrong second letter from bb on) and M5 (wrong group above 1e100) all survive. Fix: assert 1e9 -> "1.00B", 1e15 * pow(1000.0, 25) -> "1.00az", 1e15 * pow(1000.0, 27) -> "1.00bb", and a far point such as pow(10.0, 300) -> "1.00dr". Optionally make the sweep assert the suffix for exact powers too.
- [T1-I2] test/unit/test_number_format.gd:28 - Scientific notation is only checked at e3 and e6. M2 (exponent printed wrong above 99) survives. "Below 1000 = whole number, no suffix" is also never tested in SCIENTIFIC: M3 (7 -> "7.00e0") survives, and that is the switchable path D-016 is about. Fix: in the sweep assert exact strings for SCIENTIFIC: "1.00e%d" % power for 10^k and "9.99e%d" % (power - 1) for the float just below. This also replaces the `_leading_number` parsing for that notation. Add SCIENTIFIC asserts for 0, 7 and 999.9 to the below-1000 test.

## Minor
- [T1-m1] test/unit/test_number_format.gd:8 - "Rounded down" below 1000 rests only on 999.9. A mid value such as 7.6 -> "7" would also catch a capped round (M7).
- [T1-m2] test/unit/test_number_format.gd:34 - -0.5 prints "-0". That follows the spec literally ("format the absolute value and prefix -") but no test pins it either way. Pin it, or let the PO decide whether "-0" is wanted.

## Other checks (no finding)
- TDD: each criterion has a [red] test commit, then a [green] commit, then the refactor c2b886d. Red commits f6565fb and 3bdc999 also add compile-only stubs (empty `format`, `enum Notation` plus an unused parameter) so the failure is an assertion and not a parse error. That is acceptable.
- 95b09cb (change test input between red and green): not a weakening. The spec writes the input as 1e15 * 1000^26, the literal 1e93 really does parse to a different float (confirmed: `1e93 == pow(10.0, 93)` is false; in the red runs the literal hit suffix group 30 and the computed value hit group 31).
- No skipped, pending or deleted tests. Pure static calls, no nodes, no randomness, no files, no time: reliable. Test names state the behaviour.
- `_previous_float` (1 ulp below) is a sound reading of "tiny epsilon" and the strictest one.

## What I ran
- Own worktree at a39cdff: `godot --headless --path . --import` exit 0; `gdlint scenes scripts test` clean; `gdformat --check scenes scripts test` clean (4 unchanged); full GUT suite 17/17 pass, 3604 asserts, exit 0.
- Red commit 704388b (criterion 3), own worktree: exit 1, fails on the assertions ("" expected "1.00T", "1.00aa", "1.00ab", "1.00ba"), together with out-of-bounds script errors from the short suffix array. 10/11 tests pass, 19/24 asserts.
- 95b09cb (criterion 3 red with the corrected input): same failures. The computed input reaches group 31 where the literal reached group 30.
- Probe script: 1e9 -> 1.00B, 1e300 -> 1.00dr / 1.00e300, max float -> 179dt / 1.79e308, -0.5 -> "-0".
- Mutation probes M1-M7 above. Every mutation reverted, worktrees removed.
