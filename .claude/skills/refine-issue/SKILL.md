---
name: refine-issue
description: Refine a feature idea or an existing GitHub issue together with the user until it is loop-ready - interview them, write the spec in specs/, create or update the issue, and label it `ready`. Use when the user wants to plan, write, groom or refine an issue/task/story, answer a `needs-spec` issue, or says "/refine-issue <idea or #number>".
---

# refine-issue: turn an idea into a loop-ready issue

This is a **conversation with the user**, not an autonomous task. The output is
an issue plus a spec that the `implement-next` loop can build without guessing.
Read `CLAUDE.md`, `specs/README.md` and `specs/_template.md` first.

Use the GitHub MCP tools (`mcp__github__*`) for GitHub; fall back to `gh`.

## Step 1 - Find the starting point

The argument can be:

- **An idea in words** -> a new issue.
- **An issue number** -> refine that issue. Read its body, comments and any spec it links.
- **Nothing** -> list open issues labelled `needs-spec`, then open issues with no
  `ready` / `in-progress` / `blocked` label, and ask which one to refine (or a new idea).

For a `needs-spec` issue, the loop's questions in the comments are your agenda.

## Step 2 - Do your homework before asking

Read the relevant code, the existing specs (including shared ones like
`specs/architecture.md`), and related issues. Don't ask the user anything the
repository already answers; state what you found instead ("Movement already
uses `Input.ts`; I'll extend that").

## Step 3 - Interview

Ask in short rounds with `AskUserQuestion` (up to 4 questions per round). For
every question, offer concrete options with your recommended one first. Cover,
as far as the task needs:

1. **Goal**: what the player/user should experience, and why.
2. **Behaviour**: inputs, outputs, states, timings, numbers.
3. **Edge cases**: what happens at limits, on failure, on repeat.
4. **Acceptance criteria**: how we will *check* each behaviour (test, command, observable result).
5. **Out of scope**: what must not be built now.
6. **Dependencies**: other issues that must land first.

Stop interviewing once every acceptance criterion is concrete and checkable.
Usually 1-3 rounds. Don't pad; small tasks need few questions.

**Size check.** One issue = one PR a reviewer can read in one sitting. If it's
bigger, propose a split into several issues (ordered, each with its own
criteria) and refine them one after another. Note dependencies as
`Depends on #<n>` in the spec and issue body; don't mark a dependent issue
`ready` until its dependency is merged.

## Step 4 - Draft and confirm

Show the user, in the chat:

- the issue title and short body (from `.github/ISSUE_TEMPLATE/task.md`),
- the full spec (from `specs/_template.md`, `Status: ready`).

Ask for approval. Apply changes and show again until they say it's good.
**Nothing is written to GitHub or `main` before this approval.**

## Step 5 - Write it

1. **Issue.** Create it (or update the existing one) to get its number. The
   body links `specs/<number>-<slug>.md`.
2. **Spec.** Commit only the spec file (plus any shared spec you updated)
   straight to `main` - the user's approval in Step 4 is its review:

   ```bash
   git fetch origin main
   git checkout main && git pull --ff-only origin main
   # write specs/<number>-<slug>.md
   git add specs/
   git commit -m "Spec #<number>: <title>"
   git push origin main
   ```

   Commit nothing but files under `specs/` this way. If the push is rejected,
   pull and retry; never force-push `main`.
3. **Labels.** Remove `needs-spec` if present. Add `ready` unless it depends on
   an unmerged issue (say so to the user). Add `priority:high` if the user asked.
4. For a `needs-spec` issue, comment that the questions are answered in the spec.

## Step 6 - Wrap up

Report the issue link, the spec path, and its state (`ready`, or waiting on
`#<dep>`). Offer to refine the next one.
