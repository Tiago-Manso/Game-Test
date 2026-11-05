# Game architecture

- Status: approved (2026-11-05)
- Scope: the whole game. Milestone 1 (prototype) is specified in full; later
  milestones are described as extension points so the prototype doesn't block them.
- Sources: `discussions/game-design.md` (decisions `D-###`), specs `#1`-`#9`.
- Every task spec should link the sections of this document it implements.

## 1. Principles

- **A-01 Logic is plain code.** All game rules live in plain GDScript classes
  (`RefCounted` / `Resource`) under `scripts/core/`. They never touch nodes,
  scenes, input or files, so GUT tests them directly and fast.
- **A-02 Scenes only show and forward.** Scenes display state and turn player
  input into commands. They never change game state themselves.
- **A-03 One fixed-step simulation.** Time moves only through
  `Simulation.step(dt)`, called from one place at a fixed rate (60 Hz, D-031). Nothing else
  advances timers, damage or economy. This makes play deterministic and lets
  offline earnings reuse the same rules later.
- **A-04 Signals, no globals.** Each logic object emits its own typed signals.
  One `Game` node builds the objects and wires them to the UI. No gameplay
  autoloads or global event bus; dependencies are passed in, so tests build
  their own instances with their own config.
- **A-05 Data-driven balance.** Every tunable number lives in config
  resources (`data/*.tres`); code holds formulas, not numbers (D-008).
- **A-06 Numbers behind helpers.** Values are `float` for now, but all
  formatting goes through `NumberFormat` and all growth maths through
  `BalanceConfig`, so a big-number type can be swapped in later (D-021).
- **A-07 Save is a versioned snapshot.** The save file is versioned JSON
  written atomically; loading never crashes and migrates older versions.

## 2. Layers

```
+-------------------------------------------------------------+
| Presentation  scenes/   Main, Field, HUD, Shop, Settings    |
|               reads state via signals, sends commands        |
+-----------------------------^-------------------------------+
                  signals     |     commands (tap, buy, ...)
+-----------------------------v-------------------------------+
| Game          scenes/main/game.gd                           |
|               builds everything, owns the fixed-step clock, |
|               lifecycle (pause/quit -> save)                |
+-----------------------------^-------------------------------+
| Core logic    scripts/core/                                 |
|   Simulation -> BlockField, Team, Economy rules             |
|   GameState (progress + settings)                           |
+-----------------------------^-------------------------------+
| Data          data/*.tres  BalanceConfig, UnitConfig        |
+-------------------------------------------------------------+
| Platform      SaveGame (user://), input, display, OS events |
+-------------------------------------------------------------+
```

Dependencies only point down: presentation knows core, core knows data, data
knows nothing. Core never imports a scene.

## 3. Folder map

| Path | Contents |
|------|----------|
| `scripts/core/` | Pure logic: `game_state.gd`, `block_field.gd`, `team.gd`, `simulation.gd`, `number_format.gd`, `balance_config.gd`, `unit_config.gd` |
| `scripts/platform/` | `save_game.gd` and later platform services (Steam, mobile) |
| `data/` | `balance.tres` and later content resources (stages, bosses, abilities) |
| `scenes/main/` | `main.tscn` (root `Control` named `Main`) with `game.gd` |
| `scenes/field/` | Block slots and HP bars |
| `scenes/hud/` | Gold, DPS, gear button |
| `scenes/shop/` | Tap upgrade and unit rows |
| `scenes/settings/` | Settings panel |
| `test/unit/` | Tests of `scripts/core/` and `scripts/platform/` |
| `test/integration/` | Tests that instance scenes |

## 4. Core model (milestone 1)

### 4.1 `GameState` - progress and settings

Owns everything the save file stores, except the field's destroyed count.

| Field | Type | Start | Spec |
|-------|------|-------|------|
| `gold` | `float` | 0 | #5 |
| `tap_level` | `int` | 1 | #5, #6 |
| `unit_levels` | `Dictionary[StringName, int]` | all 0 | #7 |
| `notation` | `NumberFormat.Notation` | `SUFFIX` | #9 |

Signals: `gold_changed(gold)`, `tap_level_changed(level)`,
`unit_level_changed(id, level)`, `notation_changed(notation)`.
Methods: `add_gold`, `can_afford`, `spend` (#5).

### 4.2 `BlockField` - the blocks

Fixed slots (5), each a block (`hp`, `max_hp`, `gold`) or empty with a respawn
countdown. Owns `destroyed_count`, which drives block HP and gold scaling
(D-015). API and rules: spec #4. Signals: `block_broken(slot, gold)`,
`block_spawned(slot)`, plus `block_damaged(slot, hp)` so the HP bars update
without polling.

### 4.3 `Team` - automatic damage

Reads unit levels from `GameState` and unit stats from `BalanceConfig`.
`total_dps()` is cached and recomputed only on `unit_level_changed`.
`step(dt)` deals `total_dps * dt` to `BlockField.lowest_hp_slot()` (D-013);
damage with no target is lost. Spec #7.

### 4.4 `Simulation` - the clock

```gdscript
class_name Simulation extends RefCounted
func _init(state: GameState, field: BlockField, team: Team, config: BalanceConfig) -> void
func step(dt: float) -> void      # team.step(dt), then field.tick(dt)
func tap(slot: int) -> void       # tap damage on a slot
func buy_tap_upgrade() -> bool
func buy_unit(id: StringName) -> bool
```

- `Game` calls `step(dt)` from `_physics_process` at the physics tick rate
  (60 Hz by default). Neither the field scene nor any other node calls
  `tick` or `step` itself.
- Order inside a step: team damage first, then respawns, so a block that
  respawns this step can't be hit by damage meant for the previous one.
- Gold from breaks reaches `GameState` through `block_broken`, connected
  once in `Simulation` (one path for taps and team damage).
- Commands (`tap`, `buy_*`) are the only way presentation changes state.

### 4.5 `BalanceConfig` / `UnitConfig` - data

Resources with every number and the growth formulas (exponential, D-020).
Spec #3.

### 4.6 `NumberFormat` - display of numbers

Static helper, suffix or scientific (D-016). Every label that shows a game
number calls it with `GameState.notation`. Spec #2.

## 5. Presentation

- `Main` scene contains `Game` (script) and the UI scenes: `Field` (upper
  part), `HUD` (top bar), `Shop` (lower part), `Settings` (modal, hidden).
- **Binding.** In `_ready`, `Game` creates config, state, field, team and
  simulation, loads the save, then calls `setup(...)` on each UI scene with
  the objects it needs. UI scenes connect to signals in `setup` and update
  only when a signal fires - never by reading state in `_process`.
- **Input.** Each block is a `Control` with `gui_input`; a press calls
  `simulation.tap(slot)`. Touch and mouse both work because mouse emulates
  touch (D-022). The settings panel blocks input to the field while open (#9).
- **Display.** 540 x 960 base, stretch `canvas_items`, aspect `keep_width`,
  portrait (D-007). Layout uses containers and anchors, never absolute pixel
  positions that break on taller phones.
- **Feedback.** HP bars only in milestone 1 (D-023). Effects, if added later,
  live in presentation and react to signals; they never change state.

## 6. Persistence

- `SaveGame` (`scripts/platform/save_game.gd`), path injectable, default
  `user://save.json` (spec #8).
- Snapshot of `GameState` fields plus `BlockField.destroyed_count`;
  current block HP is not saved.
- `version` field; `load()` runs migrations `v1 -> v2 -> ...` in order, each a
  small function, so old saves keep working. Unknown or invalid data falls
  back to defaults; corrupt files are kept as `.bad`.
- Atomic write: `save.json.tmp`, then rename.
- When: every `autosave_interval` seconds of simulation time (D-024), and on
  `NOTIFICATION_APPLICATION_PAUSED`, `NOTIFICATION_APPLICATION_FOCUS_OUT` and
  `NOTIFICATION_WM_CLOSE_REQUEST`. Handled by `Game`, not by logic classes.
- A `saved_at` timestamp (Unix time) is stored from v1, ready for offline
  earnings later.

## 7. Testing strategy

| Layer | Test type | Notes |
|-------|-----------|-------|
| Core (`scripts/core/`) | Unit | Build objects with a test `BalanceConfig`; drive time with `step(dt)` - never real time or frames. |
| Platform (`SaveGame`) | Unit | Temp paths; clean up files. |
| Scenes | Integration | Instance the scene, call `setup` with test objects, simulate input events, assert on labels and node state. |
| Whole game | Integration (few) | Build `Main`, run N steps, check gold and blocks move as expected. |

Determinism (A-03) means no test waits on real time or frame timing.

## 8. Extension points for later milestones

None of these are built in milestone 1. The design above leaves room for them.

| Feature | How it plugs in |
|---------|-----------------|
| **Levels and bosses** | A `Stage` object (stage number, blocks left, boss timer) inside `Simulation`. `BlockField` gets block stats from a provider (`stage.block_hp(...)`) instead of `destroyed_count` directly; the boss is a block flagged `is_boss` with a timer that `step(dt)` counts down. |
| **Prestige (Time Warp)** | Split `GameState` into `RunState` (gold, levels, stage - reset on prestige) and `MetaState` (prestige currency, permanent bonuses - kept). Save v2 migrates v1 into `RunState`. |
| **Active abilities** | `Ability` resources (cooldown, duration, effect). Effects are **modifiers**: multipliers on tap damage, DPS or gold that the formulas read through one `Modifiers` object, so abilities, milestone multipliers and prestige bonuses all stack the same way. |
| **Milestone multipliers** | Same modifier pipeline, keyed by unit level thresholds in `UnitConfig`. |
| **Offline earnings** | On load, `elapsed = now - saved_at`, capped. Run an approximation of `Simulation` for `elapsed` (DPS x time, converted to blocks and gold with the same formulas), then show a "while you were away" summary. Never trusts a negative or huge clock jump. |
| **Big numbers** | Replace `float` with a `Big` value type (mantissa + exponent) behind `BalanceConfig` formulas, `GameState` amounts and `NumberFormat`. Save stores numbers as strings from that version on. |
| **Real art and sound** | Presentation only: sprite sheets from Blender (`art/` -> `assets/sprites/`), `AnimatedSprite2D` on the block and unit views, sound players reacting to signals. |
| **Steam / store builds** | `scripts/platform/` gets a `Platform` interface (achievements, cloud save) with a no-op default and per-store implementations; core never calls a store SDK. |

## 9. Decisions

| ID | Decision |
|----|----------|
| A-01 - A-07 | Principles in section 1. |
| D-027 | Architecture document lives in `specs/architecture.md`; task specs link its sections. |
| D-028 | Scope: whole game, milestone 1 in detail, later features as extension points. |
| D-029 | Pure fixed-step simulation: rules in plain classes, time only through `Simulation.step(dt)` from `_physics_process`. |
| D-030 | Systems talk through signals on state objects, wired by a `Game` node; no gameplay autoloads or event bus. |
| D-031 | Simulation runs at Godot's default physics rate, 60 Hz (was Q-009). Revisit if battery use on phones is a problem. |

## 10. Milestone 1 specs and this document

The milestone 1 specs were aligned with this document on 2026-11-05:

| Spec | Implements |
|------|------------|
| #3 Balance config | 4.5, A-05 |
| #2 Number formatting | 4.6, A-06 |
| #4 Blocks and slots | 4.2, 5; the field scene never advances time and updates on `block_damaged` |
| #5 Tap damage and gold | 4.1, 4.4, 5; introduces `Simulation` and the `Game` node driving `step` |
| #6 Tap damage upgrade | `Simulation.buy_tap_upgrade` |
| #7 Team units | 4.3; `Team.step` called by `Simulation.step` before respawns; cached DPS |
| #8 Save and load | 6, A-07; `saved_at` and the migration step |
| #9 Notation setting | 4.1, 4.6, 5 |
| #13 CI workflow | 11 |
| #14 Whole-game integration test | 7 |

## 11. Further tasks

Milestone 1 (issues created): **#13 CI workflow**, **#14 whole-game
integration test**.

Milestone 2 (to refine when it is planned): modifier pipeline, stage system
with boss timer, offline earnings.

## 12. Open questions

- Q-010 Offline earnings cap (e.g. 8 h, 24 h) - for milestone 2.
- Q-011 Should prestige (Time Warp) be in milestone 2 together with stages, or a
  separate milestone 3?
