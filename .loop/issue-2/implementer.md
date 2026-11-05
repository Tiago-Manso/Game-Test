Status: done
Issue: #2 Number formatting   Attempt: 1/2
Branch: loop/issue-2-number-formatting

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | Values below 1000 print as truncated integers | refactored | f6565fb | 5b71971 |
| 2 | Suffix examples produce the exact strings | refactored | a2ff64e | 21a7d69 |
| 3 | Suffix sequence boundaries (T, aa, ab, ba) | refactored | 704388b (input fixed in 95b09cb) | 174f9d7 |
| 4 | Scientific examples produce the exact strings | refactored | 3bdc999 | e8e2c4b |
| 5 | Negative, INF and NAN cases | refactored | 568064c | d260575 |
| 6 | No mantissa >= 1000 from 1e3 to 1e300 | refactored | a3328de | ee791e1 |

## Findings
Round 1 (tests reviewer). Fixing T1-C1, T1-I1, T1-I2; minors T1-m1, T1-m2, Q1-m1..m3 logged, not fixed.
| ID | Severity | Status | Commit | Notes |
|----|----------|--------|--------|-------|
| T1-C1 | critical | fixed | 1e8d2a3 | Truncation cases added (suffix 1239, 1999, 12399, 199999; scientific 1239, 1999). Pass immediately on current code; verified they fail with the floori->roundi mutation (6 asserts). |
| T1-I1 | important | fixed | 55e8d17 | Added 1e9 -> 1.00B, 10^90 -> 1.00az, 10^96 -> 1.00bb, 10^300 -> 1.00dr. They pass on the current code and fail with B->G and second-letter mutations. Suggested input 1e15 * pow(1000.0, 27) is one ulp below 10^96 (rightly 999ba), so the large inputs use pow(10.0, k). The 1.00ba input moved to the same form; it is the same float. |
| T1-I2 | important | fixed | (this commit) | Sweep now asserts exact "1.00e<k>" for each 10^k and "9.99e<k-1>" for the float just below; the below-1000 test asserts SCIENTIFIC 0 -> "0", 7 -> "7", 999.9 -> "999". They pass on the current code and fail with the `exponent % 100` and "7.00e0" mutations. |

## Last checks
Baseline (before any change): import 0, lint 0, format 0, tests 8/8 pass.
After refactor c2b886d: import exit 0, lint exit 0, format check exit 0, tests exit 0 (17/17 tests, 3604 asserts).
Refactor commit: c2b886d.
After round-1 fixes: import exit 0, lint exit 0, format check exit 0, tests exit 0 (19/19 tests, 4212 asserts). Production code unchanged by round 1; T1-C1 and T1-I1 asserts still pass after the T1-I2 change. Spec set to in-review in the docs commit.
Criterion 1 red: test fails on assertions ([""] expected to equal ["0"]). The red commit adds a stub `NumberFormat.format` returning "" so the failure is the assertion, not a missing class.
Criterion 2 red: ["1234"] expected to equal ["1.23K"]. First green attempt gave "100K" for 1e6 (log() lands at 5.999...), so the exponent is corrected against pow(10, e).
Criterion 3 red: [""] expected to equal ["1.00T"] (SUFFIXES out of bounds at index 4: the sequence stops at M).
Criterion 3 test fix: the GDScript literal `1e93` parses to 9.999999999999999e+92 (Godot's float parser is not correctly rounded above 1e22; 118 of the powers 10^0..10^308 differ from pow(10, k)), so strict truncation rightly prints 999az for it. The test now computes the value as the spec writes it, `1e15 * pow(1000.0, 26)`, which equals pow(10, 93) exactly.
Criterion 4 red: ["1.23K"] expected to equal ["1.23e3"]. The red commit adds `enum Notation` and the unused `_notation` parameter so the test compiles.
Criterion 5 red: ["-1234"] expected to equal ["-1.23K"]; INF printed ".-9223372036854775808", NAN printed "-9223372036854775808.".
Criterion 6 red: sweep of each 10^k (k = 3..300) and the float one ulp below it, both notations. Fails with e.g. "100az starts with 9" (1 ulp below 1e93 gives digits 1000, shown cut to 100az), "1.000ai starts with 9", "9.9e27 starts with 1" (exact 10^27 divided by inexact 10^25 floors to 99). 269 failed asserts. The explicit 999999.9999999 -> 999K case already passes (exponent correction from criterion 2); kept as the spec's named example.
Refactor: split SUFFIX / SCIENTIFIC into `_suffixed` / `_scientific`, named SUFFIX_THRESHOLD and SIGNIFICANT_DIGITS, floori/posmod instead of implicit integer division. All checks green.
