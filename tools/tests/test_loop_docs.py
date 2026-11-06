"""Tests that the loop docs use tools/check.sh and the CI run (spec #13).

Run: python3 -m unittest discover -s tools/tests -v
"""

import os
import re
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def section(path: str, heading: str) -> str:
    """Text of the `## <heading>` section of a markdown file, up to the next `## `."""
    with open(os.path.join(ROOT, path), encoding="utf-8") as handle:
        text = handle.read()
    match = re.search(rf"^## {re.escape(heading)}\n(.*?)(?=^## |\Z)", text, re.M | re.S)
    if match is None:
        raise AssertionError(f"{path}: no section '## {heading}'")
    return match.group(1)


class LoopDocs(unittest.TestCase):
    def test_claude_md_commands_list_check_sh(self) -> None:
        commands = section("CLAUDE.md", "Commands")
        self.assertRegex(commands, r"(?i)run every check.*`tools/check\.sh`")

    def test_implement_next_merge_waits_for_green_checks(self) -> None:
        merge = section(".claude/skills/implement-next/SKILL.md", "Step 10 - Merge")
        self.assertIn("`checks`", merge)
        self.assertRegex(merge, r"(?i)wait")
        self.assertRegex(merge, r"(?i)succeeded")
        self.assertRegex(merge, r"(?i)implementer")


if __name__ == "__main__":
    unittest.main()
