# Game-Test

## Project

A game project. Stack not chosen yet - update this section once it is.

## Commands

<!-- Fill these in once the project has a stack. The implementation loop runs every one before opening a PR. -->

- Install: _TBD_
- Build: _TBD_
- Lint: _TBD_
- Test: _TBD_

## Autonomous implementation loop

Work is queued as GitHub issues and specified in `specs/`. One iteration is the
`implement-next` skill (`.claude/skills/implement-next/SKILL.md`).

- Run continuously in a session: `/loop /implement-next` (or `/loop 30m /implement-next`).
- Run on a schedule: a scheduled task whose prompt is `/implement-next`.

To queue work: write `specs/<n>-<slug>.md` from `specs/_template.md`, open an
issue linking it, then add the `ready` label. The loop opens one PR per issue
(label `autoloop`); a human reviews and merges.

## Conventions

- Branches from the loop: `loop/issue-<n>-<slug>`. Never push to `main`.
- Keep changes scoped to the issue; extra ideas become new issues.
- Every acceptance criterion should be covered by a test where the stack allows.
