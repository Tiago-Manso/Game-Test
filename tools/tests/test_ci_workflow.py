"""Tests for .github/workflows/ci.yml (spec #13).

Run: python3 -m unittest discover -s tools/tests -v
PyYAML is installed with gdtoolkit (tools/install-godot.sh).
"""

import os
import unittest

import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
WORKFLOW = os.path.join(ROOT, ".github", "workflows", "ci.yml")


def load_workflow() -> dict:
    with open(WORKFLOW, encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def triggers(workflow: dict) -> dict:
    # YAML 1.1 reads a bare `on` key as the boolean True.
    return workflow.get("on", workflow.get(True))


def step_index(steps: list, predicate) -> int:
    for index, step in enumerate(steps):
        if predicate(step):
            return index
    return -1


def uses(action: str):
    return lambda step: str(step.get("uses", "")).startswith(action + "@")


def runs(command: str):
    return lambda step: command in str(step.get("run", ""))


class CiWorkflow(unittest.TestCase):
    def setUp(self) -> None:
        self.assertTrue(os.path.isfile(WORKFLOW), "missing .github/workflows/ci.yml")
        self.workflow = load_workflow()
        self.assertIsInstance(self.workflow, dict, "ci.yml must be a YAML mapping")

    def job(self) -> dict:
        jobs = self.workflow.get("jobs", {})
        self.assertIn("checks", jobs, "no job with id `checks`")
        return jobs["checks"]

    def steps(self) -> list:
        steps = self.job().get("steps")
        self.assertIsInstance(steps, list, "job `checks` has no steps")
        return steps

    def test_runs_on_pull_requests_and_pushes_to_main(self) -> None:
        on = triggers(self.workflow)
        self.assertIsInstance(on, dict, f"`on` must be a mapping, got {on!r}")
        self.assertIn("pull_request", on)
        self.assertEqual((on.get("push") or {}).get("branches"), ["main"])

    def test_has_one_job_named_checks_on_ubuntu(self) -> None:
        self.assertEqual(list(self.workflow.get("jobs", {})), ["checks"])
        job = self.job()
        self.assertEqual(job.get("name", "checks"), "checks")
        self.assertEqual(job["runs-on"], "ubuntu-latest")

    def test_steps_checkout_python_install_then_check(self) -> None:
        steps = self.steps()
        order = [
            step_index(steps, uses("actions/checkout")),
            step_index(steps, uses("actions/setup-python")),
            step_index(steps, runs("tools/install-godot.sh")),
            step_index(steps, runs("tools/check.sh")),
        ]
        self.assertNotIn(-1, order, f"missing a required step: {order}")
        self.assertEqual(order, sorted(order), "steps out of order")

    def test_caches_godot_keyed_by_godot_version(self) -> None:
        steps = self.steps()
        cache = step_index(steps, uses("actions/cache"))
        self.assertNotEqual(cache, -1, "no actions/cache step")
        self.assertLess(cache, step_index(steps, runs("tools/install-godot.sh")))
        cache_with = steps[cache].get("with", {})
        self.assertIn("godot", str(cache_with.get("path")))
        self.assertIn("hashFiles('.godot-version')", str(cache_with.get("key")))

    def test_no_continue_on_error(self) -> None:
        self.assertNotIn("continue-on-error", self.job())
        for step in self.steps():
            self.assertNotIn("continue-on-error", step, step)


if __name__ == "__main__":
    unittest.main()
