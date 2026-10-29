---
name: implement-next
description: Run one iteration of the autonomous implementation loop - fix review feedback on open loop PRs, otherwise pick the next `ready` GitHub issue, implement it from its spec in specs/, and open a PR. Use when asked to "implement the next issue", "run the loop", or via `/loop /implement-next` or a scheduled task.
---

# implement-next: one iteration of the autonomous loop

Each run does **at most one unit of work** and then stops. Repetition comes from
outside: `/loop /implement-next` in a session, or a scheduled task whose prompt
is `/implement-next`. Never chain a second task in the same run.

Work items are GitHub issues in this repository. Details live in `specs/`.
Read `CLAUDE.md` first for build/test commands and conventions.

Use the GitHub MCP tools (`mcp__github__*`) for all GitHub operations. If they
are unavailable, fall back to `gh`. If neither works, stop and report it.

## Labels

| Label         | Meaning                                                        |
|---------------|----------------------------------------------------------------|
| `ready`       | Issue is fully specified; the loop may pick it up.             |
| `in-progress` | Claimed by a loop run. Others must skip it.                    |
| `needs-spec`  | The loop found the issue/spec too ambiguous. Human must clarify. |
| `blocked`     | The loop tried and failed. Comment explains why.               |
| `autoloop`    | Set on every PR the loop opens.                                |
| `priority:high` | Picked before other `ready` issues.                          |

Adding a label that does not exist yet creates it; don't stop over a missing label.

## Limits

- `MAX_OPEN_PRS = 3`: if this many open PRs carry `autoloop`, do not start new
  work (step 2 still runs). The human merges; the loop must not outrun review.
- One issue per run. One PR per issue. One branch per PR.
- Never push to `main`, never merge a PR, never force-push a branch you didn't create in this loop.
- Never skip, disable or delete a test to get green.

## Step 1 - Sync

```bash
git fetch origin
git checkout main && git pull --ff-only origin main
```

If `main` doesn't exist, use the repository's default branch.

## Step 2 - Feedback first

List open PRs labelled `autoloop`. For each, in order of oldest first, check:

- failing CI on the head commit, or
- review comments / "changes requested" from a human that have no reply from the loop yet.

If any PR has either, take the **first** one: check out its branch, fix the
failure or address the comments (small, local asks: implement; large or
design-level asks: reply with a proposal and do not push), run the checks from
`CLAUDE.md`, push, reply on each thread you handled, and **stop the run**.

## Step 3 - Capacity check

If the number of open `autoloop` PRs is `>= MAX_OPEN_PRS`, report
"waiting on review" and stop.

## Step 4 - Pick an issue

List open issues labelled `ready` and **not** labelled `in-progress`,
`blocked`, or `needs-spec`. Order: `priority:high` first, then lowest issue
number. Take the first one. If there are none, report "backlog empty" and stop.

Claim it immediately: add `in-progress`, and comment
`Picked up by the implementation loop.` (plus the footer required by your
environment, if any).

## Step 5 - Understand the task

1. Read the issue body and all comments.
2. Open the spec it links (`specs/<number>-<slug>.md`). If the issue has no
   spec but is small and unambiguous, create one from `specs/_template.md`
   as part of your change.
3. Read any other specs it references and the code it touches.

**Ambiguity gate.** If you cannot state the acceptance criteria as concrete,
checkable items, or the spec contradicts the code or another spec, do not
guess. Comment on the issue with numbered, specific questions; swap
`in-progress` and `ready` for `needs-spec`; stop the run. The user answers
them with `/refine-issue #<number>`.

## Step 6 - Implement

```bash
git checkout -b loop/issue-<number>-<short-slug> origin/main
```

- Make the smallest change that satisfies every acceptance criterion.
- Add or update tests for each criterion where the project has tests.
- Match the existing code style; follow `CLAUDE.md`.
- Do not widen scope. Anything extra you notice becomes a new issue
  (no `ready` label) - mention it in the PR, don't build it.
- Update the spec: set `Status: in-review` and tick the criteria you met.

## Step 7 - Verify

Run every check listed in `CLAUDE.md` (build, lint, tests). Then re-read your
diff against the acceptance criteria one by one.

If checks fail and you can't fix them within a reasonable effort (about three
honest attempts at the root cause), go to **Failure**.

## Step 8 - Ship

Commit with a message like `Implement #<n>: <title>` and push:

```bash
git push -u origin loop/issue-<number>-<short-slug>
```

Open a PR against `main`:

- Title: `<issue title> (#<number>)`
- Body: follow `.github/pull_request_template.md`; include `Closes #<number>`,
  the spec path, each acceptance criterion with how it's verified, and the
  checks you ran with their result.
- Label: `autoloop`.

Remove `in-progress` from the issue (the open PR now tracks it). Stop the run.

## Failure

Commit and push whatever partial work is useful to the branch (no PR).
Comment on the issue: what you tried, the exact error, and what you think is
needed. Swap `in-progress` for `blocked`. Stop the run.

## Report

End every run with a 1-3 line summary: what was done (issue/PR link) or why
nothing was done (waiting on review / backlog empty / needs-spec / blocked).
