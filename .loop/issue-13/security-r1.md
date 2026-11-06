Status: done

# Security review - issue #13 CI workflow, round 1

VERDICT: NO BLOCKING ISSUES

## Critical
None.

## Important
None.

## Minor
- [S1-m1] .github/workflows/ci.yml:18 - Third-party actions are pinned by mutable major tag (`actions/checkout@v4`, `actions/setup-python@v5`, `actions/cache@v4`, lines 18, 20, 28). They are first-party GitHub actions, the token is `contents: read` and no secrets are used, so the risk is low. Pinning to commit SHAs (with a version comment, updated by Dependabot) is the hardening step if the repo later gets release or deploy secrets.
- [S1-m2] general (tools/install-godot.sh:19, now run by ci.yml:34) - CI downloads the Godot zip and runs it without checking its SHA-512 against the official `SHA512-SUMS.txt`, and then caches the binary (ci.yml:27-31), so a bad download would be reused for every run with that `.godot-version`. `pip install "gdtoolkit==4.*"` is not pinned either, so lint and format results can change without a commit. Both lines predate this PR, but this PR is what runs them on every PR. Suggested: check the checksum and pin an exact gdtoolkit version, as tech debt.
- [S1-m3] .github/workflows/ci.yml:16 - The job has no `timeout-minutes`, so a hung `godot --import` or a GUT test that never returns keeps the runner busy until GitHub's 6-hour default. Adding `timeout-minutes: 20` would fix it. A `concurrency` group with `cancel-in-progress` for PR refs would also stop stale runs from piling up.

## Checked, no issue
- Trigger is `pull_request`, not `pull_request_target`: fork PRs run with a read-only token and no secrets. No `${{ github.event.* }}` interpolated into `run:` (no script injection).
- `permissions: contents: read` at the workflow level (least privilege).
- Cache scope: PR-written caches can't be read by `main` or by other PRs, so the PR flow can't poison the cache.
- No secrets, tokens or personal data in any changed file. No network use besides the existing HTTPS Godot download from github.com.
- tools/check.sh: fixed argument lists, no eval, no data-driven paths, writes nothing outside the repo (the Godot import writes `.godot/`, which is expected). tools/tests write only to a `mkdtemp` copy and delete it in tearDown; YAML is read with `yaml.safe_load`.
- No game runtime code changed: no save, settings or `user://` surface in this PR.

## What I ran
- `git diff origin/main...loop/issue-13-ci-workflow` (whole change, 11 files) and `git log` (13 commits).
- `python3 -m unittest discover -s tools/tests -p 'test_ci_workflow.py'`: 5/5 OK.
- `bash -n tools/check.sh`: syntax OK.
- grep for `secrets.`, `GITHUB_TOKEN`, `curl`, `http`, `timeout`, `concurrency` in .github and tools: only the existing HTTPS download in install-godot.sh; no timeout or concurrency set.
- actionlint: not installed, not run.
