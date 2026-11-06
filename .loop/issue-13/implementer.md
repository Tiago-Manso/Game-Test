Status: done

# Implementer log - issue #13 CI workflow (attempt 1/2)

Tests for the tooling live in `tools/tests/` (Python unittest, PyYAML comes with
gdtoolkit): `python3 -m unittest discover -s tools/tests -v`. GUT can't run
`check.sh` (it would run GUT recursively) nor parse YAML.

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | check.sh exits 0 on head, names all four steps | green | fcc4974 | (this commit) |
| 2 | check.sh exits non-zero, names failing step | green | none: passed on first run (behaviour came with 57950fe); mutation check - removing the failure branch from check.sh gives `AssertionError: 0 == 0` in both tests | 57950fe (test: this commit) |
| 3 | ci.yml valid YAML, triggers, job `checks`, steps | green | ecc68ac | (this commit) |
| 4 | [manual] `checks` green on the PR | orchestrator | - | - |
| 5 | CLAUDE.md lists check.sh; implement-next Step 10 needs green `checks` | green | b53ce03 | (this commit) |

## Notes
- 414346b: untracked `tools/tests/__pycache__` committed by mistake; `__pycache__/` now in .gitignore.

## Findings
| ID | Severity | Outcome |
|----|----------|---------|
| T1-I1 | important | Deferred: nothing runs tools/tests automatically. Fixing it means adding a CI step and a CLAUDE.md command. The spec fixes the ci.yml steps (checkout, Python, install-godot.sh, check.sh) and the CLAUDE.md edit (only `tools/check.sh`), and this run must keep those edits to exactly the spec. Wiring tools/tests in needs a spec decision and belongs in a follow-up issue. |
| G1-I1 | important | fixed: red f22a476 (`244 not greater than 1037 : checks wait comes before the last push`); the wait moved from Step 10 item 1 to item 4, after item 3's push and before merge_pull_request (fix: this commit). T1-I1 (deferred) not affected. |

## Last checks (head before this commit: 23e6b87)
- import: pass
- lint: pass (gdlint scenes scripts test)
- format: pass (7 files unchanged)
- GUT: 33/33 passed
- tools/check.sh: exit 0, all four steps named
- tools tests (`python3 -m unittest discover -s tools/tests`): 11/11 passed (after G1-I1)
- tools/check.sh after G1-I1: exit 0
- [manual] `checks` workflow on the PR: for the orchestrator
