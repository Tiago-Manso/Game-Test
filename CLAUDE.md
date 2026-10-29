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

To queue work: run `/refine-issue <idea or #number>` and refine it together
with Claude. It interviews you, writes `specs/<n>-<slug>.md`, creates the issue
and labels it `ready`. (By hand: write the spec from `specs/_template.md`, open
an issue linking it, add `ready`.) The loop opens one PR per issue
(label `autoloop`); a human reviews and merges.

## Conventions

- Branches from the loop: `loop/issue-<n>-<slug>`. Code never goes straight to `main`.
- Exception: `refine-issue` pushes spec-only commits (files under `specs/`) to
  `main` after the user approves the spec in the conversation.
- Keep changes scoped to the issue; extra ideas become new issues.
- Every acceptance criterion should be covered by a test where the stack allows.
