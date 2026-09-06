import importlib.util
import json
from pathlib import Path
import subprocess
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("watchdog", ROOT / "scripts/process_watchdog.py")
watchdog = importlib.util.module_from_spec(spec)
spec.loader.exec_module(watchdog)


class WatchdogTests(unittest.TestCase):
    def row(self, cpu=40, started="Mon Sep 07 10:00:00 2026"):
        return {"pid": 123, "cpu": cpu, "started": started, "command": "/bin/lazygit"}

    def test_requires_full_hour_of_samples(self):
        state = {}
        for now in (0, 900, 1800, 2700):
            state, expired = watchdog.high_cpu_samples([self.row()], state, now)
            self.assertEqual(expired, [])
        _, expired = watchdog.high_cpu_samples([self.row()], state, 3600)
        self.assertEqual(expired, [self.row()])

    def test_low_cpu_or_missing_process_resets_history(self):
        for rows in ([], [self.row(cpu=5)]):
            state, _ = watchdog.high_cpu_samples([self.row()], {}, 0)
            state, _ = watchdog.high_cpu_samples(rows, state, 900)
            _, expired = watchdog.high_cpu_samples([self.row()], state, 3600)
            self.assertEqual(expired, [])

    def test_gap_clock_reversal_and_pid_reuse_reset_history(self):
        state, _ = watchdog.high_cpu_samples([self.row()], {}, 0)
        for now, row in ((3600, self.row()), (-1, self.row()),
                         (900, self.row(started="new process"))):
            current, expired = watchdog.high_cpu_samples([row], state, now)
            self.assertEqual(expired, [])
            self.assertEqual(next(iter(current.values()))["first"], now)

    @patch.object(watchdog.os, "kill")
    @patch.object(watchdog.subprocess, "run")
    def test_does_not_kill_reused_pid(self, run, kill):
        run.return_value = subprocess.CompletedProcess([], 0, "different start time")
        watchdog.terminate(self.row(), "test")
        kill.assert_not_called()

    @patch.object(watchdog.subprocess, "run")
    def test_ps_parsing_preserves_command_arguments(self, run):
        run.return_value = subprocess.CompletedProcess(
            [], 0, "123 42.5 Mon Sep  7 10:00:00 2026 /bin/lazygit\n"
            "124 0.0 Mon Sep  7 10:00:00 2026 node /bin/live-server --port=8080\n",
        )
        rows = watchdog.processes()
        self.assertEqual(rows[0]["started"], self.row()["started"].replace("07", "7"))
        self.assertEqual(rows[1]["command"], "node /bin/live-server --port=8080")


class CopilotMergeTests(unittest.TestCase):
    entries = [{"bash": "bash '/Users/example/.copilot/hooks/herdr-agent-state.sh'",
                "type": "command", "timeoutSec": 10}]

    def merge(self, content):
        return subprocess.run(
            ["jq", "-s", "--argjson", "entries", json.dumps(self.entries),
             "-f", str(ROOT / "scripts/merge-copilot-hooks.jq")],
            input=content, text=True, capture_output=True,
        )

    def test_preserves_other_hooks_and_is_idempotent(self):
        other = {"bash": "another-hook", "type": "command"}
        old = {**self.entries[0], "timeoutSec": 1}
        result = self.merge(json.dumps({"token": "fixture", "hooks": {
            "SessionStart": [other, old, old], "Stop": [other]}}))
        self.assertEqual(result.returncode, 0, result.stderr)
        config = json.loads(result.stdout)
        self.assertEqual(config["token"], "fixture")
        self.assertEqual(config["hooks"]["Stop"], [other])
        self.assertEqual(config["hooks"]["SessionStart"], [other] + self.entries)
        self.assertEqual(json.loads(self.merge(result.stdout).stdout), config)

    def test_empty_file_initialization(self):
        self.assertEqual(json.loads(self.merge("").stdout),
                         {"hooks": {"SessionStart": self.entries}})

    def test_invalid_input_is_rejected(self):
        for value in ('{', '[]', 'null', '{"hooks": 1}',
                      '{"hooks":{"SessionStart":{}}}', '{} {}'):
            with self.subTest(value=value):
                self.assertNotEqual(self.merge(value).returncode, 0)


if __name__ == "__main__":
    unittest.main()
