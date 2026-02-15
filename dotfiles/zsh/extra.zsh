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

# mise (バージョン管理 - anyenv の代替)
# mise コマンドは Home Manager によってインストール・初期化されます
# 言語のインストール:
#   mise install node@lts
#   mise install python@3.12
#   mise install go@latest
#
# グローバルに設定:
#   mise use -g node@lts
#   mise use -g python@3.12
#
# その他の anyenv/asdf 設定は mise に移行可能です
# 詳細: https://mise.jdx.dev