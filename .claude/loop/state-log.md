# Loop state logs

Every agent in the implementation loop keeps a log file, so that if a session,
container or agent dies, a new one can read the logs and continue exactly where
work stopped. Logs live on the issue's branch and are pushed, so they survive
the container; when the PR is merged they stay on `main` as the record of how
the issue was built.

```
.loop/issue-<n>/
  state.md                  orchestrator - stage, agent runs, findings, minor findings
  implementer.md            implementer - progress per criterion and per finding
  <agent>-r<k>.md           one per review agent and round, e.g. security-r2.md,
                            general-r1.md, po-r1.md
```

`.loop/` starts with a dot, so Godot ignores it.

## Rules for every agent

1. **Read your log first.** If your log file already exists, a previous agent
   of your type was interrupted: read it and continue from where it stopped
   instead of starting over.
2. **Write as you go.** Update your log after every meaningful step (a
   criterion finished, a finding found, a check run) - not only at the end.
   The first line is always `Status: in progress` or `Status: done`.
3. **Only your own file.** Never edit another agent's log or `state.md`.
4. **Who commits.** The implementer commits its log together with each of its
   own commits and pushes. Review agents don't commit; the orchestrator
   commits their logs after they return. The orchestrator commits `state.md`
   before starting an agent and after it returns, and pushes every time.

## state.md (orchestrator)

```markdown
Status: in progress
Issue: #12 Player movement   Attempt: 1/2
Branch: loop/issue-12-player-movement   PR: #34
Stage: review-round-2

## Stages
- [x] claimed
- [x] implemented (PR opened)
- [ ] specialist reviews (round 2 of min 2)
- [ ] general review
- [ ] PO go / no-go
- [ ] merged

## Specialist reviewers
| Reviewer    | Rounds | Last round majors | Done |
|-------------|--------|-------------------|------|
| quality     | 2      | 0                 | yes  |
| security    | 2      | 1                 | no   |
| tests       | 1      | -                 | no   |
| performance | 2      | 0                 | yes  |

## Agent runs
| # | Agent    | Round | Started (UTC)    | Status  | Log             |
|---|----------|-------|------------------|---------|-----------------|
| 1 | implementer | -  | 2026-11-05 10:02 | done    | implementer.md  |
| 2 | security | 1     | 2026-11-05 10:40 | done    | security-r1.md  |
| 9 | tests    | 2     | 2026-11-05 11:30 | started | tests-r2.md     |

## Findings
| ID      | Reviewer | Severity | Where            | Status   | Fix commit |
|---------|----------|----------|------------------|----------|------------|
| S1-M1   | security | major    | scripts/save.gd:40 | fixed  | abc1234    |
| Q1-m2   | quality  | minor    | scripts/hud.gd:12  | logged | -          |

## Minor findings (for future work)
- Q1-m2 scripts/hud.gd:12 - label text built in _process every frame.
```

A run marked `started` without `done` means that agent was interrupted:
start a fresh agent of the same type and tell it to resume from its log.

## Finding IDs

`<reviewer letter><round>-<M|m><n>`: `Q` quality, `S` security, `T` tests,
`P` performance, `G` general, `O` product owner; `M` major, `m` minor.
Example: `S2-M1` is the security reviewer's round-2 major finding 1.
