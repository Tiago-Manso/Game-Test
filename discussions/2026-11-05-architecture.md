# 2026-11-05 - Game architecture

Participants: Tiago, Claude

## Asked and answered

| Question | Answer |
|----------|--------|
| Where does the architecture document live? | **`specs/architecture.md`** in the repo, so agents and `/refine-issue` read it. |
| How far does it reach? | **Whole game**, milestone 1 in detail, later features as extension points. |
| How does the game simulate time? | **Pure fixed-step simulation**: rules in plain classes, `Simulation.step(dt)`. |
| How do systems and UI talk? | **Signals on state objects**, wired by a `Game` node; no globals. |
| Approve the draft? | **Approved as drafted.** |
| Update specs #4 and #5 to match? | **Yes** (also aligned #6-#9 in passing). |
| Tick rate (Q-009)? | **60 Hz**, Godot default. |
| New tasks? | **CI workflow** (#13) and **whole-game integration test** (#14) in milestone 1; milestone 2 tasks later. |

Decisions D-027 to D-031 recorded in `game-design.md`.
