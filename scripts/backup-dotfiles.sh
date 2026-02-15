#!/bin/bash
# Home Manager 設定適用前に既存の dotfiles をバックアップ

set -e

BACKUP_DIR="${HOME}/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "📦 既存の dotfiles をバックアップ中..."

# バックアップディレクトリの作成
mkdir -p "$BACKUP_DIR"

# バックアップするファイルのリスト
FILES_TO_BACKUP=(
  "${HOME}/.zshrc"
  "${HOME}/.gitconfig"
  "${HOME}/.config/nvim"
)

BACKUP_COUNT=0

for FILE in "${FILES_TO_BACKUP[@]}"; do
  if [ -e "$FILE" ]; then
    BASENAME=$(basename "$FILE")
    echo "  📁 バックアップ: $FILE"
    if [ -d "$FILE" ]; then
      cp -R "$FILE" "${BACKUP_DIR}/${BASENAME}"
    else
      cp "$FILE" "${BACKUP_DIR}/${BASENAME}"
    fi
    ((BACKUP_COUNT++))
  fi
done

echo ""
echo "✅ バックアップ完了: ${BACKUP_DIR}"
echo "   ${BACKUP_COUNT} 個のファイルをバックアップしました"

# バックアップディレクトリの場所を記録
echo "$BACKUP_DIR" > "${HOME}/.config/last-dotfiles-backup"

echo ""
echo "💡 リストアが必要な場合:"
echo "   ls ${BACKUP_DIR}"
echo "   cp -R ${BACKUP_DIR}/* ~/"
echo ""
echo "💡 Home Manager を適用する準備ができました:"