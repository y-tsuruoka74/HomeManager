# 追加のシェル設定

# エイリアス
alias ll='eza -la'
alias ls='eza'
alias la='eza -a'
alias lt='eza --tree'
alias cat='bat'
alias grep='rg'

# 環境変数
export EDITOR='nvim'
export LANG='ja_JP.UTF-8'

# バージョン管理（mise または Nix devshell）
#
# 方案 A: mise を使う（既存の anyenv/asdf ワークフローに近い）
# - modules/packages.nix の mise を有効化
# - modules/zsh.nix の mise 初期化コメントを外す
# - 使い方:
#   mise install node@lts
#   mise use -g node@lts
#
# 方案 B: Nix devshell を使う（Nix ネイティブ、再現性高い）
# - 詳細: dotfiles/nix/VERSION_MANAGEMENT.md 参照
# - プロジェクトの flake.nix で開発環境を定義
# - 使い方:
#   cd ~/my-project
#   nix develop
#   # または .envrc に "use flake" を追加して direnv を使用
#
# ※ 両方のアプローチを共存させることも可能