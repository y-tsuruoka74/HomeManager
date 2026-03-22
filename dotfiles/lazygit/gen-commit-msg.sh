#!/usr/bin/env bash
set -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)
TICKET=""
if [[ $BRANCH =~ \#([0-9]{1,6}) ]]; then
  TICKET="${BASH_REMATCH[1]}"
elif TICKET=$(echo "$BRANCH" | grep -oE '(^|[/_-])[A-Za-z0-9]+[-_]?[0-9]{1,6}' | grep -oE '[0-9]{1,6}$' | tail -1) && [ -n "$TICKET" ]; then
  :
else
  TICKET=$(echo "$BRANCH" | grep -oE '[0-9]{1,6}' | tail -1)
fi

if [ -n "$TICKET" ]; then
  TICKET_RULE="コミットタイトルの末尾にスペース1つと '#${TICKET}' を付けてください（例: 'feat: ログイン機能を追加 #${TICKET}'）。"
else
  TICKET_RULE="チケット番号は付けないでください。"
fi

AI_PROMPT="以下のgit diffを見て、コミットメッセージを生成してください。ルール：必ず日本語で記述する。Conventional Commitsフォーマット（type: subject）で先頭行を記述する。typeはfeat/fix/docs/style/refactor/test/choreのいずれか。${TICKET_RULE}コミットタイトルの後に空行を挟み、変更されたファイルごとの詳細な変更内容を日本語で箇条書きにする。コミットメッセージのみ出力すること。"

MSG=$(git diff --staged | claude --no-session-persistence --print --model haiku "$AI_PROMPT")
git commit -e -m "$MSG"
