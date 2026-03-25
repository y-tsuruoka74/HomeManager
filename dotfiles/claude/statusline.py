#!/usr/bin/env python3
"""Status line: line 1 = model/context/rate-limits, line 2 = tokens/cost"""

import json
import os
import subprocess
import sys
import time

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

data = json.load(sys.stdin)

BLOCKS = " ▏▎▍▌▋▊▉█"
R = "\033[0m"
DIM = "\033[2m"
BOLD = "\033[1m"

# True-color helpers
GREEN = "\033[38;2;80;200;80m"
YELLOW = "\033[38;2;255;200;60m"
ORANGE = "\033[38;2;255;140;40m"
CYAN = "\033[38;2;80;200;220m"
GOLD = "\033[38;2;220;180;60m"
BLUE = "\033[38;2;95;175;255m"
PURPLE = "\033[38;2;156;122;242m"


def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f"\033[38;2;{r};200;80m"
    else:
        g = int(200 - (pct - 50) * 4)
        return f"\033[38;2;255;{max(g, 0)};60m"


def bar(pct, width=10):
    pct = min(max(pct, 0), 100)
    filled = pct * width / 100
    full = int(filled)
    frac = int((filled - full) * 8)
    b = "█" * full
    if full < width:
        b += BLOCKS[frac]
        b += "░" * (width - full - 1)
    return b


def fmt(label, pct, resets_at=None, color_fn=None):
    if color_fn is None:
        color_fn = gradient
    p = round(pct)
    reset_str = ""
    if resets_at is not None:
        remaining_secs = int(resets_at - time.time())
        if remaining_secs > 0:
            h, rem = divmod(remaining_secs, 3600)
            m = rem // 60
            if h > 0:
                reset_str = f" {h}h{m:02d}m"
            else:
                reset_str = f" {m}m"
        else:
            reset_str = " now"
    return f"{label} {color_fn(pct)}{bar(pct)} {p}%{R}{DIM}{reset_str}{R}"


# Pricing per 1M tokens (USD) — update as needed
PRICING = {
    # Claude 4 models
    "claude-opus-4": (15.0, 75.0),
    "claude-sonnet-4": (3.0, 15.0),
    # Claude 3.7 / 3.5 models
    "claude-3-7-sonnet": (3.0, 15.0),
    "claude-3-5-sonnet": (3.0, 15.0),
    "claude-3-5-haiku": (0.8, 4.0),
    # Claude 3 models
    "claude-3-opus": (15.0, 75.0),
    "claude-3-sonnet": (3.0, 15.0),
    "claude-3-haiku": (0.25, 1.25),
}


def estimate_cost(model_id, ctx_window):
    """Estimate cost in USD from token counts."""
    model_id_lower = (model_id or "").lower()
    price_in, price_out = 3.0, 15.0  # default: sonnet pricing
    for key, prices in PRICING.items():
        if key in model_id_lower:
            price_in, price_out = prices
            break

    total_in = ctx_window.get("total_input_tokens", 0) or 0
    total_out = ctx_window.get("total_output_tokens", 0) or 0
    cache_write = 0
    cache_read = 0
    current = ctx_window.get("current_usage")
    if current:
        cache_write = current.get("cache_creation_input_tokens", 0) or 0
        cache_read = current.get("cache_read_input_tokens", 0) or 0

    cost = (
        total_in * price_in / 1_000_000
        + total_out * price_out / 1_000_000
        + cache_write * price_in * 1.25 / 1_000_000
        + cache_read * price_in * 0.1 / 1_000_000
    )
    return cost


def fmt_cost(usd):
    if usd < 0.001:
        return f"{GOLD}$0.00{R}"
    elif usd < 1.0:
        return f"{GOLD}${usd:.3f}{R}"
    else:
        return f"{GOLD}${usd:.2f}{R}"


def get_claude_process_counts():
    """Return (active, total) Claude process counts.

    'total'  = number of 'claude' processes owned by the current user.
    'active' = subset where the process state is R (running) or the CPU
               usage reported by ps is > 0.
    """
    try:
        uid = os.getuid()
        result = subprocess.run(
            ["ps", "-u", str(uid), "-o", "pid=,stat=,pcpu=,comm="],
            capture_output=True,
            text=True,
            timeout=2,
        )
        total = 0
        active = 0
        for line in result.stdout.splitlines():
            parts = line.split(None, 3)
            if len(parts) < 4:
                continue
            _pid, stat, pcpu, comm = parts
            # Match the 'claude' binary (node process launched as 'claude')
            if not (comm.strip().endswith("claude") or "/claude" in comm):
                continue
            total += 1
            # 'active' = CPU running state OR measurable CPU usage
            try:
                cpu = float(pcpu)
            except ValueError:
                cpu = 0.0
            if stat.startswith("R") or cpu > 0.0:
                active += 1
        return active, total
    except Exception:
        return None, None


def fmt_tokens(n):
    if n is None:
        return "-"
    if n >= 1_000_000:
        return f"{n/1_000_000:.1f}M"
    elif n >= 1_000:
        return f"{n/1_000:.1f}k"
    return str(n)


# ── Line 1: model | context | rate limits ──────────────────────────────────
model_name = data.get("model", {}).get("display_name", "Claude")
model_id = data.get("model", {}).get("id", "")
parts1 = [model_name]

ctx_window = data.get("context_window", {})
ctx = ctx_window.get("used_percentage")
if ctx is not None:
    parts1.append(fmt("ctx", ctx))

five_data = data.get("rate_limits", {}).get("five_hour", {})
five = five_data.get("used_percentage")
if five is not None:
    parts1.append(fmt("5h", five, five_data.get("resets_at")))

week_data = data.get("rate_limits", {}).get("seven_day", {})
week = week_data.get("used_percentage")
if week is not None:
    parts1.append(fmt("7d", week, week_data.get("resets_at")))

line1 = f"{DIM}│{R}".join(f" {p} " for p in parts1)

# ── Line 2: tokens | cost ───────────────────────────────────────────────────
parts2 = []

# Today's token counts via ccusage
def get_today_usage():
    """Run `ccusage daily --json` and return today's entry, or None on failure."""
    ccusage_path = "/opt/homebrew/bin/ccusage"
    try:
        result = subprocess.run(
            [ccusage_path, "daily", "--json"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode != 0:
            return None
        payload = json.loads(result.stdout)
        # payload may be a list of daily entries or a dict with a list inside
        entries = payload if isinstance(payload, list) else payload.get("daily", [])
        today_str = time.strftime("%Y-%m-%d")
        for entry in entries:
            if entry.get("date", "").startswith(today_str):
                return entry
        return None
    except Exception:
        return None

today_entry = get_today_usage()

if today_entry is not None:
    today_in = today_entry.get("inputTokens", 0) or 0
    today_out = today_entry.get("outputTokens", 0) or 0
    parts2.append(
        f"{DIM}today:{R} {DIM}in{R} {fmt_tokens(today_in)}  {DIM}out{R} {fmt_tokens(today_out)}"
    )
    today_cost = today_entry.get("totalCost")
    if today_cost is not None:
        parts2.append(f"cost {fmt_cost(float(today_cost))}")
else:
    # Fallback: session token counts from stdin data
    total_in = ctx_window.get("total_input_tokens") or 0
    total_out = ctx_window.get("total_output_tokens") or 0
    if total_in > 0 or total_out > 0:
        parts2.append(
            f"{DIM}session:{R} {DIM}in{R} {fmt_tokens(total_in)}  {DIM}out{R} {fmt_tokens(total_out)}"
        )
    if total_in > 0 or total_out > 0:
        cost = estimate_cost(model_id, ctx_window)
        parts2.append(f"cost {fmt_cost(cost)}")

# Claude process counts (active / total)
proc_active, proc_total = get_claude_process_counts()
if proc_total is not None and proc_total > 0:
    if proc_active is not None and proc_active > 0:
        proc_color = GREEN
    else:
        proc_color = DIM
    parts2.append(f"{DIM}claude{R} {proc_color}{proc_active}{R}{DIM}/{R}{proc_total}")

line2 = f"{DIM}│{R}".join(f" {p} " for p in parts2)

# ── Line 3: git リポジトリ + ブランチ ────────────────────────────────────────
def get_git_info():
    """Return (repo_name, branch) for the current working directory, or (None, None)."""
    try:
        cwd = os.getcwd()
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, timeout=2, cwd=cwd,
        )
        if result.returncode != 0:
            return None, None
        repo_root = result.stdout.strip()
        home = os.path.expanduser("~")
        if repo_root.startswith(home):
            repo_name = "~" + repo_root[len(home):]
        else:
            repo_name = repo_root

        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=2, cwd=cwd,
        )
        branch = result.stdout.strip() if result.returncode == 0 else None
        return repo_name, branch
    except Exception:
        return None, None


repo_name, branch = get_git_info()
if repo_name:
    line3 = f" {BLUE} {repo_name}{R}"
    if branch:
        line3 += f"  {PURPLE}{branch}{R}"
    line3 += " "
else:
    line3 = None

# ── Output ──────────────────────────────────────────────────────────────────
print(line1, end="")
if line2:
    print(f"\n{line2}", end="")
if line3:
    print(f"\n{line3}", end="")
