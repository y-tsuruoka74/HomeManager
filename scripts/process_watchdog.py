"""macOS user agents: process counting, sampled CPU monitoring and server expiry."""

import argparse
import datetime
import json
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import time


def processes():
    result = subprocess.run(
        ["/bin/ps", "-axo", "pid=,pcpu=,lstart=,comm="],
        check=True, capture_output=True, text=True, env={**os.environ, "LC_ALL": "C"},
    )
    rows = []
    for line in result.stdout.splitlines():
        fields = line.split(None, 7)
        if len(fields) != 8:
            continue
        pid, cpu, *rest = fields
        started = " ".join(rest[:5])
        rows.append({
            "pid": int(pid), "cpu": float(cpu), "started": started,
            "epoch": datetime.datetime.strptime(started, "%a %b %d %H:%M:%S %Y").timestamp(),
            "command": rest[5],
        })
    return rows


def high_cpu_samples(rows, previous, now, duration=3600, threshold=30, max_gap=1800):
    """Require high CPU at every observed sample for an hour; reset after gaps."""
    current, expired = {}, []
    for row in rows:
        if Path(row["command"]).name != "lazygit" or row["cpu"] < threshold:
            continue
        key = f'{row["pid"]}:{row["started"]}'
        old = previous.get(key, {})
        first = old.get("first", now)
        last = old.get("last", now)
        if not (0 <= now - last <= max_gap and first <= last):
            first = now
        current[key] = {"first": first, "last": now}
        if now - first >= duration:
            expired.append(row)
    return current, expired


def notify(title, body):
    subprocess.run(
        ["/opt/homebrew/bin/terminal-notifier", "-title", title, "-message", body],
        check=False,
    )


def terminate(row, reason):
    # Recheck start time to avoid acting on a PID reused since the sample.
    result = subprocess.run(
        ["/bin/ps", "-p", str(row["pid"]), "-o", "lstart="],
        capture_output=True, text=True, env={**os.environ, "LC_ALL": "C"},
    )
    if result.returncode or " ".join(result.stdout.split()) != row["started"]:
        return
    try:
        os.kill(row["pid"], signal.SIGKILL)
    except ProcessLookupError:
        return
    notify(f'{Path(row["command"]).name}を自動終了しました', f'PID {row["pid"]}: {reason}')


def save_state(path, state):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix="watchdog-")
    try:
        with os.fdopen(fd, "w") as stream:
            json.dump(state, stream)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=["count", "cpu", "live-server"])
    mode = parser.parse_args().mode
    rows, now = processes(), time.time()
    if mode == "count":
        count = sum(Path(row["command"]).name == "lazygit" for row in rows)
        if count >= 3:
            notify(f"lazygitが{count}個起動中", "閉じ忘れがないか確認してください")
    elif mode == "cpu":
        path = Path.home() / ".local/state/process-watchdog/lazygit.json"
        try:
            previous = json.loads(path.read_text())
            if not isinstance(previous, dict) or not all(
                isinstance(value, dict)
                and all(isinstance(value.get(key), (int, float)) for key in ("first", "last"))
                for value in previous.values()
            ):
                previous = {}
        except (FileNotFoundError, ValueError):
            previous = {}
        state, expired = high_cpu_samples(rows, previous, now)
        save_state(path, state)
        for row in expired:
            terminate(row, "15分ごとの観測でCPU 30%以上が60分継続")
    else:
        for row in rows:
            if "/bin/live-server" in row["command"] and now - row["epoch"] >= 7200:
                terminate(row, "起動から120分経過")


if __name__ == "__main__":
    main()
