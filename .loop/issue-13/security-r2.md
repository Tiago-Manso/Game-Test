Status: done

# Security review - issue #13 CI workflow, round 2

VERDICT: NO BLOCKING ISSUES

## Earlier findings
- S1-m1 (minor) .github/workflows/ci.yml:18 - actions pinned by major tag: not fixed, logged as tech debt (fine).
- S1-m2 (minor) tools/install-godot.sh:19 - no SHA-512 check on Godot zip, gdtoolkit==4.* unpinned: not fixed, logged (fine).
- S1-m3 (minor) .github/workflows/ci.yml:16 - no timeout-minutes / concurrency: not fixed, logged (fine).
- T1-I1 (tests, deferred): no security impact; not judged here.

## Critical
None.

## Important
None.

## Minor
- [S2-m1] .claude/skills/implement-next/SKILL.md:323 - "if it is still running, wait for it" has no bound and no case for a run that never appears (workflows disabled, Actions outage, run queued forever, or no run for the new head after step 1's merge of origin/main). The loop then hangs at merge instead of failing or retrying. Together with S1-m3 (no job timeout) a hung Godot step stalls the loop for up to 6 h. Suggested: wait at most N minutes (e.g. 30), and treat "no run for the head SHA" or a timeout as a red run, going back to the implementer or stopping with an environment report. Minor because it costs availability only, with no data or secret exposure. It could count as Important if the loop runs unattended on a schedule.

## Checked, no issue
- No non-log change since round 1: `git diff 4979d9f~1 HEAD -- . ':!.loop'` is empty.
- Trigger is `pull_request`, not `pull_request_target`. Workflow `permissions: contents: read`. No secrets, no `github.event.*` in `run:`, no eval.
- Cache writes from PR runs are scoped to the PR ref and can't poison main.
- check.sh: fixed argv, `cd` to repo root, no data-driven paths, writes only `.godot/`.
- No game runtime, save or `user://` surface changed.

## What I ran
- Worktree at origin/loop/issue-13-ci-workflow: `bash -n tools/check.sh` OK; `python3 -I -m unittest discover -s tools/tests`: 10 tests OK.
- grep for `github.event`, `secrets.`, `pull_request_target`, `GITHUB_TOKEN`, `eval` in .github and tools: no matches.
- Read SKILL.md Step 10 merge text.
