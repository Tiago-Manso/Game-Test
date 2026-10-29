---
name: implement-next
description: Run one iteration of the autonomous implementation loop - fix review feedback on open loop PRs, otherwise pick the next `ready` GitHub issue and have it implemented with TDD by an implementer agent, reviewed by a code-reviewer agent and accepted by a product-owner agent before opening a PR. Use when asked to "implement the next issue", "run the loop", or via `/loop /implement-next` or a scheduled task.
---

# implement-next: one iteration of the autonomous loop

Each run does **at most one unit of work** and then stops. Repetition comes from
outside: `/loop /implement-next` in a session, or a scheduled task whose prompt
is `/implement-next`. Never chain a second task in the same run.

Work items are GitHub issues in this repository. Details live in `specs/`.
Read `CLAUDE.md` first for build/test commands and conventions.

## Roles

You, running this skill, are the **orchestrator**: you handle git sync,
GitHub, labels and the hand-offs. You do **not** write production code or
tests yourself. Three subagents (defined in `.claude/agents/`) do the work,
started with the Agent tool:

| Agent           | `subagent_type`  | Job                                                    |
|-----------------|------------------|--------------------------------------------------------|
| Implementer     | `implementer`    | Writes tests and code with strict TDD; fixes findings. |
| Code reviewer   | `code-reviewer`  | Independent review of code, tests and TDD. Read-only.  |
| Product owner   | `product-owner`  | Accepts or rejects against the spec. Final gate before any PR. Read-only. |

Run them in the foreground (`run_in_background: false`), one at a time - they
share the working tree. Keep each agent's ID: send follow-ups to the **same**
implementer and reviewer with `SendMessage` so they keep their context. Pass
each agent everything it needs in its prompt (issue number, title, body and
comments, spec path, branch); it has no other context. Never pass the
reviewer or PO your own opinion of the code - give them the branch and let
them judge. If `SendMessage` is unavailable, start a fresh agent of the same
type and include its previous report plus the new findings in the prompt.

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
- `MAX_REVIEW_ROUNDS = 3` (implementer <-> code reviewer) and
  `MAX_PO_ROUNDS = 2` (PO rejections) per issue. Hitting either means **Failure**.

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

If any PR has either, take the **first** one and check out its branch.

- Large or design-level asks: reply with a proposal on the thread, don't change code.
- Everything else: give the failure / comments to a new `implementer` (TDD
  still applies), then run the **review loop** (Step 7). If the fix changes
  behaviour covered by an acceptance criterion, also run the **PO gate**
  (Step 8).
- Push, reply on each thread you handled with the commit that addressed it,
  and **stop the run**.

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

## Step 6 - Implement (TDD)

```bash
git checkout -b loop/issue-<number>-<short-slug> origin/main
```

Start an `implementer` with: issue number, title, body and comments, spec
path, branch name. It works criterion by criterion: failing test (`[red]`
commit), minimum code to pass (`[green]` commit), refactor (`[refactor]`
commit). It returns a TDD log, manual-check steps, check results and follow-ups.

If it reports `STATUS: STUCK`, go to **Failure**.

## Step 7 - Review loop (implementer <-> code reviewer)

1. Start a `code-reviewer` with: spec path, branch, issue number. It returns
   `VERDICT: APPROVE` or `CHANGES_REQUESTED` with blocking (`B#`) and
   non-blocking (`N#`) findings.
2. `CHANGES_REQUESTED`: send the blocking findings (and any non-blocking ones
   that are plainly right) to the **same** implementer via `SendMessage`. Then
   send the **same** reviewer a re-review request listing the finding IDs.
3. Repeat until `APPROVE`. More than `MAX_REVIEW_ROUNDS` rounds -> **Failure**.

## Step 8 - PO gate (product owner)

Start a `product-owner` with: issue title, body and comments, spec path,
branch, the implementer's TDD log and manual-check steps, and the reviewer's
final verdict.

- `ACCEPT` -> Step 9.
- `REJECT` with `[SPEC]` reasons -> the spec is wrong, not the code. Push the
  branch (no PR), comment the PO's reasons on the issue as numbered questions,
  swap `in-progress` and `ready` for `needs-spec`, stop the run.
- `REJECT` otherwise -> send the reasons to the **same** implementer, then
  run Step 7 again (re-review the new commits), then return to this step with
  the **same** PO via `SendMessage`. More than `MAX_PO_ROUNDS` rejections ->
  **Failure**.

## Step 9 - Ship

Only after the PO's `ACCEPT`. Run the checks from `CLAUDE.md` yourself one last
time, then push (keep the TDD commit history - don't squash):

```bash
git push -u origin loop/issue-<number>-<short-slug>
```

Open a PR against `main`:

- Title: `<issue title> (#<number>)`
- Body: follow `.github/pull_request_template.md`, filled from the agents'
  reports: `Closes #<number>`, spec path, the TDD log, the reviewer's final
  verdict and non-blocking notes it left open, the PO's acceptance table and
  notes for the human reviewer, the checks you ran, follow-ups.
- Label: `autoloop`.

Remove `in-progress` from the issue (the open PR now tracks it). Stop the run.

## Failure

Push whatever partial work is useful to the branch (no PR).
Comment on the issue: which stage failed (implementer stuck / review rounds
exhausted / PO rounds exhausted), the open findings or exact error, and what
you think is needed. Swap `in-progress` for `blocked`. Stop the run.

## Report

End every run with a 1-3 line summary: what was done (issue/PR link) or why
nothing was done (waiting on review / backlog empty / needs-spec / blocked).
