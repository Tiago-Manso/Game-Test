Status: in progress
Issue: #13 CI workflow   Attempt: 1/2
Branch: loop/issue-13-ci-workflow   PR: #22
Stage: review-round-2

## Stages
- [x] claimed
- [x] implemented (PR opened)
- [ ] specialist reviews
- [ ] general review
- [ ] PO go / no-go
- [ ] merged

## Specialist reviewers
| Reviewer    | Rounds | Last round blocking | Done |
|-------------|--------|---------------------|------|
| quality     | 1      | 0                   | no   |
| security    | 1      | 0                   | no   |
| tests       | 1      | 1                   | no   |
| performance | 1      | 0                   | no   |

## Agent runs
| # | Agent | Round | Started (UTC) | Status | Log |
|---|-------|-------|---------------|--------|-----|
| 1 | implementer | - | 2026-11-06 | done | implementer.md |
| 2 | quality | 1 | 2026-11-06 | done | quality-r1.md |
| 3 | security | 1 | 2026-11-06 | done | security-r1.md |
| 4 | tests | 1 | 2026-11-06 | done | tests-r1.md |
| 5 | performance | 1 | 2026-11-06 | done | performance-r1.md |
| 6 | implementer | fixes r1 | 2026-11-06 | done | implementer.md |
| 7 | quality | 2 | 2026-11-06 | started | quality-r2.md |
| 8 | security | 2 | 2026-11-06 | started | security-r2.md |
| 9 | tests | 2 | 2026-11-06 | started | tests-r2.md |
| 10 | performance | 2 | 2026-11-06 | started | performance-r2.md |

## Findings
| ID | Reviewer | Severity | Where | Status | Fix commit |
|----|----------|----------|-------|--------|------------|
| T1-I1 | tests | important | general (tools/tests not run by CI/check.sh/CLAUDE.md) | open | - |
| Q1-m1 | quality | minor | general (tools/tests not run anywhere) | logged | - |
| Q1-m2 | quality | minor | .github/workflows/ci.yml:14 | logged | - |
| Q1-m3 | quality | minor | tools/check.sh:20 | logged | - |
| S1-m1 | security | minor | .github/workflows/ci.yml:18 | logged | - |
| S1-m2 | security | minor | tools/install-godot.sh:19 | logged | - |
| S1-m3 | security | minor | .github/workflows/ci.yml:16 | logged | - |
| T1-m1 | tests | minor | general (criterion 2 had no red commit) | logged | - |
| T1-m2 | tests | minor | tools/tests/test_loop_docs.py:33 | logged | - |
| T1-m3 | tests | minor | tools/tests/test_ci_workflow.py:86 | logged | - |
| T1-m4 | tests | minor | tools/tests/test_check_sh.py:15 | logged | - |
| P1-m1 | performance | minor | .github/workflows/ci.yml:13 | logged | - |
| P1-m2 | performance | minor | .github/workflows/ci.yml:16 | logged | - |
| P1-m3 | performance | minor | .github/workflows/ci.yml:20 | logged | - |

## Tech debt (Minor and deferred Important)
- T1-I1 (important, deferred) general - tools/tests (test_ci_workflow, test_loop_docs) not run by CI or listed in CLAUDE.md; reason: spec fixes the ci.yml steps and the CLAUDE.md edit, so wiring them in needs a follow-up spec.
- Q1-m1 (minor) general - tools/tests Python tests are not run by check.sh, CI or listed in CLAUDE.md; add a CI step for test_ci_workflow/test_loop_docs.
- Q1-m2 (minor) .github/workflows/ci.yml:14 - no timeout-minutes on `checks`; add timeout-minutes: 20.
- Q1-m3 (minor) tools/check.sh:20 - `godot --import` exits 0 on a scene with a missing ext_resource; CLAUDE.md claim "catches broken resources" is false; follow-up: a step that loads every .tscn/.tres headless.
- S1-m1 (minor) .github/workflows/ci.yml:18 - actions pinned to movable major tags; pin to SHAs if secrets are ever added.
- S1-m2 (minor) tools/install-godot.sh:19 - Godot zip not checked against SHA512-SUMS; gdtoolkit==4.* not exact.
- S1-m3 (minor) .github/workflows/ci.yml:16 - no timeout-minutes; also consider concurrency with cancel-in-progress.
- T1-m1 (minor) general - criterion 2's tests (af04ecc) came after its code (57950fe); mutation shows they now guard it.
- T1-m2 (minor) tools/tests/test_loop_docs.py:33 - `implementer` regex can never fail; assert a phrase tying wait/succeeded to `checks`.
- T1-m3 (minor) tools/tests/test_ci_workflow.py:86 - cache path check only asserts "godot" in path; assert ~/.local/bin/godot and PATH step before install.
- T1-m4 (minor) tools/tests/test_check_sh.py:15 - import/format failures and step order not tested.
- P1-m1 (minor) .github/workflows/ci.yml:13 - no concurrency group; superseded PR runs waste minutes.
- P1-m2 (minor) .github/workflows/ci.yml:16 - no timeout-minutes (dup of Q1-m2/S1-m3).
- P1-m3 (minor) .github/workflows/ci.yml:20 - gdtoolkit pip-installed every run, not cached.
