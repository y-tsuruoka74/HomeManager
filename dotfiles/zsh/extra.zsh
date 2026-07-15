# 追加のシェル設定

# エイリアス
alias ll='eza -la'
alias ls='eza'
alias la='eza -a'
alias lt='eza --tree'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias du='dust'
alias top='btm'
alias htop='btm'

# 環境変数
export EDITOR='nvim'
export LANG='ja_JP.UTF-8'
export PATH="$HOME/.local/bin:$PATH"

# GitHub トークン（aipf-cpanel 用）
# 注意: 本番環境では環境変数マネージャーを使用してください
# export NODE_AUTH_TOKEN="your_token_here"
# export NPM_TOKEN="your_token_here"

# Copilot CLI 用 GitHub トークン
# security（署名済み標準コマンド）でキーチェーンから読み込むことで、
# copilot 自身（Nix 製・未署名バイナリ）がキーチェーンにアクセスして
# 都度許可を求められる問題を回避する。
# 事前に以下を一度実行してトークンを保存しておくこと:
#   security add-generic-password -a "$USER" -s copilot-github-token -w
GH_TOKEN="$(security find-generic-password -a "$USER" -s copilot-github-token -w 2>/dev/null)"
[[ -n "$GH_TOKEN" ]] && export GH_TOKEN

# direnv
eval "$(direnv hook zsh)"

# sheldon (プラグインマネージャー)
# 使用する場合、以下のコメントを外してください
# eval "$(sheldon source)"

# go-task (タスクランナー)
eval "$(task --completion zsh)"

# Git ユーザー切り替え
# ~/.config/git/identities/<名前>.gitconfig にプロファイルを置いておくと、
# `git-user <名前>` で ~/.gitconfig.identity (git.nix から include される
# 無条件 include ファイル) をそのプロファイルへのシンボリックリンクに切り替える。
# 引数無しなら現在のプロファイルと利用可能な一覧を表示する。
function git-user() {
  local identities_dir="$HOME/.config/git/identities"
  local identity_file="$HOME/.gitconfig.identity"

  if [ -z "$1" ]; then
    local current=""
    if [ -L "$identity_file" ]; then
      current="$(basename "$(readlink "$identity_file")" .gitconfig)"
    fi
    echo "現在のプロファイル: ${current:-未設定}"
    echo "利用可能なプロファイル:"
    ls "$identities_dir" 2>/dev/null | sed 's/\.gitconfig$//' | sed 's/^/  /'
    return 0
  fi

  local target="$identities_dir/$1.gitconfig"
  if [ ! -f "$target" ]; then
    echo "プロファイルが見つかりません: $1 ($target)" >&2
    return 1
  fi

  ln -sf "$target" "$identity_file"
  echo "git user を '$1' に切り替えました:"
  git config --file "$target" --get-regexp '^user\.'
}

_git_user_profiles() {
  local -a profiles
  profiles=(${(f)"$(ls "$HOME/.config/git/identities" 2>/dev/null | sed 's/\.gitconfig$//')"})
  _describe 'profile' profiles
}
compdef _git_user_profiles git-user

# Nix で管理しているツールの現在のバージョン一覧
# home.packages で入れた実体は /etc/profiles/per-user/$USER/bin にシンボリックリンクされ、
# その先の /nix/store/<hash>-<name>-<version>/... から名前とバージョンを抽出して一覧表示する。
# --version 等をツールごとに個別実装する必要がなく、実際にインストールされている
# 内容と常に一致する（packages.nix と手動でズレることがない）。
function tool-versions() {
  local profile_bin="/etc/profiles/per-user/$USER/bin"
  local f target
  for f in "$profile_bin"/*(N); do
    target=$(readlink -f "$f" 2>/dev/null) || continue
    [[ "$target" == /nix/store/* ]] || continue
    echo "$target" | sed -E 's|^/nix/store/[a-z0-9]+-([^/]+)/.*|\1|'
  done | sort -u
}

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
