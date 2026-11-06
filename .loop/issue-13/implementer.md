Status: in progress

# Implementer log - issue #13 CI workflow (attempt 1/2)

Tests for the tooling live in `tools/tests/` (Python unittest, PyYAML comes with
gdtoolkit): `python3 -m unittest discover -s tools/tests -v`. GUT can't run
`check.sh` (it would run GUT recursively) nor parse YAML.

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | check.sh exits 0 on head, names all four steps | green | fcc4974 | (this commit) |
| 2 | check.sh exits non-zero, names failing step | green | none: passed on first run (behaviour came with 57950fe); mutation check - removing the failure branch from check.sh gives `AssertionError: 0 == 0` in both tests | 57950fe (test: this commit) |
| 3 | ci.yml valid YAML, triggers, job `checks`, steps | todo | - | - |
| 4 | [manual] `checks` green on the PR | orchestrator | - | - |
| 5 | CLAUDE.md lists check.sh; implement-next Step 10 needs green `checks` | todo | - | - |

## Notes
- 414346b: untracked `tools/tests/__pycache__` committed by mistake; `__pycache__/` now in .gitignore.

## Findings
None yet.

## Last checks
- tools tests: 3 passed (lint error and failing GUT test in a throwaway copy)
