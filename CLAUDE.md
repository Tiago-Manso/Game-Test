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

If Godot can't be installed (e.g. network blocked), the loop must not open a
PR on untested code: it marks the issue `blocked` and says why.

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
running it orchestrates three agents from `.claude/agents/`:

1. `implementer` - builds the issue with strict TDD (red, green and refactor commits per criterion).
2. `code-reviewer` - reviews code, tests and TDD history; loops with the implementer until it approves.
3. `product-owner` - checks every acceptance criterion; must accept before a PR is opened.

- Run continuously in a session: `/loop /implement-next` (or `/loop 30m /implement-next`).
- Run on a schedule: a scheduled task whose prompt is `/implement-next`.

To queue work: run `/refine-issue <idea or #number>` and refine it together
with Claude. It interviews you, writes `specs/<n>-<slug>.md`, creates the issue
and labels it `ready`. (By hand: write the spec from `specs/_template.md`, open
an issue linking it, add `ready`.) The loop opens one PR per issue
(label `autoloop`); a human reviews and merges.

## Conventions

- Branches from the loop: `loop/issue-<n>-<slug>`. Code never goes straight to `main`.
- Exception: `refine-issue` pushes spec-only commits (files under `specs/`) to
  `main` after the user approves the spec in the conversation.
- Keep changes scoped to the issue; extra ideas become new issues.
- Every acceptance criterion should be covered by a GUT test. Criteria that are
  purely visual or feel-based are stated as such in the spec and checked by a human
  in the PR.
