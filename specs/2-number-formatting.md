# Number formatting

- Issue: #2
- Status: ready

## Context

Idle-game numbers grow huge. Every number on screen goes through one helper
so the look is consistent and the notation can be switched (D-016). Pure
logic, no scenes.

## Requirements

- `scripts/core/number_format.gd`, `class_name NumberFormat`, static functions only.
- `enum Notation { SUFFIX, SCIENTIFIC }`.
- `static func format(value: float, notation: Notation = Notation.SUFFIX) -> String`.
- Below 1000: the value rounded **down** to an integer, no suffix: `0`, `7`, `999`.
- From 1000 up, **suffix** notation: 3 significant digits, truncated (never rounded up), then a suffix:
  - `1234` -> `1.23K`, `12345` -> `12.3K`, `123456` -> `123K`, `999999` -> `999K`, `1000000` -> `1.00M`.
  - Suffixes per power of 1000: `K` (1e3), `M` (1e6), `B` (1e9), `T` (1e12), then `aa` (1e15), `ab`, ... `az`, `ba`, ... `zz`.
- From 1000 up, **scientific** notation: mantissa with 2 decimals, truncated, `e`, exponent: `1234` -> `1.23e3`, `1000000` -> `1.00e6`.
- Negative values: format the absolute value and prefix `-`.
- `INF` -> `∞`; `NAN` -> `?`.
- Floating-point edge: values just below a power of 1000 due to float error (e.g. `999999.9999999`) must not print `1000K`; they print `999K`.

## Acceptance criteria

- [ ] [test] Values below 1000 print as truncated integers (0, 7, 999.9 -> `999`).
- [ ] [test] Suffix examples above all produce the exact strings listed.
- [ ] [test] The suffix sequence is right at its boundaries: 1e12 -> `1.00T`, 1e15 -> `1.00aa`, 1e18 -> `1.00ab`, 1e15 * 1000^26 -> `1.00ba`.
- [ ] [test] Scientific examples produce the exact strings listed.
- [ ] [test] Negative, `INF` and `NAN` cases produce the strings listed.
- [ ] [test] No value from 1000 to 1e300 (sampled: each power of 10 and each power of 10 minus a tiny epsilon) ever produces a mantissa of 1000 or more.

## Assets

None.

## Out of scope

- The settings toggle (issue #9) and any UI.
- A big-number type beyond `float` (Q-006 answer, D-021).

## Notes

D-016, D-021. Depends on #1.
