"""Tests for tools/check.sh (spec #13).

Run: python3 -m unittest discover -s tools/tests -v
Needs Godot and gdtoolkit on PATH (tools/install-godot.sh).
"""

import os
import subprocess
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CHECK = os.path.join(ROOT, "tools", "check.sh")
STEPS = ("import", "lint", "format", "test")


def run_check(cwd: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["bash", os.path.join(cwd, "tools", "check.sh")],
        cwd=cwd,
        capture_output=True,
        text=True,
        timeout=600,
        check=False,
    )


class CheckPassesOnHead(unittest.TestCase):
    def test_exits_zero_and_names_every_step(self) -> None:
        result = run_check(ROOT)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        for step in STEPS:
            self.assertIn(f"==> {step}", output)
        self.assertIn("all checks passed", output)


if __name__ == "__main__":
    unittest.main()
