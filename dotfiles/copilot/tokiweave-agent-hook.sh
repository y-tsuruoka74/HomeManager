#!/bin/sh
# Tokiweave連携: GitHub Copilot CLIのフック入力をTokiweaveの作業ログへ転送する。
#
# Copilotのフック入力はClaude Codeと同じフィールド名（hook_event_name / tool_name /
# tool_input）を使うため、変換せずそのまま渡せる。イベントの解釈はTokiweave側が行う。
set -eu

# Copilotがstdinへ書き込む前にこちらが終了するとEPIPEになるため、先に読み切る。
hook_input="$(cat 2>/dev/null || true)"

# TOKIWEAVE_HOOK_COMMAND はTokiweave経由で起動したときのみ設定される。
# 通常のcopilot利用では何もせず終了する。
[ -n "${TOKIWEAVE_HOOK_COMMAND:-}" ] || exit 0

# 転送の失敗でエージェントの作業を止めない。
printf '%s' "$hook_input" | sh -c "$TOKIWEAVE_HOOK_COMMAND" >/dev/null 2>&1 || true
