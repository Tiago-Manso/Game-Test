"""Tests for tools/check.sh (spec #13).

Run: python3 -m unittest discover -s tools/tests -v
Needs Godot and gdtoolkit on PATH (tools/install-godot.sh).
"""

import os
import shutil
import subprocess
import tempfile
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


# Copied into a throwaway copy of the project, never into the repo itself.
LINT_ERROR = "extends Node\n\n\nfunc BadName() -> void:\n\tpass\n"
FAILING_TEST = (
    "extends GutTest\n\n\nfunc test_deliberately_fails() -> void:\n"
    "\tassert_eq(1, 2, \"deliberate failure for check.sh\")\n"
)


class CheckFailsAndNamesStep(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.mkdtemp(prefix="check-sh-")
        self.copy = os.path.join(self._tmp, "project")
        skip = shutil.ignore_patterns(".git", ".godot", ".loop", "__pycache__")
        shutil.copytree(ROOT, self.copy, ignore=skip)

    def tearDown(self) -> None:
        shutil.rmtree(self._tmp, ignore_errors=True)

    def _write(self, rel_path: str, content: str) -> None:
        with open(os.path.join(self.copy, rel_path), "w", encoding="utf-8") as handle:
            handle.write(content)

    def _assert_fails_at(self, step: str) -> None:
        result = run_check(self.copy)
        output = result.stdout + result.stderr
        self.assertNotEqual(result.returncode, 0, output)
        self.assertIn(f"step '{step}' failed", output)
        self.assertNotIn("all checks passed", output)
        later = STEPS[STEPS.index(step) + 1 :]
        for skipped in later:
            self.assertNotIn(f"==> {skipped}", output, "check.sh must stop at the first failure")

    def test_lint_error_fails_lint_step(self) -> None:
        self._write("scripts/check_sh_lint_error.gd", LINT_ERROR)
        self._assert_fails_at("lint")

    def test_failing_gut_test_fails_test_step(self) -> None:
        self._write("test/unit/test_check_sh_deliberate.gd", FAILING_TEST)
        self._assert_fails_at("test")


if __name__ == "__main__":
    unittest.main()
