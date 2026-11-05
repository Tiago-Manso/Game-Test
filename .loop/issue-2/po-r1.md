Status: done
Issue: #2 Number formatting   Round: 1   Reviewed: b385a6a (whole change main..HEAD)

DECISION: GO

## Acceptance criteria
| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | [test] Values below 1000 print as truncated integers (0, 7, 999.9 -> `999`) | met | `test_values_below_1000_print_as_truncated_integers` (test/unit/test_number_format.gd:5): 0, 7, 999.9 -> "0", "7", "999" in both notations. My probe also gives 7.6 -> "7", 0.5 -> "0" and 999.999 -> "999", so values are rounded down, never up. |
| 2 | [test] Suffix examples produce the exact strings listed | met | `test_suffix_examples_produce_exact_strings` (:14) has all 5 spec examples, letter for letter: 1234 -> 1.23K, 12345 -> 12.3K, 123456 -> 123K, 999999 -> 999K, 1000000 -> 1.00M. `test_suffix_digits_are_truncated_never_rounded_up` (:22) shows truncation (1999 -> 1.99K, 199999 -> 199K). The spec's float edge case (999999.9999999 -> 999K) has its own test, `test_value_just_below_a_power_of_1000_does_not_print_1000k` (:70). |
| 3 | [test] Suffix boundaries: 1e12 -> 1.00T, 1e15 -> 1.00aa, 1e18 -> 1.00ab, 1e15 * 1000^26 -> 1.00ba | met | `test_suffix_sequence_is_right_at_its_boundaries` (:29). It also covers B, az, bb and dr. The test builds the ba input as `pow(10.0, 93)`. I checked in Godot that `1e15 * pow(1000.0, 26) == pow(10.0, 93)` is true, and that the spec's own expression formats as "1.00ba". |
| 4 | [test] Scientific examples produce the exact strings listed | met | `test_scientific_examples_produce_exact_strings` (:43): 1234 -> 1.23e3, 1000000 -> 1.00e6. `test_scientific_digits_are_truncated_never_rounded_up` (:48) covers truncation. The sweep pins "1.00e<k>" for k = 3..300. |
| 5 | [test] Negative, INF and NAN cases produce the strings listed | met | `test_negative_values_format_the_absolute_value_with_a_minus` (:53) covers -7, and -1234 in both notations. `test_infinity_prints_as_infinity_sign` (:59) covers INF and -INF. `test_nan_prints_as_question_mark` (:65) covers NAN in both notations. |
| 6 | [test] No value from 1000 to 1e300 (each power of 10, and each power of 10 minus a tiny epsilon) ever produces a mantissa >= 1000 | met | `test_no_power_of_ten_or_value_just_below_it_reaches_a_mantissa_of_1000` (:74) checks 10^3..10^300 and the float one ulp below each (the smallest possible epsilon). For each it asserts: the leading digit, 3 significant digits, a suffix mantissa below 1000 and a scientific mantissa below 10, and the exact strings "1.00e<k>" / "9.99e<k-1>". |

Other spec requirements, checked by reading the code:
- The file is `scripts/core/number_format.gd` with `class_name NumberFormat`, static functions only.
- `enum Notation { SUFFIX, SCIENTIFIC }` and `format(value: float, notation: Notation = Notation.SUFFIX) -> String` match the spec exactly.
- The suffix order is K, M, B, T, then aa..zz.
- In my probe the largest float gives "179dt" and "1.79e308", with no crash and no overflow past zz.
- Out of scope was respected: no settings toggle, no UI, no big-number type. Production code is one script, scripts/core/number_format.gd; the other non-log files are the test, two .uid files and the spec status/checkboxes.
- Assets: none needed, none added.
- Issue comments: only the loop's pickup comment, so there are no extra clarifications to honour.

## NO-GO reasons
None.

## Deferred and minor findings (none is something a player hits in this feature)
- G1-I1 (deferred): specs #6 and #7 show decimals through NumberFormat, but this spec says whole numbers below 1000.
  - This feature has no UI, and the spec's own criterion 1 requires "999", so the code is right for this spec.
  - The conflict was raised on #6 and #7 as questions for /refine-issue. The ambiguity gate will hold those issues until it is settled.
  - The deferral is sound. It is not a [SPEC] defect in #2.
- Q1-m1 / T1-m2: -0.5 prints "-0".
  - This follows the spec's rule word for word: format the absolute value, then prefix "-".
  - Nothing in milestone 1 shows negative numbers yet, so it stays a Minor.
- The other Minors are code or test style, or process notes. None is visible to a player.

## Manual checks (non-blocking)
- The spec has no [manual] criteria, so there is nothing to try by hand for this issue.
- Follow-up risk: once #5 (HUD gold) lands, check that fractional gold shows as a whole number, e.g. 5.9 -> "5". The design may need to revisit this; #6/#7 already have the questions.
- Follow-up risk (G1-m1): float literals and JSON round trips above ~1e22 can move a value one ulp below a power. That flips the display, e.g. 1.00ac -> 999ab. The save issue #8 should store floats losslessly.

## What I ran (own worktree at b385a6a, removed and pruned afterwards)
- `godot --headless --path . --import`: exit 0, no errors.
- `gdlint scenes scripts test`: no problems.
- `gdformat --check scenes scripts test`: 4 files unchanged.
- GUT full suite: 19/19 passing, 4212 asserts, exit 0.
- A throwaway probe script (deleted before removing the worktree) checked:
  - the spec's 1e15 * 1000^26 expression gives "1.00ba", and it equals pow(10, 93);
  - 1000 -> 1.00K / 1.00e3;
  - 999999.9999999 -> 999K / 9.99e5;
  - 1e300 -> 1.00dr;
  - the largest float -> 179dt / 1.79e308;
  - 7.6 -> 7, 0.5 -> 0, -0.5 -> -0;
  - 2500 -> 2.50K, 123456789 -> 123M.
