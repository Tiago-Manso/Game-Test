Status: in progress
Issue: #2 Number formatting   Attempt: 1/2
Branch: loop/issue-2-number-formatting

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | Values below 1000 print as truncated integers | green | f6565fb | (this commit) |
| 2 | Suffix examples produce the exact strings | todo | - | - |
| 3 | Suffix sequence boundaries (T, aa, ab, ba) | todo | - | - |
| 4 | Scientific examples produce the exact strings | todo | - | - |
| 5 | Negative, INF and NAN cases | todo | - | - |
| 6 | No mantissa >= 1000 from 1e3 to 1e300 | todo | - | - |

## Findings
None yet.

## Last checks
Baseline (before any change): import 0, lint 0, format 0, tests 8/8 pass.
Criterion 1 red: test fails on assertions ([""] expected to equal ["0"]). The red commit adds a stub `NumberFormat.format` returning "" so the failure is the assertion, not a missing class.
