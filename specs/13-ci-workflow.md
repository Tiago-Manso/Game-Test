# CI workflow

- Issue: #13
- Status: done

## Context

Every PR should be checked by something independent of the agents that wrote
and reviewed it. One script runs all checks, and GitHub Actions runs that
script on every PR and on `main` (architecture section 11).

## Requirements

- `tools/check.sh`: runs, in order and stopping at the first failure, the
  commands from `CLAUDE.md`: import, `gdlint scenes scripts test`,
  `gdformat --check scenes scripts test`, the GUT test command. It prints which
  step failed and exits non-zero; exits 0 when all pass. It assumes Godot and
  gdtoolkit are installed (`tools/install-godot.sh`).
- `.github/workflows/ci.yml`:
  - runs on `pull_request` and on `push` to `main`;
  - one job on `ubuntu-latest`: checkout, install Python, run
    `tools/install-godot.sh` (version from `.godot-version`), then
    `tools/check.sh`;
  - caches the Godot download keyed by `.godot-version`;
  - job name `checks`, so it can later be made a required status check;
  - fails if any step fails; no `continue-on-error`.
- `CLAUDE.md` Commands: add `tools/check.sh` as "run every check".
- `.claude/skills/implement-next/SKILL.md` Step 10: before merging, the
  `checks` CI run on the PR head must have succeeded (wait for it if still
  running; a red run goes back to the implementer like a failed local check).

## Acceptance criteria

- [ ] [test] `tools/check.sh` exits 0 on the branch head, and runs all four steps (its output names each).
- [ ] [test] `tools/check.sh` exits non-zero and names the step when one step fails (verify by running it in a temp worktree with a deliberately failing GUT test or a lint error - don't commit that change).
- [ ] [test] `.github/workflows/ci.yml` is valid YAML with the triggers, job name and steps above (a GUT test or a script that parses it is fine; `actionlint` if available).
- [ ] [manual] The `checks` workflow runs on this issue's own PR and is green before merge.
- [ ] [test] `CLAUDE.md` lists `tools/check.sh`, and `implement-next` Step 10 requires a green `checks` run before merging.

## Assets

None.

## Out of scope

- Making `checks` a required status check in the repository rules (the user does that in GitHub settings).
- Export builds, releases, deployment.
- Code scanning (CodeQL doesn't analyse GDScript).

## Notes

Architecture section 11. Depends on #1.
