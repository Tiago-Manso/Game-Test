# Whole-game integration test

- Issue: #14
- Status: ready

## Context

Issues #1-#9 each test their own part. This test plays the prototype end to
end through the real `Main` scene, to catch wiring mistakes between them
(architecture section 7).

## Requirements

- `test/integration/test_game_flow.gd`, using GUT.
- Builds the real `Main` scene with a test `BalanceConfig` (small numbers so
  the flow is quick) and a temporary save path. If `Game` doesn't allow
  injecting these yet, add the smallest seam that does (e.g. exported
  properties set before `_ready`), without changing game behaviour.
- Drives time only through `Simulation.step(dt)` and input only through
  simulated input events on the block, shop and settings controls - no
  direct state changes, no real time.
- Covers this flow in one or more tests:
  1. Start: gold 0, 5 blocks with full HP, HUD shows `0`.
  2. Tap a block until it breaks: gold goes up by its gold; it respawns after `respawn_delay` of steps.
  3. Buy a tap upgrade when affordable; the next tap deals the new damage.
  4. Buy a Pistol; with no taps, N steps lower the lowest-HP block and eventually break blocks and add gold.
  5. Trigger the pause notification: a save file exists.
  6. Build a fresh `Main` with the same save path: gold, tap level, unit levels and block toughness are restored.
  7. Switch notation in settings: gold and shop labels show scientific notation once values pass 1000.
- Cleans up the temp save files and frees all nodes.

## Acceptance criteria

- [ ] [test] Each of the 7 flow points above is asserted, in order, through the real `Main` scene.
- [ ] [test] The test uses no real time (`await` on timers or frames) and no direct writes to `GameState`, `BlockField` or `Team`.
- [ ] [test] The test leaves no files in `user://` and no orphan nodes (GUT reports none).
- [ ] [test] The full suite, including this test, still passes, and this test runs in under 5 seconds.

## Assets

None.

## Out of scope

- New gameplay; any seam added is test-only plumbing.
- Performance benchmarking.

## Notes

Architecture sections 4, 5, 7. Depends on #9.
