# specs/

Detailed specifications for work items. GitHub issues are the queue; specs hold
the detail an implementer (human or the loop) needs.

## Conventions

- One file per issue: `specs/<issue-number>-<short-slug>.md`, e.g. `specs/12-player-movement.md`.
- Start from [`_template.md`](_template.md).
- Link the spec from the issue body. The issue stays short; the spec is the source of truth.
- Shared, cross-cutting design (architecture, game rules, art style) can live in
  unnumbered files such as `specs/architecture.md` and be referenced from task specs.

## Status lifecycle

`draft` → `ready` → `in-review` → `done`

- **draft**: still being written. Don't label the issue `ready` yet.
- **ready**: acceptance criteria are concrete and checkable. Label the issue `ready`.
- **in-review**: the loop opened a PR (it sets this).
- **done**: PR merged.

## What makes a spec loop-ready

- Acceptance criteria are concrete and verifiable (a test, a command, an observable behaviour).
- Out-of-scope items are listed, so the implementer doesn't widen the change.
- Open questions are resolved or removed.

If the loop can't meet these, it labels the issue `needs-spec` and asks its
questions on the issue.
