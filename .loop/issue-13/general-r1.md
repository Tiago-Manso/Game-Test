Status: done

# General review r1 - issue #13 CI workflow (PR #22)

VERDICT: BLOCKING ISSUES

## Solved findings check
No finding in `state.md` has status `fixed` (all Minors `logged`; T1-I1 deferred), so nothing can regress.
Deferral check:
- [T1-I1] deferred: reason sound - the spec fixes the ci.yml steps and the CLAUDE.md line; wiring tools/tests into CI is a follow-up. Settled, not re-raised.

## Critical
None.

## Important
- [G1-I1] .claude/skills/implement-next/SKILL.md:322 - the green-`checks` wait sits in Step 10 item 1, but item 3 then commits and pushes `state.md` (Status: done, PR body), creating a new PR head, and item 4 squash-merges straight away and posts "checks green". So the head that gets merged never has its `checks` run waited for. Every log push starts a new run (the PR already has 7 runs, one per orchestrator push). Today that is low risk because the commit only touches `.loop/`. But the spec says `checks` is named so it "can later be made a required status check" (Out of scope: the user does that), and once it is required, `merge_pull_request` in item 4 fails because the new head's required check is still pending, and Step 10 has no rule for that. This is a design the next step (required checks) would have to undo, and it doesn't meet the spec's "before merging, the `checks` CI run on the PR head must have succeeded" for the head that is merged. Suggested fix: move the wait into item 4, after item 3's push and right before `merge_pull_request`, e.g. "Wait for the `checks` run on the current PR head (after item 3's push) to succeed; red -> implementer as in item 1." Keep item 1's local checks as they are. Don't use `paths-ignore: .loop/**` instead: a workflow skipped by path filters leaves a required check pending forever. test_loop_docs still passes because it reads the whole Step 10 section. It could be lower (Minor) because nothing breaks until the user enables required checks; it's rated Important because the spec names that as the next step.

## Minor
- [G1-m1] .claude/skills/implement-next/SKILL.md:322 - "wait for it" doesn't say how. In these sessions `gh pr checks` (GraphQL) returns HTTP 403. The working call is REST: `gh api repos/{owner}/{repo}/commits/<head-sha>/check-runs -q '.check_runs[] | select(.name=="checks")'` (verified: returns `checks completed success` for 2414dbe). Name it in Step 10 so the orchestrator doesn't read a 403 as an environment stop or skip the check. This complements S2-m1 (how long to wait), it doesn't duplicate it.

## Cross-cutting notes (no finding)
- PR #16 edits SKILL.md hunks at ~10, ~188, ~202 and CLAUDE.md ~79; no overlap with Step 10 or the Commands list. Merges textually; origin/main hasn't moved (merge-tree clean).
- check.sh mirrors the CLAUDE.md commands exactly, and the cache path matches install-godot.sh's default dest and its version check, so a cache hit skips the download. Consistent with architecture section 11 and game-design.md row #13.

## What I ran
Ran in a private worktree at 2414dbe, PATH with ~/.local/bin:
- `bash tools/check.sh`: exit 0; import, lint, format, GUT (33/33 passing), "all checks passed".
- `python3 -m unittest discover -s tools/tests -v`: 10/10 OK (includes the lint-fail and GUT-fail cases).
- `gh api .../commits/2414dbe/check-runs`: `checks` completed/success on the head; 7 runs on the branch, all green.
- `git merge-tree --write-tree origin/main loop/issue-13-ci-workflow`: clean.
- `gh pr diff 16`: hunk overlap check (none).
