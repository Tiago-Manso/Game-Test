---
name: implement-next
description: Run one iteration of the autonomous implementation loop - resume an unfinished loop PR, otherwise pick the next `ready` GitHub issue, implement it with TDD (implementer agent), review it in the pull request (3 code-reviewer passes, then a product-owner gate) and merge it. Use when asked to "implement the next issue", "run the loop", or via `/loop /implement-next` or a scheduled task.
---

# implement-next: one iteration of the autonomous loop

Each run takes **one issue from `ready` to merged** (or to a clean stop) and
then ends. Repetition comes from outside: `/loop /implement-next` in a session,
or a scheduled task whose prompt is `/implement-next`. Never start a second
issue in the same run.

The loop runs **without a human**. The only thing that ever waits for the user
is spec refinement: an issue labelled `needs-spec`, which they answer with
`/refine-issue #<n>`. Everything else - review, acceptance, merge, retries -
happens inside the loop, and every review is posted **in the pull request** so
the user can read the whole discussion afterwards.

Work items are GitHub issues in this repository. Details live in `specs/`.
Read `CLAUDE.md` first for build/test commands and conventions.

## Roles

You, running this skill, are the **orchestrator**: you handle git, GitHub,
labels, posting to the PR, and the hand-offs. You do **not** write production
code or tests yourself. Three subagents (defined in `.claude/agents/`) do the
work, started with the Agent tool:

| Agent           | `subagent_type`  | Job                                                    |
|-----------------|------------------|--------------------------------------------------------|
| Implementer     | `implementer`    | Writes tests and code with strict TDD; fixes findings. |
| Code reviewer   | `code-reviewer`  | Independent review of code, tests and TDD. Read-only.  |
| Product owner   | `product-owner`  | Accepts or rejects against the spec. Gate before merge. Read-only. |

Run them in the foreground (`run_in_background: false`), one at a time - they
share the working tree. Keep the implementer's ID and send it every round of
fixes with `SendMessage` so it keeps its context. Pass each agent everything
it needs in its prompt (issue number, title, body and comments, spec path,
branch, PR number); it has no other context. Never pass the reviewer or PO
your own opinion of the code - give them the branch and let them judge. If
`SendMessage` is unavailable, start a fresh agent of the same type and include
its previous report plus the new findings in the prompt.

The agents don't talk to GitHub. **You post what they return**, keeping their
substance, under a heading naming the agent (see "Posting to the PR").

Use the GitHub MCP tools (`mcp__github__*`) for all GitHub operations. If they
are unavailable, fall back to `gh`. If neither works, it is an
**environment problem** (see Failure).

## Labels

| Label           | Meaning                                                        |
|-----------------|----------------------------------------------------------------|
| `ready`         | Issue is fully specified; the loop may pick it up.             |
| `in-progress`   | Claimed by a loop run. Other runs skip it.                     |
| `retry`         | The first attempt failed; the next run tries once more from scratch. |
| `needs-spec`    | Waiting for the user to refine the spec. The only human step.  |
| `autoloop`      | Set on every PR the loop opens.                                |
| `priority:high` | Picked before other `ready` issues.                            |

Adding a label that does not exist yet creates it; don't stop over a missing label.

## Limits

- One issue in flight at a time: at most one open `autoloop` PR.
- `REVIEW_PASSES = 3`: every PR gets exactly three code-review passes, each
  followed by implementer fixes, before the PO sees it.
- `MAX_PO_ROUNDS = 2` PO rejections per attempt; a third is a failed attempt.
- `MAX_ATTEMPTS = 2` per issue; the second failed attempt sends the issue to `needs-spec`.
- Never push to `main` directly. Code reaches `main` only by merging a loop PR
  after the PO's `ACCEPT` with all checks green.
- Merge with a **merge commit** (not squash or rebase) so the red/green/refactor history stays on `main`.
- Never skip, disable or delete a test to get green. Never force-push.

## Posting to the PR

All comments are posted from the same GitHub account, so each one starts with
a bold heading saying who is speaking, and ends with the footer your
environment requires (if any). GitHub doesn't let an account approve or
request changes on its own PR, so every review is submitted with event
`COMMENT`; the verdict is written in the heading.

- **Code review** - one PR review per pass:
  - create a pending review (`pull_request_review_write`, method `create`);
  - add each finding that has a `file:line` in the diff as an inline comment
    (`add_comment_to_pending_review`), text `**[P<k>-B<n>] blocking** - ...` or
    `**[P<k>-N<n>] non-blocking** - ...`;
  - submit (`submit_pending`, event `COMMENT`) with the body
    `**Code review - pass <k>/3 (code-reviewer agent): APPROVE | CHANGES REQUESTED**`,
    then the checks it ran, the TDD spot-check, the earlier findings it
    verified, and any finding without a diff line.
- **Implementer fixes** - reply on each finding's thread
  (`add_reply_to_pull_request_comment`), heading `**Implementer:**`, saying
  `Fixed in <sha>: <what changed>` or `Not changed: <reason>`. Resolve the
  thread (`resolve_review_thread`) when fixed. Findings that were in the review
  body get one PR comment listing them the same way.
- **Pass-3 verification** - a PR comment
  `**Code review - pass 3 verification (code-reviewer agent): RESOLVED | OPEN**`
  listing each finding.
- **PO gate** - a PR review (event `COMMENT`) with body
  `**Product owner (product-owner agent): ACCEPT | REJECT**`, the acceptance
  table, rejection reasons (inline where they point at code), and manual checks.
- **Stage marker** - end each loop comment with a hidden marker
  `<!-- loop:stage=<stage> -->`, where stage is one of `implemented`,
  `review-1`, `fixes-1`, `review-2`, `fixes-2`, `review-3`, `fixes-3`,
  `verified`, `po-1`, `po-fixes-1`, `po-2`, ..., `accepted`. Step 2 uses these
  to resume an interrupted run.

## Step 1 - Sync

```bash
git fetch origin
git checkout main && git pull --ff-only origin main
```

If `main` doesn't exist, use the repository's default branch.

## Step 2 - Resume an unfinished PR

If an open PR labelled `autoloop` exists (a run was interrupted, or the user
commented on it), take it:

1. Check out its branch and merge `origin/main` into it if it is behind.
2. Find the last `loop:stage` marker in its comments and reviews and continue
   from the step after it (no marker -> start at Step 7, pass 1). Start a fresh
   implementer, giving it the PR's findings and replies so far.
3. Comments from the user that have no loop reply yet are **blocking findings**
   for the next fixes round: the implementer handles them like reviewer
   findings and you reply on their threads.

Then continue with the normal steps from there; skip Steps 3-6.

## Step 3 - Pick an issue

List open issues labelled `ready` and **not** labelled `in-progress` or
`needs-spec`. Order: `priority:high` first, then lowest issue number.

**Dependencies.** An issue body may contain lines `Depends on #<n>` (one per
line, or `Depends on #<a> and #<b>`). Skip the issue while any issue it
depends on is still open - it unlocks once those PRs are merged and their
issues closed. Don't comment on or relabel skipped issues.

Take the first issue that isn't skipped. If none is left, report
"backlog empty" (no `ready` issues) or "waiting on dependencies" (every
`ready` issue waits on an open one - list which) and stop.

## Step 4 - Claim

Add `in-progress` and comment `Picked up by the implementation loop
(attempt <a>/2).` For an issue labelled `retry`, `a` is 2: read the failure
comment from attempt 1 and pass it to the implementer.

## Step 5 - Understand the task

1. Read the issue body and all comments.
2. Open the spec it links (`specs/<number>-<slug>.md`). If the issue has no
   spec but is small and unambiguous, create one from `specs/_template.md`
   as part of your change.
3. Read any other specs it references and the code it touches.

**Ambiguity gate.** If you cannot state the acceptance criteria as concrete,
checkable items, or the spec contradicts the code or another spec, do not
guess. Comment on the issue with numbered, specific questions; swap
`in-progress`, `ready` and `retry` for `needs-spec`; stop the run. The user
answers them with `/refine-issue #<number>`.

## Step 6 - Implement (TDD) and open the PR

```bash
git checkout -b loop/issue-<number>-<short-slug> origin/main
```

(On attempt 2 add `-2` to the branch name; the attempt-1 branch stays as it was.)

Start an `implementer` with: issue number, title, body and comments, spec
path, branch name (and the attempt-1 failure, if any). It works criterion by
criterion: failing test (`[red]` commit), minimum code to pass (`[green]`
commit), refactor (`[refactor]` commit). It returns a TDD log, manual-check
steps, check results and follow-ups. If it reports `STATUS: STUCK`, go to
**Failure**.

Push and open a **draft** PR against `main`:

- Title: `<issue title> (#<number>)`
- Body: follow `.github/pull_request_template.md`: `Closes #<number>`, spec
  path, the TDD log, checks run, manual checks, follow-ups.
- Label: `autoloop`.

Post a PR comment `**Implementer:** ready for review.` with the
`implemented` marker.

## Step 7 - Review passes in the PR (3 x code reviewer -> implementer fixes)

Run exactly `REVIEW_PASSES = 3` passes, even if an earlier pass approves - each
pass is a fresh pair of eyes. For pass `k` = 1, 2, 3:

1. **Review.** Start a **new** `code-reviewer` with: spec path, branch, issue
   number, PR number, pass number, and - from pass 2 on - the previous passes'
   findings with the implementer's replies, so it verifies those fixes as well
   as reviewing the whole branch again. Post its result as the pass-`k` review
   (marker `review-<k>`).
2. **Fix.** Send the **same** implementer every blocking finding and the
   non-blocking ones that are plainly right, with their `P<k>-` IDs. It fixes
   them (TDD for behaviour changes) and reports per finding. Push, then post
   the replies and resolve fixed threads (marker `fixes-<k>`). If the pass had
   no findings to act on, post `**Implementer:** nothing to fix in pass <k>.`

After pass 3:

- If pass 3 had blocking findings, send the pass-3 reviewer (`SendMessage`)
  the implementer's fixes to verify and post its answer as the pass-3
  verification (marker `verified`). Anything still open -> **Failure**.
- If pass 3 approved, post the verification as `RESOLVED` with nothing open.

## Step 8 - PO gate in the PR

Start a `product-owner` with: issue title, body and comments, spec path,
branch, PR number, the TDD log and manual-check steps, and the three review
verdicts. Post its result as the PO review (marker `po-<round>`).

- `ACCEPT` -> Step 9.
- `REJECT` with `[SPEC]` reasons -> the spec is wrong, not the code. Close the
  PR with a comment pointing to the issue, comment the PO's reasons on the
  issue as numbered questions, swap `in-progress`, `ready` and `retry` for
  `needs-spec`, stop the run. (After refinement the issue is picked up fresh.)
- `REJECT` otherwise -> send the reasons to the **same** implementer; post its
  replies (marker `po-fixes-<round>`); run **one** more review pass on the new
  commits (fresh `code-reviewer`, posted as `pass 3+<round>`, pass-3 rules:
  open findings after its fixes -> **Failure**); then ask the **same** PO again
  via `SendMessage`. A third rejection -> **Failure**.

## Step 9 - Merge

Only after the PO's `ACCEPT`:

1. Merge `origin/main` into the branch if it moved; run every check from
   `CLAUDE.md` yourself. Anything red -> back to the implementer for a fix and
   one more review pass, as in a PO rejection.
2. Update the PR body with the final TDD log and a table of the review passes
   (verdict, blocking/non-blocking counts, fixing commits).
3. Mark the PR ready for review (no longer draft), post
   `**Orchestrator:** merging - PO accepted, checks green.` (marker `accepted`),
   and merge it with a merge commit (`merge_pull_request`, method `merge`).
   `Closes #<number>` closes the issue; issues that depend on it unlock.
4. Delete the branch. Stop the run.

## Failure

A failed **attempt** (implementer stuck, findings still open after pass-3
verification, third PO rejection):

1. Push the branch as it is. On the PR, post
   `**Orchestrator:** attempt <a>/2 failed at <stage>` with the open findings
   or exact error, then close the PR (don't merge, don't delete the branch).
2. Attempt 1: comment the same on the issue, swap `in-progress` for `retry`
   (keep `ready`). The next run starts over from `main` with a new
   implementer.
3. Attempt 2: comment on the issue with what failed both times, as numbered
   questions about what the spec should say instead; swap `in-progress`,
   `ready` and `retry` for `needs-spec`.

Stop the run.

An **environment problem** (Godot or gdtoolkit can't be installed, GitHub
tools unavailable, push refused) is not the issue's fault and doesn't count as
an attempt: remove `in-progress`, leave any PR open as it is (Step 2 resumes
it later), and stop with a report naming the problem. Never merge or open a
PR on code whose checks couldn't run.

## Report

End every run with a 1-3 line summary: the issue and PR links and the outcome
(merged / attempt failed / needs-spec), or why nothing was done (backlog empty
/ waiting on dependencies / environment problem).
