#!/usr/bin/env python3
"""PreToolUse guard for `gh api`: allow read (GET/HEAD) calls, block write methods.

`gh api` can perform any HTTP method through the same subcommand, so a plain
allow/deny permission rule can't distinguish reads from writes. This hook
inspects the actual command for -X/--method flags and decides per call.
"""

import json
import re
import shlex
import sys

WRAPPERS = {"timeout", "time", "nice", "nohup", "stdbuf"}
OPERATORS = {"&&", "||", ";", "|", "|&", "&"}
WRITE_METHODS = {"POST", "PUT", "PATCH", "DELETE"}
SAFE_METHODS = {"GET", "HEAD"}


def strip_wrappers(tokens):
    i = 0
    while i < len(tokens):
        t = tokens[i]
        if t == "xargs":
            i += 1
            continue
        if t in WRAPPERS:
            i += 1
            if t == "timeout" and i < len(tokens) and re.match(r"^[\d.]+[smhd]?$", tokens[i]):
                i += 1
            while i < len(tokens) and tokens[i].startswith("-"):
                i += 1
            continue
        break
    return tokens[i:]


def split_subcommands(tokens):
    subs = [[]]
    for t in tokens:
        if t in OPERATORS:
            subs.append([])
        else:
            subs[-1].append(t)
    return [s for s in subs if s]


def check_gh_api(tokens):
    """Return 'write', 'ambiguous', 'safe', or None (not a gh-api call) for one subcommand."""
    tokens = strip_wrappers(tokens)
    if len(tokens) < 2 or tokens[0] != "gh" or tokens[1] != "api":
        return None
    args = tokens[2:]

    if any(a == "graphql" for a in args if not a.startswith("-")):
        return "ambiguous"

    method = "GET"
    for i, a in enumerate(args):
        if a in ("-X", "--method") and i + 1 < len(args):
            method = args[i + 1].upper()
        elif a.startswith("--method="):
            method = a.split("=", 1)[1].upper()
        elif re.match(r"^-X[A-Za-z]+$", a):
            method = a[2:].upper()

    if method in WRITE_METHODS:
        return "write"
    if method not in SAFE_METHODS:
        return "ambiguous"
    return "safe"


def emit(decision, reason):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
            "permissionDecisionReason": reason,
        }
    }))


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return

    command = payload.get("tool_input", {}).get("command", "")
    if not command:
        return

    try:
        tokens = shlex.split(command)
    except ValueError:
        emit("ask", "gh api コマンドの解析に失敗したため、内容を確認してください。")
        return

    verdict = None
    found_gh_api = False
    for sub in split_subcommands(tokens):
        result = check_gh_api(sub)
        if result is None:
            continue
        found_gh_api = True
        if result == "write":
            verdict = "write"
            break
        if result == "ambiguous" and verdict is None:
            verdict = "ambiguous"

    if not found_gh_api:
        return

    if verdict == "write":
        emit("deny", "gh api で書き込み系メソッド(POST/PUT/PATCH/DELETE)が検出されたため拒否しました。読み取り(GET/HEAD)のみ許可されています。")
    elif verdict == "ambiguous":
        emit("ask", "gh api graphql、またはメソッドを自動判定できないため、書き込みでないか確認してください。")
    else:
        emit("allow", "gh api の読み取り(GET/HEAD)操作のため許可しました。")


if __name__ == "__main__":
    main()
