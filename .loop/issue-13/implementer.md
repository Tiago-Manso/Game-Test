Status: in progress

# Implementer log - issue #13 CI workflow (attempt 1/2)

Tests for the tooling live in `tools/tests/` (Python unittest, PyYAML comes with
gdtoolkit): `python3 -m unittest discover -s tools/tests -v`. GUT can't run
`check.sh` (it would run GUT recursively) nor parse YAML.

## Criteria
| # | Criterion | Status | Red | Green |
|---|-----------|--------|-----|-------|
| 1 | check.sh exits 0 on head, names all four steps | red | (this commit) | - |
| 2 | check.sh exits non-zero, names failing step | todo | - | - |
| 3 | ci.yml valid YAML, triggers, job `checks`, steps | todo | - | - |
| 4 | [manual] `checks` green on the PR | orchestrator | - | - |
| 5 | CLAUDE.md lists check.sh; implement-next Step 10 needs green `checks` | todo | - | - |

## Findings
None yet.

## Last checks
- tools tests: 1 failed (expected red: `AssertionError: 1 != 0 : check.sh: not implemented`)
