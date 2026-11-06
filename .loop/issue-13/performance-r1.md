Status: done

# Performance review - issue #13 CI workflow, round 1

VERDICT: NO BLOCKING ISSUES

No game code changed (no .gd/.tscn), so nothing runs per frame, allocates at
runtime, renders or does IO on phones. Only CI/tooling cost was reviewed.

## Critical
None.

## Important
None.

## Minor
- [P1-m1] .github/workflows/ci.yml:13 - no `concurrency` group. The loop pushes a commit per TDD step and per log update, so each push to the PR branch starts a full run while the previous one keeps going; superseded runs waste runner minutes and queue time. Suggest `concurrency: { group: ci-${{ github.ref }}, cancel-in-progress: ${{ github.event_name == 'pull_request' }} }` (keeps every run on main).
- [P1-m2] .github/workflows/ci.yml:16 - no `timeout-minutes` on the job. A headless Godot import/GUT run that hangs (e.g. a test awaiting a signal that never fires) holds the runner for the 6 h default and the loop's merge step waits on it. Locally check.sh takes ~9 s; `timeout-minutes: 15` is ample.
- [P1-m3] .github/workflows/ci.yml:20 - gdtoolkit is pip-installed fresh on every run (only the Godot binary is cached). A few seconds per run; `setup-python`'s `cache: pip` needs a requirements/lock file to key on, so this only pays off if one is added. Optional.

## What I ran
- git diff origin/main...loop/issue-13-ci-workflow: CI/tooling/docs only, no game code.
- Read tools/install-godot.sh: cached ~/.local/bin/godot + PATH step means a cache hit skips the download (`godot --version` -> `4.5.1.stable.official.f62fdbde1`, matches `^4.5.1`); cache key hashes .godot-version - correct.
- tools/check.sh in a private worktree at branch head: exit 0, all four steps named, ~9 s wall.
