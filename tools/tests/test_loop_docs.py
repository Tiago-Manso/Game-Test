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

    def test_checks_wait_covers_the_merged_head(self) -> None:
        # The last push before merging is the state.md / PR body commit, so the
        # wait for `checks` must come after it and before merge_pull_request.
        merge = section(".claude/skills/implement-next/SKILL.md", "Step 10 - Merge")
        last_push = merge.rfind("Commit, push")
        wait = merge.find("`checks`")
        merge_call = merge.find("merge_pull_request")
        self.assertNotEqual(last_push, -1, "Step 10 no longer pushes state.md")
        self.assertNotEqual(merge_call, -1, "Step 10 no longer calls merge_pull_request")
        self.assertGreater(wait, last_push, "`checks` wait comes before the last push")
        self.assertLess(wait, merge_call, "`checks` wait comes after merge_pull_request")


if __name__ == "__main__":
    unittest.main()
