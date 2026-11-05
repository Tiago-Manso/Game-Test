Status: in progress
Issue: #1 Project skeleton   Attempt: 1/2
Branch: loop/issue-1-project-skeleton   PR: #15
Stage: general-review-1

## Stages
- [x] claimed
- [x] implemented (PR opened)
- [x] specialist reviews (2 rounds, 0 blocking)
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
| 1 | implementer | - | 2026-11-05 16:50 | done | implementer.md |
| 2 | quality | 1 | 2026-11-05 17:00 | done | quality-r1.md |
| 3 | security | 1 | 2026-11-05 17:00 | done | security-r1.md |
| 4 | tests | 1 | 2026-11-05 17:00 | done | tests-r1.md |
| 5 | performance | 1 | 2026-11-05 17:00 | done | performance-r1.md |
| 6 | quality | 2 | 2026-11-05 17:10 | done | quality-r2.md |
| 7 | security | 2 | 2026-11-05 17:10 | done | security-r2.md |
| 8 | tests | 2 | 2026-11-05 17:10 | done | tests-r2.md |
| 9 | performance | 2 | 2026-11-05 17:10 | done | performance-r2.md |
| 10 | general | 1 | 2026-11-05 17:20 | started | general-r1.md |

## Findings
| ID      | Reviewer | Severity | Where            | Status   | Fix commit |
|---------|----------|----------|------------------|----------|------------|
| Q1-m1 | quality | minor | scenes/main/main.tscn:3 | logged | - |
| S1-m1 | security | minor | general | logged | - |
| T1-m1 | tests | minor | general | logged | - |
| T1-m2 | tests | minor | scenes/main/main.tscn:18 | logged | - |
| P1-m1 | performance | minor | scenes/main/main.tscn:11 | logged | - |
| P1-m2 | performance | minor | general | logged | - |
| P1-m3 | performance | minor | general | logged | - |

## Tech debt (Minor and deferred Important)
- Q1-m1 (minor) scenes/main/main.tscn:3 - root `Main` Control keeps default mouse_filter STOP; once gameplay reads taps in `_unhandled_input`, it would swallow them. Fix: set root mouse_filter to IGNORE/PASS (now or in the first input issue).
- S1-m1 (minor) general - GUT editor GUI code (OS.execute, shell_open) and `test/` would ship in an export unless filtered. Fix (export issue): exclude `addons/gut/*` and `test/*` in every preset; consider committing export_presets.cfg without credentials.
- T1-m1 (minor) general - project name, `config/features` vs `.godot-version`, and GUT plugin enabled are untested. Fix: add tests to test_project_settings.gd.
- T1-m2 (minor) scenes/main/main.tscn:18 - Background `mouse_filter = IGNORE` is untested. Fix: assert it in test_main_scene.gd (or in the first input issue).
- P1-m1 (minor) scenes/main/main.tscn:11 - full-screen ColorRect background adds a full-screen overdraw quad per frame. Fix: use `rendering/environment/defaults/default_clear_color` instead.
- P1-m2 (minor) general - no renderer chosen (Forward+/Mobile default); `gl_compatibility` is usually better for a 2D mobile game. Fix: decide explicitly (here or in the export/mobile issue).
- P1-m3 (minor) general - exports should exclude `addons/gut/*` and `test/*` (size/load time). Fix: export filters in the export issue.
