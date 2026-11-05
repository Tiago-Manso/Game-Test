---
name: implement-next
description: Run one iteration of the autonomous implementation loop - resume an interrupted issue from its state logs, otherwise pick the next `ready` GitHub issue (or the one given as `#<n>`), implement it with TDD, review it in the pull request (quality, security, tests and performance reviewers until no Critical or Important issues remain, then an Opus general review and an Opus product-owner go/no-go) and merge it. Use when asked to "implement the next issue", "implement issue #n", "run the loop", or via `/loop /implement-next` or a scheduled task.
---

# implement-next: one iteration of the autonomous loop

Each run takes **one issue from `ready` to merged** (or to a clean stop) and
then ends. Repetition comes from outside: `/loop /implement-next` in a session,
or a scheduled task whose prompt is `/implement-next`. Never start a second
issue in the same run, and never run two loops at once.

## Arguments

- `/implement-next` - take the next issue the normal way (Step 3 picks it).
- `/implement-next #<n>` (or just `<n>`) - **work only on issue `<n>`**. Use it
  to run a single issue on demand. Run it without `/loop`: once the issue is
  merged there is nothing left for it to do. The differences are in Steps 2
  and 3, marked "Targeted run"; everything else is the same.

The loop runs **without a human**. The only thing that ever waits for the user
is spec refinement: an issue labelled `needs-spec`, which they answer with
`/refine-issue #<n>`. Everything else - review, go/no-go, merge, retries -
happens inside the loop, and every review is posted **in the pull request** so
the user can read the whole discussion afterwards.

Work items are GitHub issues in this repository. Details live in `specs/`.
Read `CLAUDE.md` first for build/test commands and conventions, then
`.claude/loop/state-log.md` (log files) and `.claude/loop/reviewer-guide.md`
(how reviews work).

## Roles

You, running this skill, are the **orchestrator**: you handle git, GitHub,
labels, the state log, posting to the PR, and the hand-offs. You do **not**
write production code or tests yourself. Agents from `.claude/agents/` do the
work, started with the Agent tool:

| Agent                 | `subagent_type`        | Model   | Job |
|-----------------------|------------------------|---------|-----|
| Implementer           | `implementer`          | default | Writes tests and code with strict TDD; fixes Critical and Important findings. |
| Quality reviewer      | `quality-reviewer`     | default | Correctness, design, readability, conventions, scope, lint. |
| Security reviewer     | `security-reviewer`    | default | Untrusted input, save files, paths, code execution, secrets, dependencies. |
| Test reviewer         | `test-reviewer`        | default | Tests prove the spec, make sense, aren't flaky; TDD really happened. |
| Performance reviewer  | `performance-reviewer` | default | Per-frame cost, allocations, leaks, rendering, IO on mobile. |
| General reviewer      | `general-reviewer`     | **opus** | Holistic review after the specialists converge. |
| Product owner         | `product-owner`        | **opus** | GO / NO-GO against the spec. Final gate before merge. |

Always pass `model: "opus"` when starting the general reviewer and the
product owner (their definitions also pin it).

- The implementer runs alone in the foreground - it changes the working tree.
  Keep its ID and send each round of fixes with `SendMessage` so it keeps its
  context.
- The four specialist reviewers of a round run **in parallel**: start them in
  one message (several Agent calls, `run_in_background: false`). They are
  read-only and run Godot only in their own worktrees.
- Every review agent is **fresh** each round, so it isn't anchored on its
  earlier opinion; it gets the earlier rounds' findings and replies instead.
- Pass each agent everything it needs in its prompt: issue number, title,
  body and comments, spec path, branch, PR number, round, its log path, and
  (from round 2) earlier findings with the implementer's replies. Never pass
  your own opinion of the code.
- If `SendMessage` is unavailable, start a fresh implementer and tell it to
  resume from its log plus the new findings.

The agents don't talk to GitHub. **You post what they return**, keeping their
substance, under a heading naming the agent (see "Posting to the PR").

Use the GitHub MCP tools (`mcp__github__*`) for all GitHub operations. If they
are unavailable, fall back to `gh`. If neither works, it is an
**environment problem** (see Failure).

## State logs

Every agent keeps a log under `.loop/issue-<n>/` on the issue's branch (format
in `.claude/loop/state-log.md`). You keep `state.md`:

- Before starting an agent: add its row to "Agent runs" as `started`, commit
  `state.md`, push.
- After it returns: mark the row `done`, record its findings (with their
  severity) in "Findings", update the stage, commit `state.md` **and the agent's
  log** (review agents don't commit their own), push.
- Push after every change, so a new session can always pick up from the
  branch alone.

## Labels

| Label            | Meaning                                                        |
|------------------|----------------------------------------------------------------|
| `ready`          | Issue is fully specified; the loop may pick it up.             |
| `in-progress`    | Claimed by a loop run. Only a resume (Step 2) touches it.      |
| `retry`          | The first attempt failed; the next run tries once more from scratch. |
| `needs-spec`     | Waiting for the user to refine the spec. The only human step.  |
| `autoloop`       | Set on every PR the loop opens.                                |
| `tech-debt`      | Tech-debt issue grouping a merged PR's Minor (and deferred Important) findings. Never `ready` by itself: analysed later with `/refine-issue tech-debt` and fixed only if required. |
| `priority:high`  | Picked before other `ready` issues.                            |

Adding a label that does not exist yet creates it; don't stop over a missing label.

## Severity

Reviewers classify every finding as **Critical**, **Important** or **Minor**
(definitions in `.claude/loop/reviewer-guide.md`):

| Severity  | Before merge |
|-----------|--------------|
| Critical  | Must be fixed. Can't be deferred. |
| Important | Must be fixed, unless the implementer defers it with a stated reason that the reviewers accept. |
| Minor     | Not fixed in this PR; logged and grouped as tech debt. |

**Blocking** findings are every Critical and every Important that isn't
deferred. All Minors - and any deferred Importants - are grouped into one
`tech-debt` issue at merge, to be analysed and fixed later if required.

## Limits

- One issue in flight at a time.
- Specialist reviewers: each runs **at least `MIN_REVIEW_ROUNDS = 2`** rounds
  and keeps running until its latest round has **no blocking findings**. A
  specialist still reporting blocking findings in round `MAX_REVIEW_ROUNDS = 4`
  fails the attempt.
- General review: repeats until a round has no blocking findings; one still open in
  round `MAX_GENERAL_ROUNDS = 3` fails the attempt.
- Product owner: `MAX_NO_GO = 2`; a third NO-GO fails the attempt.
- `MAX_ATTEMPTS = 2` per issue; the second failed attempt sends the issue to `needs-spec`.
- Minor findings are never fixed in the PR that found them, and deferred
  Importants aren't either: both are logged in `state.md`, posted on the PR,
  and grouped into a `tech-debt` issue at merge.
- Never push to `main` directly. Code reaches `main` only by merging a loop PR
  after the PO's **GO** with all checks green.
- **Squash-merge.** TDD is how the code is written and is verified during
  review (the test reviewer checks the red/green commits on the PR); `main`
  gets one commit per issue. The PR keeps the full commit history, and the
  `.loop/` logs land on `main` with the squash.
- Never skip, disable or delete a test to get green. Never force-push.

## Posting to the PR

All comments are posted from the same GitHub account, so each one starts with
a bold heading saying who is speaking, and ends with the footer your
environment requires (if any). GitHub doesn't let an account approve or
request changes on its own PR, so every review is submitted with event
`COMMENT`; the verdict is in the heading.

- **Each review agent's round** is one PR review:
  - create a pending review (`pull_request_review_write`, method `create`);
  - add each finding that has a `file:line` in the diff as an inline comment
    (`add_comment_to_pending_review`): `**[S2-C1] Critical** - ...`,
    `**[S2-I2] Important** - ...` or `**[S2-m3] Minor (logged for later)** - ...`;
  - submit (`submit_pending`, event `COMMENT`) with the body
    `**<Security> review - round <k> (<security-reviewer> agent): <c> Critical, <i> Important, <m> Minor**`
    (or `no blocking issues`), what it ran, the earlier findings it verified, and
    findings without a diff line.
- **Implementer fixes** - reply on each Critical and Important finding's
  thread (`add_reply_to_pull_request_comment`) with `**Implementer:** Fixed in
  <sha>: <what changed>`, `**Implementer:** Not changed: <reason>` or
  `**Implementer:** Deferred: <reason>`, and resolve the thread
  (`resolve_review_thread`) when fixed or deferred. Findings from a review body get
  one PR comment listing them the same way.
- **Product owner** - a PR review with body
  `**Product owner (product-owner agent, Opus): GO | NO-GO**`, the acceptance
  table, NO-GO reasons (inline where they point at code), and manual checks.

## Step 1 - Sync

```bash
git fetch origin
git checkout main && git pull --ff-only origin main
```

If `main` doesn't exist, use the repository's default branch.

## Step 2 - Resume an interrupted issue

Look for unfinished work, in this order:

1. an open PR labelled `autoloop`;
2. an open issue labelled `in-progress` (a run died, possibly before the PR
   was opened) - find its branch `loop/issue-<n>-*` on the remote.

If there is one, check out its branch, merge `origin/main` into it if it is
behind, and read `.loop/issue-<n>/state.md`:

- Continue from the stage it records. An agent run marked `started` but not
  `done` was interrupted: start a fresh agent of the same type (same round,
  same log path) and tell it to resume from its log.
- If there is no `state.md` but a branch exists, treat it as Step 6 with an
  implementer told to resume from `git log` and `implementer.md`.
- If no branch exists, remove `in-progress` and go on to Step 3.
- Comments from the user on the PR that have no loop reply yet are findings
  for the next fixes round: classify each with the reviewer guide (Important
  unless it is clearly Critical or Minor), record it in `state.md` (ID
  `U-C<n>` / `U-I<n>` / `U-m<n>`), have the implementer handle it, and reply
  on its thread.

Then carry on with the normal steps from there; skip Steps 3-5.

**Targeted run (`#<n>`).** If the unfinished work is issue `<n>`, resume it as
above. If it is a **different** issue, don't touch it and don't start `<n>`:
stop and report "issue #<m> is still in progress - finish or resume it first",
since only one issue may be in flight.

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

**Targeted run (`#<n>`).** Don't search; check issue `<n>` instead and stop
with the reason if any of these is true:

- it is closed - "already done";
- it is labelled `needs-spec` - "waiting for refinement: run `/refine-issue #<n>`";
- it isn't labelled `ready` - "not ready: refine it first";
- an issue it depends on is still open - "waiting on #<a>, #<b>".

`priority:high` and the order of other issues don't matter. An issue labelled
`retry` runs as attempt 2, as usual. Otherwise continue with Step 4 for `<n>`.

## Step 4 - Claim

Create the branch and the state log, then claim:

```bash
git checkout -b loop/issue-<number>-<short-slug> origin/main
```

(On attempt 2 add `-2` to the branch name; the attempt-1 branch stays as it was.)

Write `.loop/issue-<n>/state.md` (stage `claimed`, attempt 1 or 2), commit
`loop(#<n>): claim, attempt <a>`, push. Add `in-progress` to the issue and
comment `Picked up by the implementation loop (attempt <a>/2). Branch:
<branch>.` For an issue labelled `retry`, `a` is 2: read the failure comment
from attempt 1 and pass it to the implementer.

## Step 5 - Understand the task

1. Read the issue body and all comments.
2. Open the spec it links (`specs/<number>-<slug>.md`). If the issue has no
   spec but is small and unambiguous, create one from `specs/_template.md`
   as part of your change.
3. Read any other specs it references and the code it touches.

**Ambiguity gate.** If you cannot state the acceptance criteria as concrete,
checkable items, or the spec contradicts the code or another spec, do not
guess. Comment on the issue with numbered, specific questions; swap
`in-progress`, `ready` and `retry` for `needs-spec`; record it in `state.md`;
stop the run. The user answers them with `/refine-issue #<number>`.

## Step 6 - Implement (TDD) and open the PR

Start an `implementer` with: issue number, title, body and comments, spec
path, branch name, its log path (and the attempt-1 failure, if any). It works
criterion by criterion - failing test (`[red]` commit), minimum code to pass
(`[green]` commit), refactor (`[refactor]` commit) - keeping
`implementer.md` and pushing after every commit. It returns a TDD log,
manual-check steps, check results and follow-ups. If it reports
`STATUS: STUCK`, go to **Failure**.

Run every check from `CLAUDE.md` yourself. Then open a **draft** PR against `main`:

- Title: `<issue title> (#<number>)`
- Body: follow `.github/pull_request_template.md`: `Closes #<number>`, spec
  path, the TDD log, checks run, manual checks, follow-ups.
- Label: `autoloop`.

Record the PR number and stage `implemented` in `state.md`, push, and post
`**Implementer:** ready for review.` on the PR.

## Step 7 - Specialist review rounds

Specialists: `quality-reviewer`, `security-reviewer`, `test-reviewer`,
`performance-reviewer`. A specialist is **done** once it has run at least
`MIN_REVIEW_ROUNDS` (2) rounds and its latest round found no blocking issues.

Repeat for round `k` = 1, 2, ... while any specialist isn't done:

1. **Review.** Mark a run `started` in `state.md` for every specialist not yet
   done, push, then start them **in parallel**, each fresh, with its log path
   `.loop/issue-<n>/<quality|security|tests|performance>-r<k>.md`.
2. **Record and post.** When all have returned, record their findings in
   `state.md` (Critical and Important as `open`, Minor as `logged` and in
   "Tech debt"),
   commit their logs, push, and post one PR review per specialist.
3. **Fix.** If the round has blocking findings, send them all to the
   implementer (same agent) in one message. It fixes them (TDD for behaviour
   changes), updates its log, pushes, and reports per finding. Mark them
   `fixed` / `not changed` in `state.md`, push, reply on the threads and
   resolve the fixed ones.
   Deferred Importants: mark them `deferred: <reason>`, add them to
   "Tech debt". The next round's reviewer judges the reason; one it rejects
   comes back `open` under the same ID.
4. A specialist with blocking findings in round `MAX_REVIEW_ROUNDS` (4) ->
   **Failure**.

Done specialists don't run again. The general review catches anything later
fixes break in their area.

## Step 8 - General review (Opus)

Repeat for round `g` = 1, 2, ...:

1. Start a fresh `general-reviewer` with `model: "opus"`, log
   `.loop/issue-<n>/general-r<g>.md`, the spec, the PR discussion so far and
   the path to `state.md`.
2. Record, commit, push and post its review as in Step 7. A finding it
   reports as `REGRESSED` keeps its original ID: set it back to
   `regressed (by <sha>)` in `state.md`, reopen its PR thread (`unresolve_review_thread`) with a
   reply naming the commit that undid it, and send it to the implementer together
   with the finding whose fix caused it.
3. No blocking findings -> Step 9. Otherwise the implementer fixes them as in
   Step 7 and the next round starts. A blocking finding still open in round
   `MAX_GENERAL_ROUNDS` (3) -> **Failure**.

## Step 9 - Product owner go / no-go (Opus)

Start a `product-owner` with `model: "opus"`, log `.loop/issue-<n>/po-r<r>.md`,
and: issue title, body and comments, spec path, branch, PR number, the TDD log
and manual-check steps. Record, commit, push and post its review.

- **GO** -> Step 10.
- **NO-GO** with `[SPEC]` reasons -> the spec is wrong, not the code. Close the
  PR with a comment pointing to the issue, comment the PO's reasons on the
  issue as numbered questions, swap `in-progress`, `ready` and `retry` for
  `needs-spec`, record it in `state.md`, push, stop the run.
- **NO-GO** otherwise -> the implementer fixes the reasons, then **one**
  general review round (Step 8 rules: blocking findings must reach zero), then a fresh
  `product-owner` round `r+1`. A third NO-GO -> **Failure**.

## Step 10 - Merge

Only after the PO's **GO**:

1. Merge `origin/main` into the branch if it moved; run every check from
   `CLAUDE.md` yourself. Anything red -> the implementer fixes it, then one
   general review round and the PO again, as for a NO-GO.
2. If "Tech debt" in `state.md` isn't empty, open one issue
   `Tech debt from #<n>: <issue title>` labelled `tech-debt` (never `ready`),
   linking the PR, with one checklist item per finding - ID, severity,
   reviewer, `file:line`, the finding and the suggested fix - grouped by area
   (e.g. save system, HUD, tests), deferred Importants first with their
   reasons. Record its number in `state.md`.
3. Set `state.md` to `Status: done`, stage `merged`; update the PR body with
   the final TDD log, a table of review rounds per agent (rounds, Critical /
   Important fixed, deferred, Minor logged) and the tech-debt issue link. Commit, push.
4. Mark the PR ready for review (no longer draft), post
   `**Orchestrator:** merging - PO GO, checks green.`, and squash-merge it
   (`merge_pull_request`, method `squash`, title `<issue title> (#<number>)`).
   `Closes #<number>` closes the issue; issues that depend on it unlock.
5. Delete the branch. Stop the run.

## Failure

A failed **attempt** (implementer stuck, a specialist or general review still
reporting blocking findings at its round limit, third NO-GO):

1. Record the failure in `state.md` (`Status: failed`, stage, open blocking findings),
   commit, push. On the PR, post `**Orchestrator:** attempt <a>/2 failed at
   <stage>` with the open blocking findings or exact error, then close the PR (don't
   merge, don't delete the branch).
2. Attempt 1: comment the same on the issue, swap `in-progress` for `retry`
   (keep `ready`). The next run starts over from `main` with a new branch and
   a new implementer.
3. Attempt 2: comment on the issue with what failed both times, as numbered
   questions about what the spec should say instead; swap `in-progress`,
   `ready` and `retry` for `needs-spec`.

Stop the run.

An **environment problem** (Godot or gdtoolkit can't be installed, GitHub
tools unavailable, push refused) is not the issue's fault and doesn't count as
an attempt. Record it in `state.md` if you can, leave the issue
`in-progress` and any PR open (Step 2 resumes them once the environment
works), and stop with a report naming the problem. Never merge or open a PR
on code whose checks couldn't run.

## Report

End every run with a 1-3 line summary: the issue and PR links and the outcome
(merged / attempt failed / needs-spec), or why nothing was done (backlog empty
/ waiting on dependencies / environment problem).
