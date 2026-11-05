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

Every finding gets exactly one of three severities.

- **Critical** - merging as-is is unsafe or wrong: an acceptance-criterion
  violation that defeats the issue's goal, a bug with a concrete input ->
  wrong output or crash, or a security / data-integrity risk. **Blocks merge.**
  Can't be deferred.
- **Important** - it works, but carries real cost the team shouldn't wave
  through silently: a cited guideline violation (`CLAUDE.md`, the spec, the
  reviewer guides), missing test coverage for a behaviour change, a concrete
  performance issue (per-frame allocation or lookup in a hot path, wrong data
  structure, work that grows with play time), or an unexplained deviation from
  the local pattern. **Fix before merge unless explicitly deferred with a
  stated reason.**
- **Minor** - correct and mergeable, but improvable: a nit within a
  guideline's latitude, a marginal "better way" where the current code is
  fine, cosmetic naming. **A suggestion, not a gate:** logged as tech debt, to be
  analysed and fixed later if required - not fixed in this PR.

How to choose:

- For Critical, name the concrete input, state or scenario and the wrong
  result. If you can't, it isn't Critical.
- For Important, cite the guideline, the missing test, the hot path (how
  often it runs) or the local pattern it departs from.
- When in doubt between two levels, pick the lower one and say why it might
  be higher.
- Failing checks (import, lint, format, tests) are always **Critical**.

**Deferral.** The implementer may answer an Important finding with
`Deferred: <reason>` instead of fixing it (e.g. it needs a design decision, or
belongs to a later issue). In later rounds, judge each deferral: a sound
reason settles it - don't raise it again; an unsound one is re-raised under
its original ID with why the reason doesn't hold. Deferred Importants are
grouped with the Minors as tech debt at merge.

Don't pad. An empty list is a good result.

## Where findings point

Findings are posted as inline comments on the pull request. Give the
repo-relative path and a line number **as it is in the branch's version of
the file**, on a line the diff changed. If a finding isn't about a changed
line (a missing test, the commit history, a design concern), write `general`;
it goes in the review body.

## Output (also the content of your log, under `Status: done`)

```
VERDICT: NO BLOCKING ISSUES | BLOCKING ISSUES

## Critical
- [<ID>] path/to/file.gd:42 - concrete input/scenario -> wrong result. Why it matters. Suggested fix.

## Important
- [<ID>] path/to/file.gd:58 - problem, and the guideline / test / hot path / pattern it concerns. Suggested fix.

## Minor
- [<ID>] path/to/file.gd:17 - suggestion.

## Earlier findings (round 2+)
- [<ID>] fixed | not fixed | deferred: reason sound / reason doesn't hold - note

## What I ran
- <command>: <result>
```

"Blocking" means any Critical, or any Important that isn't deferred.

Use the finding IDs from `.claude/loop/state-log.md` (e.g. `S2-C1`, `S2-I2`, `S2-m3`).
