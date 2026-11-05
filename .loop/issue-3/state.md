Status: in progress
Issue: #3 Balance config   Attempt: 1/2
Branch: loop/issue-3-balance-config   PR: #20
Stage: po-1

## Stages
- [x] claimed
- [x] implemented (PR opened)
- [x] specialist reviews (2 rounds; r1 Q1-I1 fixed, r2 0 blocking)
- [x] general review (1 round, 0 blocking)
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
| 1 | implementer | - | 2026-11-05 19:50 | done | implementer.md |
| 2 | quality | 1 | 2026-11-05 20:00 | done | quality-r1.md |
| 3 | security | 1 | 2026-11-05 20:00 | done | security-r1.md |
| 4 | tests | 1 | 2026-11-05 20:00 | done | tests-r1.md |
| 5 | performance | 1 | 2026-11-05 20:00 | done | performance-r1.md |
| 6 | implementer (fixes r1) | 1 | 2026-11-05 20:10 | done | implementer.md |
| 7 | quality | 2 | 2026-11-05 20:20 | done | quality-r2.md |
| 8 | security | 2 | 2026-11-05 20:20 | done | security-r2.md |
| 9 | tests | 2 | 2026-11-05 20:20 | done | tests-r2.md |
| 10 | performance | 2 | 2026-11-05 20:20 | done | performance-r2.md |
| 11 | general | 1 | 2026-11-05 20:30 | done | general-r1.md |
| 12 | product-owner | 1 | 2026-11-05 20:40 | started | po-r1.md |

## Findings
| ID      | Reviewer | Severity | Where            | Status   | Fix commit |
|---------|----------|----------|------------------|----------|------------|
| Q1-I1 | quality | important | scripts/core/balance_config.gd:21 | fixed | 55ce5cc |
| Q1-m1 | quality | minor | scripts/core/balance_config.gd:57 | logged | - |
| S1-m1 | security | minor | scripts/core/balance_config.gd:27 | logged | - |
| S1-m2 | security | minor | scripts/core/balance_config.gd:47 | logged | - |
| T1-m1 | tests | minor | test/unit/test_balance_config.gd:126 | logged | - |
| T2-m1 | tests | minor | test/unit/test_balance_config.gd:46 | logged | - |
| G1-m1 | general | minor | scripts/core/balance_config.gd:20 | logged | - |

## Tech debt (Minor and deferred Important)
- Q1-m1 (minor) scripts/core/balance_config.gd:57 - `unit_by_id` reads `unit.id` without a null check; an empty slot in `units` (easy in the inspector) crashes. Fix: `if unit != null and unit.id == id:`.
- S1-m1 (minor) scripts/core/balance_config.gd:27 - growth formulas overflow to INF for huge inputs (block_hp(14548), tap_upgrade_cost(10493), unit_cost(pistol, 10500)); negatives give 0/negative. An edited save with destroyed_count = 1e6 would spawn an unkillable INF-HP block (softlock; Critical in #8). Fix (in #8): clamp loaded counts/levels to a sane max or reject non-finite formula results.
- S1-m2 (minor) scripts/core/balance_config.gd:47 - `unit_dps`/`unit_cost` dereference `unit` without a null check while `unit_by_id` returns null by design; a save-file unit id passed straight through would crash. Fix: document/assert non-null; #7/#8 callers skip null units.
- T1-m1 (minor) test/unit/test_balance_config.gd:126 - `unit_by_id` only tested with the middle entry; a mutant returning `units[1]` on any match passes. Fix: also `assert_same` pistol -> units[0], rocket -> units[2].
- T2-m1 (minor) test/unit/test_balance_config.gd:46 - identity checks use `assert_ne` (works because Object `==` is identity); the file already uses `assert_same`. Fix: `assert_not_same` for the config and `units[0]`.
- G1-m1 (minor) scripts/core/balance_config.gd:20 - the Q1-I1 fix only covers `load_default()`; `preload`/`load` of balance.tres or an `@export var config: BalanceConfig` pointing at it (spec #14's suggested seam) returns the shared cached instance again, indistinguishable by `resource_path`. Fix: class doc line - get the default config only through load_default().
