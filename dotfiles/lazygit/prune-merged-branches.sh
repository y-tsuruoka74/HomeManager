#!/usr/bin/env bash
set -e

git fetch --prune --quiet

DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$DEFAULT_BRANCH" ]; then
  if git show-ref --verify --quiet refs/heads/main; then
    DEFAULT_BRANCH="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    DEFAULT_BRANCH="master"
  else
    echo "デフォルトブランチを判定できませんでした。" >&2
    exit 1
  fi
fi

CURRENT_BRANCH=$(git branch --show-current)
REMOTE_BRANCHES=$(git for-each-ref --format='%(refname:short)' refs/remotes/origin | sed 's@^origin/@@')

worktree_path_for_branch() {
  git worktree list --porcelain | awk -v b="refs/heads/$1" '
    /^worktree / { path = substr($0, 10) }
    /^branch /   { if ($2 == b) { print path; exit } }
  '
}

DELETED=0
while IFS= read -r branch; do
  [ -z "$branch" ] && continue
  [ "$branch" = "$DEFAULT_BRANCH" ] && continue
  [ "$branch" = "$CURRENT_BRANCH" ] && continue

  if grep -qx "$branch" <<< "$REMOTE_BRANCHES"; then
    continue
  fi

  WT_PATH=$(worktree_path_for_branch "$branch")
  if [ -n "$WT_PATH" ]; then
    if [ -n "$(git -C "$WT_PATH" status --porcelain --ignore-submodules 2>/dev/null)" ]; then
      echo "スキップ: $branch（ワークツリー ${WT_PATH} に未コミットの変更があるため保持）"
      continue
    fi
    echo "ワークツリー削除: $WT_PATH（$branch）"
    if ! git worktree remove "$WT_PATH"; then
      echo "失敗: ワークツリー ${WT_PATH} の削除に失敗しました。" >&2
      continue
    fi
  fi

  echo "削除: $branch（${DEFAULT_BRANCH} にマージ済み、リモートに存在しない）"
  if git branch -D "$branch"; then
    DELETED=$((DELETED + 1))
  else
    echo "失敗: $branch の削除に失敗しました。" >&2
  fi
done <<< "$(git branch --merged "$DEFAULT_BRANCH" --format='%(refname:short)')"

if [ "$DELETED" -eq 0 ]; then
  echo "削除対象のブランチはありませんでした。"
fi
