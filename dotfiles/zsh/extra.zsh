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

# GitHub トークン（aipf-cpanel 用）
# 注意: 本番環境では環境変数マネージャーを使用してください
# export NODE_AUTH_TOKEN="your_token_here"
# export NPM_TOKEN="your_token_here"

# zsh 補完を常に有効化
autoload -Uz compinit
compinit

# direnv
eval "$(direnv hook zsh)"

# sheldon (プラグインマネージャー)
# 使用する場合、以下のコメントを外してください
# eval "$(sheldon source)"

# go-task (タスクランナー)
eval "$(task --completion zsh)"

# ghq + peco 関数
function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src

# MySQL/MariaDB PKG_CONFIG_PATH
# export PKG_CONFIG_PATH="$(brew --prefix)/opt/mariadb-connector-c/lib/pkgconfig:$PKG_CONFIG_PATH"

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