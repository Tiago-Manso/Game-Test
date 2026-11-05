Status: in progress
Issue: #2 Number formatting   Attempt: 1/2
Branch: loop/issue-2-number-formatting   PR: #18
Stage: review-round-1-fixes

## Stages
- [x] claimed
- [x] implemented (PR opened)
- [ ] specialist reviews
- [ ] general review
- [ ] PO go / no-go
- [ ] merged

## Specialist reviewers
| Reviewer    | Rounds | Last round blocking | Done |
|-------------|--------|-------------------|------|
| quality     | 1      | 0                 | no   |
| security    | 1      | 0                 | no   |
| tests       | 1      | 3                 | no   |
| performance | 1      | 0                 | no   |

## Agent runs
| # | Agent    | Round | Started (UTC)    | Status  | Log             |
|---|----------|-------|------------------|---------|-----------------|
| 1 | implementer | - | 2026-11-05 17:55 | done | implementer.md |
| 2 | quality | 1 | 2026-11-05 18:10 | done | quality-r1.md |
| 3 | security | 1 | 2026-11-05 18:10 | done | security-r1.md |
| 4 | tests | 1 | 2026-11-05 18:10 | done | tests-r1.md |
| 5 | performance | 1 | 2026-11-05 18:10 | done | performance-r1.md |
| 6 | implementer (fixes r1) | 1 | 2026-11-05 18:30 | started | implementer.md |

## Findings
| ID      | Reviewer | Severity | Where            | Status   | Fix commit |
|---------|----------|----------|------------------|----------|------------|
| T1-C1 | tests | critical | test/unit/test_number_format.gd:11 | open | - |
| T1-I1 | tests | important | test/unit/test_number_format.gd:19 | open | - |
| T1-I2 | tests | important | test/unit/test_number_format.gd:28 | open | - |
| T1-m1 | tests | minor | test/unit/test_number_format.gd:8 | logged | - |
| T1-m2 | tests | minor | test/unit/test_number_format.gd:34 | logged | - |
| Q1-m1 | quality | minor | scripts/core/number_format.gd:22 | logged | - |
| Q1-m2 | quality | minor | scripts/core/number_format.gd:48 | logged | - |
| Q1-m3 | quality | minor | scripts/core/number_format.gd:2 | logged | - |

## Tech debt (Minor and deferred Important)
- Q1-m1 (minor) scripts/core/number_format.gd:22 - format(-0.5) returns "-0" (literal spec reading); odd once negative changes are shown. Fix: only prefix "-" when the absolute value doesn't format as "0" (needs a spec note).
- Q1-m2 (minor) scripts/core/number_format.gd:48 - clamp bounds 100/999 hard-coded while SIGNIFICANT_DIGITS looks tunable; the suffix layout only works for 3. Fix: derive bounds or comment that 3 is fixed.
- Q1-m3 (minor) scripts/core/number_format.gd:2 - header swaps decisions: notation switch is D-016, big-number swap is D-021. Fix: reword.
- T1-m1 (minor) test/unit/test_number_format.gd:8 - "rounded down" below 1000 only shown by 999.9; add e.g. 7.6 -> "7".
- T1-m2 (minor) test/unit/test_number_format.gd:34 - -0.5 -> "-0" not pinned by a test either way (see Q1-m1).
