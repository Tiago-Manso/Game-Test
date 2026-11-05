# Game-Test

## Project

A 2D game built with **Godot 4** (version pinned in `.godot-version`) and
**GDScript**. Art and animation sources are made in **Blender** when needed.

## Layout

The Godot project lives at the repository root (`project.godot`).

| Path               | Contents                                                        |
|--------------------|-----------------------------------------------------------------|
| `scenes/`          | `.tscn` scenes, grouped by feature (`scenes/player/`, ...)      |
| `scripts/`         | `.gd` scripts not owned by a single scene                       |
| `assets/`          | Imported game assets: `sprites/`, `audio/`, `fonts/`, `models/` |
| `test/`            | GUT tests: `test/unit/`, `test/integration/`, files `test_*.gd` |
| `addons/gut/`      | GUT test framework (vendored)                                   |
| `art/`             | Blender `.blend` sources - ignored by Godot (`.gdignore`)       |
| `specs/`           | Specs for issues                                                |
| `tools/`           | Dev scripts                                                     |

## Commands

The implementation loop runs install, import, lint and test before every PR.

- Install Godot + gdtoolkit: `tools/install-godot.sh`
- Import (refresh `.godot/` cache, catches broken resources): `godot --headless --path . --import`
- Lint: `gdlint scenes scripts test`
- Format check: `gdformat --check scenes scripts test`
- Test: `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit`
- Run the game: `godot --path .`

If Godot can't be installed (e.g. network blocked), the loop must not open or
merge a PR on untested code: it stops and reports the environment problem,
and resumes the issue from its logs once the environment works.

## GDScript conventions

- Static typing everywhere: `var speed: float = 200.0`, typed function signatures.
- `snake_case` files, functions and variables; `PascalCase` for `class_name` and nodes.
- One script per scene root where possible; prefer signals over reaching up the tree.
- Tunable values as `@export` variables, not magic numbers.
- Logic that can be tested without a scene goes in plain classes so GUT can test it directly.

## Art pipeline (Blender)

- Sources in `art/<name>.blend`; exports committed alongside (see `art/README.md`).
- 2D: render to PNG sprite sheets in `assets/sprites/<name>/`, animate in Godot with
  `AnimatedSprite2D` / `AnimationPlayer`.
- The loop never needs Blender. If an issue needs new art, the spec names the
  exported files; until they exist the loop uses placeholder sprites and says so in the PR.

## Autonomous implementation loop

Work is queued as GitHub issues and specified in `specs/`. One iteration is the
`implement-next` skill (`.claude/skills/implement-next/SKILL.md`). The session
running it orchestrates agents from `.claude/agents/`:

1. `implementer` - builds the issue with strict TDD (red, green and refactor commits per criterion); the loop opens a draft PR.
2. Specialist reviewers, in parallel: `quality-reviewer`, `security-reviewer`,
   `test-reviewer`, `performance-reviewer`. Each runs at least 2 rounds and until
   it reports no major issues; the implementer fixes majors between rounds.
   Minor findings are logged, not fixed, and collected into a `minor-findings` issue.
3. `general-reviewer` (Opus) - holistic review once the specialists are done.
4. `product-owner` (Opus) - GO / NO-GO against the spec; on GO the loop merges.

Every review is posted on the PR with inline comments, and the implementer
replies on each thread. Every agent keeps a log under `.loop/issue-<n>/` on the
branch (see `.claude/loop/state-log.md`), so an interrupted run resumes where it
stopped.

The loop needs no human: it reviews, accepts, merges and retries a failed issue
once by itself. The only human step is answering `needs-spec` issues with
`/refine-issue`. The whole discussion stays readable on each PR.

- Run continuously in a session: `/loop /implement-next` (or `/loop 30m /implement-next`).
- Run on a schedule: a scheduled task whose prompt is `/implement-next`.

Design discussions live in `discussions/` (`game-design.md` is the current
state; dated files are session logs). To queue work: run `/refine-issue <idea or #number>` and refine it together
with Claude. It interviews you, writes `specs/<n>-<slug>.md`, creates the issue
and labels it `ready`. (By hand: write the spec from `specs/_template.md`, open
an issue linking it, add `ready`.) The loop opens and merges one PR per issue
(label `autoloop`).

## Conventions

- Branches from the loop: `loop/issue-<n>-<slug>`. Code never goes straight to
  `main`; it is merged from a loop PR (merge commit) after the PO accepts.
- Exception: `refine-issue` pushes spec-only commits (files under `specs/` and `discussions/`) to
  `main` after the user approves the spec in the conversation.
- Keep changes scoped to the issue; extra ideas become new issues.
- Every acceptance criterion should be covered by a GUT test. Criteria that are
  purely visual or feel-based are marked `[manual]`: the PO judges them from the
  code, and the PR lists them as non-blocking checks to try later.
