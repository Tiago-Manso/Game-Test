Status: done

VERDICT: NO BLOCKING ISSUES

## Critical
(none)

## Important
(none)

## Minor
- [Q1-m1] scripts/core/block_field.gd:48 - `hp(-1)` (and `max_hp(-1)`, `gold(-1)`) silently returns slot 4's value because Packed arrays wrap negative indices (checked: `BlockField.new(load_default()).hp(-1)` -> 10.0), while `hp(5)` raises an out-of-bounds error. `has_block` treats both the same way, but the read accessors don't. Suggested fix: guard them like `has_block` (return 0.0 outside the range, or `assert`), or document that the index has to be valid.
- [Q1-m2] scenes/field/field.gd:21 - `setup()` is not idempotent. A second call appends another set of rows, so `_blocks` and `_bars` grow to 10, and it connects the same callables again, which Godot reports as an error. Only `Game` (#5) calls it once today, but a guard (`assert(_field == null)`, or clear the rows and disconnect first) would make the contract explicit.
- [Q1-m3] scenes/field/field.gd:1 - the field script has no `class_name`, so callers (the tests now, `Game` in #5) hold it as a plain `Control` and call `setup`/`block_count`/`hp_bar` dynamically, which goes around static typing (CLAUDE.md: static typing everywhere). Suggested fix: `class_name FieldView` (or similar), and type the callers with it.

## What I ran
- `gdlint scenes scripts test`: Success, no problems.
- `gdformat --check scenes scripts test`: 11 files unchanged (exit 0).
- In a private worktree at HEAD: `godot --headless --path . --import` exit 0; GUT full suite 55/55 passing, 4458 asserts, exit 0.
- Throwaway script in the worktree: Packed array negative index and `BlockField.hp(-1)` both return the last element (confirms Q1-m1).
- Checked against the spec and architecture section 5: the running game shows an empty field until `Game` calls `setup` in #5. That is by design (architecture 5 binding, spec #5), the implementer log says so, and it is not a finding. The PR should state it for the manual check.
