# discussions/

Design conversations about **what** we're building, before it becomes specs.
This is the raw material `/refine-issue` turns into `specs/` and GitHub issues.

## Files

- `game-design.md` - the current, consolidated picture of the game: decisions
  made so far and open questions. Always kept up to date; read this first.
- `YYYY-MM-DD-<topic>.md` - one log per discussion session: what was asked,
  what was answered, what was decided and why. Never rewritten afterwards;
  later sessions add new files.

## Flow

1. Discuss -> log the session here and update `game-design.md`.
2. When an area is clear enough, mark it **ready to spec** in `game-design.md`.
3. `/refine-issue <area>` reads these files, splits the area into issues and
   writes one spec per issue, linking back to the discussion it came from.
4. The loop (`/implement-next`) builds the specs.

## Decision format

Each decision gets an ID so specs can cite it: `D-001`, `D-002`, ...
Open questions get `Q-001`, ... and are removed from the open list once
answered (the answer becomes a decision that references the question).
