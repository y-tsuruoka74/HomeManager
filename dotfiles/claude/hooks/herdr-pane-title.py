#!/usr/bin/env python3
"""Show the latest Claude Code prompt as ephemeral Herdr pane metadata."""

import json
import os
import random
import socket
import sys
import time


def main() -> None:
    if os.environ.get("HERDR_ENV") != "1":
        return

    pane_id = os.environ.get("HERDR_PANE_ID")
    socket_path = os.environ.get("HERDR_SOCKET_PATH")
    if not pane_id or not socket_path:
        return

    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, OSError):
        return

    prompt = hook_input.get("prompt")
    if not isinstance(prompt, str):
        return

    title = " ".join(prompt.split())
    if not title:
        return
    if len(title) > 80:
        title = f"{title[:79]}…"

    source = "user:claude-title"
    request = {
        "id": f"{source}:{int(time.time() * 1000)}:{random.randrange(1_000_000):06d}",
        "method": "pane.report_metadata",
        "params": {
            "pane_id": pane_id,
            "source": source,
            "agent": "claude",
            "title": title,
            "tokens": {"summary": title},
            "ttl_ms": 3_600_000,
            "seq": time.time_ns(),
        },
    }

    try:
        client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        client.settimeout(0.5)
        client.connect(socket_path)
        client.sendall((json.dumps(request) + "\n").encode())
        try:
            client.recv(4096)
        except OSError:
            pass
        client.close()
    except OSError:
        # Hooks must never interrupt Claude Code when Herdr is unavailable.
        pass


if __name__ == "__main__":
    main()
