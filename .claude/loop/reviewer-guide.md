# Reviewer guide

Shared rules for every review agent in the loop: `quality-reviewer`,
`security-reviewer`, `test-reviewer`, `performance-reviewer`,
`general-reviewer` and `product-owner`. Each agent's own file says what it
focuses on; this file says how every review works.

## Before you start

- Read `CLAUDE.md`, the spec you are given, and `.claude/loop/state-log.md`.
- Your log file is `.loop/issue-<n>/<your-log-name>-r<round>.md` (the
  orchestrator gives you the exact path). If it exists, you were interrupted:
  continue from it.
- Get the change: `git log --oneline origin/main..HEAD` and
  `git diff origin/main...HEAD`. Review the **whole** change, not just the
  latest commits, and don't assume earlier rounds caught everything.
- If earlier rounds exist, you get their findings and the implementer's
  replies. List each one as fixed / not fixed under `## Earlier findings`.

## Read-only, and a private copy for running things

You never edit code, tests, specs or other logs, and never commit. The only
file you write is your own log.

Several reviewers run **in parallel** on the same checkout. If you need to run
Godot (tests, import, a benchmark) or check out another commit, do it in your
own worktree, never in the shared checkout:

```bash
wt="$(mktemp -d)/review"
git worktree add --detach "$wt" HEAD      # or <sha> for an older commit
(cd "$wt" && godot --headless --path . --import && <command>)
git worktree remove --force "$wt"
```

## Severity

- **major** - must be fixed before merge: wrong behaviour, a real
  vulnerability, a test that doesn't prove what it claims, a missing test for
  a spec criterion, a performance problem a player would notice on a phone,
  failing checks, anything that will clearly hurt later work.
- **minor** - worth doing some day, not now: naming, small simplifications,
  micro-optimisations, nice-to-have tests. Minor findings are **not fixed in
  this PR**: they are logged for future work, so only call something major if
  it truly blocks.

Don't pad. An empty list is a good result.

## Where findings point

Findings are posted as inline comments on the pull request. Give the
repo-relative path and a line number **as it is in the branch's version of
the file**, on a line the diff changed. If a finding isn't about a changed
line (a missing test, the commit history, a design concern), write `general`;
it goes in the review body.

## Output (also the content of your log, under `Status: done`)

```
VERDICT: NO MAJOR ISSUES | MAJOR ISSUES

## Major
- [<ID>] path/to/file.gd:42 - problem. Why it matters. Suggested fix.

## Minor
- [<ID>] path/to/file.gd:17 - suggestion.

## Earlier findings (round 2+)
- [<ID>] fixed | not fixed - note

## What I ran
- <command>: <result>
```

Use the finding IDs from `.claude/loop/state-log.md` (e.g. `S2-M1`, `S2-m3`).
