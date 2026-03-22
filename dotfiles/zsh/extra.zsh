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
export PATH="$HOME/.local/bin:$PATH"

# GitHub トークン（aipf-cpanel 用）
# 注意: 本番環境では環境変数マネージャーを使用してください
# export NODE_AUTH_TOKEN="your_token_here"
# export NPM_TOKEN="your_token_here"

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
