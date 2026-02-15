# 追加のシェル設定

# エイリアス
alias ll='eza -la'
alias ls='eza'
alias ll='eza -la'
alias la='eza -a'
alias lt='eza --tree'
alias cat='bat'
alias grep='rg'

# 環境変数
export EDITOR='nvim'
export LANG='ja_JP.UTF-8'

# anyenv
if [ -d "$HOME/.anyenv" ]; then
  export PATH="$HOME/.anyenv/bin:$PATH"
  eval "$(anyenv init - zsh)"
fi

# asdf
if [ -d "$HOME/.asdf" ]; then
  . "$HOME/.asdf/asdf.sh"
fi