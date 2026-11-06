Status: in progress
Issue: #4 Blocks and slots   Attempt: 1/2
Branch: loop/issue-4-blocks-and-slots   PR: #23
Stage: review-round-2

## Stages
- [x] claimed
- [x] implemented (PR opened)
- [ ] specialist reviews (round 1 done: 0 blocking)
- [ ] general review
- [ ] PO go / no-go
- [ ] merged

## Specialist reviewers
| Reviewer    | Rounds | Last round blocking | Done |
|-------------|--------|-------------------|------|
| quality     | 1      | 0                 | no   |
| security    | 1      | 0                 | no   |
| tests       | 1      | 0                 | no   |
| performance | 1      | 0                 | no   |

## Agent runs
| # | Agent    | Round | Started (UTC)    | Status  | Log             |
|---|----------|-------|------------------|---------|-----------------|
| 1 | implementer | - | 2026-11-06 10:55 | done | implementer.md |
| 2 | quality | 1 | 2026-11-06 11:06 | done | quality-r1.md |
| 3 | security | 1 | 2026-11-06 11:06 | done | security-r1.md |
| 4 | tests | 1 | 2026-11-06 11:06 | done | tests-r1.md |
| 5 | performance | 1 | 2026-11-06 11:06 | done | performance-r1.md |
| 6 | quality | 2 | 2026-11-06 11:10 | started | quality-r2.md |
| 7 | security | 2 | 2026-11-06 11:10 | started | security-r2.md |
| 8 | tests | 2 | 2026-11-06 11:10 | started | tests-r2.md |
| 9 | performance | 2 | 2026-11-06 11:10 | started | performance-r2.md |

## Findings
| ID      | Reviewer | Severity | Where            | Status   | Fix commit |
|---------|----------|----------|------------------|----------|------------|
| Q1-m1 | quality | minor | scripts/core/block_field.gd:48 | logged | - |
| Q1-m2 | quality | minor | scenes/field/field.gd:21 | logged | - |
| Q1-m3 | quality | minor | scenes/field/field.gd:1 | logged | - |
| S1-m1 | security | minor | scripts/core/block_field.gd:25 | logged | - |
| S1-m2 | security | minor | scripts/core/block_field.gd:48 | logged | - |
| T1-m1 | tests | minor | test/unit/test_block_field.gd:55 | logged | - |
| T1-m2 | tests | minor | test/unit/test_block_field.gd:134 | logged | - |

## Tech debt (Minor and deferred Important)
- Q1-m1 (minor) scripts/core/block_field.gd:48 - `hp(-1)`/`max_hp(-1)`/`gold(-1)` return slot 4's value (packed arrays wrap negative indices); `hp(5)` raises out-of-bounds. Fix: guard like `has_block` (return 0.0) or assert.
- S1-m2 (minor) scripts/core/block_field.gd:48 - same root as Q1-m1; matters for #7 since `lowest_hp_slot()` can return -1 and `hp(-1)` gives slot 4's HP. Fix: return 0.0 out of range.
- S1-m1 (minor) scripts/core/block_field.gd:25 - `initial_destroyed_count` unbounded; #8 will feed it from an editable save: 100000 -> INF HP, unbreakable blocks (softlock); large negative -> HP 0/gold 0. Fix (in #8 or here): clamp count or reject saves where `is_finite(block_hp(count))` is false. Should rate higher once #8 connects saves.
- Q1-m2 (minor) scenes/field/field.gd:21 - `setup()` twice adds a second set of slots and double-connects signals. Fix: `assert(_field == null)` or clear/disconnect first.
- Q1-m3 (minor) scenes/field/field.gd:1 - field script has no `class_name`, so callers call `setup`/`block_count`/`hp_bar` dynamically on a `Control` (CLAUDE.md static typing). Fix: add e.g. `class_name FieldView` and type callers.
- T1-m1 (minor) test/unit/test_block_field.gd:55 - empty-slot damage test's snapshot omits the respawn countdown; a mutant that resets the countdown passes. Fix: break slot, tick(0.3), damage it, assert respawn still at 0.5 s total.
- T1-m2 (minor) test/unit/test_block_field.gd:134 - test covers two behaviours (full field ignores tick; non-positive/NaN delta keeps countdown) and ends asserting a respawn. Fix: split into two tests.
