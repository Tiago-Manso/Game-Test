Status: in progress
Issue: #2 Number formatting   Attempt: 1/2
Branch: loop/issue-2-number-formatting

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | Values below 1000 print as truncated integers | green | f6565fb | 5b71971 |
| 2 | Suffix examples produce the exact strings | green | a2ff64e | 21a7d69 |
| 3 | Suffix sequence boundaries (T, aa, ab, ba) | green | 704388b (input fixed in 95b09cb) | 174f9d7 |
| 4 | Scientific examples produce the exact strings | green | 3bdc999 | e8e2c4b |
| 5 | Negative, INF and NAN cases | green | 568064c | d260575 |
| 6 | No mantissa >= 1000 from 1e3 to 1e300 | red | (this commit) | - |

## Findings
None yet.

## Last checks
Baseline (before any change): import 0, lint 0, format 0, tests 8/8 pass.
Criterion 1 red: test fails on assertions ([""] expected to equal ["0"]). The red commit adds a stub `NumberFormat.format` returning "" so the failure is the assertion, not a missing class.
Criterion 2 red: ["1234"] expected to equal ["1.23K"]. First green attempt gave "100K" for 1e6 (log() lands at 5.999...), so the exponent is corrected against pow(10, e).
Criterion 3 red: [""] expected to equal ["1.00T"] (SUFFIXES out of bounds at index 4: the sequence stops at M).
Criterion 3 test fix: the GDScript literal `1e93` parses to 9.999999999999999e+92 (Godot's float parser is not correctly rounded above 1e22; 118 of the powers 10^0..10^308 differ from pow(10, k)), so strict truncation rightly prints 999az for it. The test now computes the value as the spec writes it, `1e15 * pow(1000.0, 26)`, which equals pow(10, 93) exactly.
Criterion 4 red: ["1.23K"] expected to equal ["1.23e3"]. The red commit adds `enum Notation` and the unused `_notation` parameter so the test compiles.
Criterion 5 red: ["-1234"] expected to equal ["-1.23K"]; INF printed ".-9223372036854775808", NAN printed "-9223372036854775808.".
Criterion 6 red: sweep of each 10^k (k = 3..300) and the float one ulp below it, both notations. Fails with e.g. "100az starts with 9" (1 ulp below 1e93 gives digits 1000, shown cut to 100az), "1.000ai starts with 9", "9.9e27 starts with 1" (exact 10^27 divided by inexact 10^25 floors to 99). 269 failed asserts. The explicit 999999.9999999 -> 999K case already passes (exponent correction from criterion 2); kept as the spec's named example.
