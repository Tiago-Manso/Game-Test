Status: in progress
Issue: #2 Number formatting   Attempt: 1/2
Branch: loop/issue-2-number-formatting   PR: #18
Stage: general-review-2

## Stages
- [x] claimed
- [x] implemented (PR opened)
- [x] specialist reviews (2 rounds; r1 tests 1C+2I fixed, r2 0 blocking)
- [ ] general review
- [ ] PO go / no-go
- [ ] merged

## Specialist reviewers
| Reviewer    | Rounds | Last round blocking | Done |
|-------------|--------|-------------------|------|
| quality     | 2      | 0                 | yes  |
| security    | 2      | 0                 | yes  |
| tests       | 2      | 0                 | yes  |
| performance | 2      | 0                 | yes  |

## Agent runs
| # | Agent    | Round | Started (UTC)    | Status  | Log             |
|---|----------|-------|------------------|---------|-----------------|
| 1 | implementer | - | 2026-11-05 17:55 | done | implementer.md |
| 2 | quality | 1 | 2026-11-05 18:10 | done | quality-r1.md |
| 3 | security | 1 | 2026-11-05 18:10 | done | security-r1.md |
| 4 | tests | 1 | 2026-11-05 18:10 | done | tests-r1.md |
| 5 | performance | 1 | 2026-11-05 18:10 | done | performance-r1.md |
| 6 | implementer (fixes r1) | 1 | 2026-11-05 18:30 | done | implementer.md |
| 7 | quality | 2 | 2026-11-05 18:50 | done | quality-r2.md |
| 8 | security | 2 | 2026-11-05 18:50 | done | security-r2.md |
| 9 | tests | 2 | 2026-11-05 18:50 | done | tests-r2.md |
| 10 | performance | 2 | 2026-11-05 18:50 | done | performance-r2.md |
| 11 | general | 1 | 2026-11-05 19:00 | done | general-r1.md |
| 12 | implementer (fixes g1) | - | 2026-11-05 19:15 | done | implementer.md |
| 13 | general | 2 | 2026-11-05 19:25 | started | general-r2.md |

## Findings
| ID      | Reviewer | Severity | Where            | Status   | Fix commit |
|---------|----------|----------|------------------|----------|------------|
| T1-C1 | tests | critical | test/unit/test_number_format.gd:11 | fixed | 1e8d2a3 |
| T1-I1 | tests | important | test/unit/test_number_format.gd:19 | fixed | 55e8d17 |
| T1-I2 | tests | important | test/unit/test_number_format.gd:28 | fixed | ed3e881 |
| T1-m1 | tests | minor | test/unit/test_number_format.gd:8 | logged | - |
| T1-m2 | tests | minor | test/unit/test_number_format.gd:34 | logged | - |
| Q1-m1 | quality | minor | scripts/core/number_format.gd:22 | logged | - |
| Q1-m2 | quality | minor | scripts/core/number_format.gd:48 | logged | - |
| Q1-m3 | quality | minor | scripts/core/number_format.gd:2 | logged | - |
| Q2-m1 | quality | minor | test/unit/test_number_format.gd:77 | logged | - |
| G1-I1 | general | important | general (specs #2 vs #6/#7) | deferred: spec conflict for the user to settle via /refine-issue before #6; flagged on #6 and #7 | - |
| G1-m1 | general | minor | general | logged | - |
| G1-m2 | general | minor | general (specs/README, implement-next Step 10) | logged | - |

## Tech debt (Minor and deferred Important)
- G1-I1 (important, deferred) general - spec #2 prints values below 1000 as whole numbers, but spec #6 (`Upgrade: 5.72`) and spec #7 (`DPS: 9.00`) expect decimals via NumberFormat; fractional gold/costs show as e.g. "Gold: 5" vs disabled "Upgrade: 5". Reason: spec conflict, user decides via /refine-issue before #6 (either spec #2 gains 3 significant digits below 1000, or #6/#7 examples become `5`/`9`). Flagged on #6 and #7.
- Q1-m1 (minor) scripts/core/number_format.gd:22 - format(-0.5) returns "-0" (literal spec reading); odd once negative changes are shown. Fix: only prefix "-" when the absolute value doesn't format as "0" (needs a spec note).
- Q1-m2 (minor) scripts/core/number_format.gd:48 - clamp bounds 100/999 hard-coded while SIGNIFICANT_DIGITS looks tunable; the suffix layout only works for 3. Fix: derive bounds or comment that 3 is fixed.
- Q1-m3 (minor) scripts/core/number_format.gd:2 - header swaps decisions: notation switch is D-016, big-number swap is D-021. Fix: reword.
- T1-m1 (minor) test/unit/test_number_format.gd:8 - "rounded down" below 1000 only shown by 999.9; add e.g. 7.6 -> "7".
- T1-m2 (minor) test/unit/test_number_format.gd:34 - -0.5 -> "-0" not pinned by a test either way (see Q1-m1).
- Q2-m1 (minor) test/unit/test_number_format.gd:77 - sweep checks SCIENTIFIC twice: `_assert_mantissa` loops both notations, but the exact `1.00e%d`/`9.99e%d` asserts already cover it. Fix: `_assert_mantissa` checks SUFFIX only (drop the loop and `limit` ternary).
- G1-m1 (minor) general - Godot float parsing isn't correctly rounded above ~1e22: JSON round trip of 10^k changes 115 of k=3..300 (14 change the display, e.g. 10^23 `100ac` -> `99.9ac`); default JSON.stringify keeps ~14 significant digits so gold drifts on save/load. Fix: note in #8 - save floats losslessly (var_to_str or the double's bytes/hex) and test the round trip.
- G1-m2 (minor) general - specs never reach `Status: done`: specs/README says in-review -> done on merge, but implement-next Step 10 never sets it (spec #1 on main still in-review). Fix: set the spec's Status: done in the merge step.
