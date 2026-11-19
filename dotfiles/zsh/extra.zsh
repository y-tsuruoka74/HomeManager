# 追加のシェル設定

# エイリアス・環境変数・direnv統合は modules/zsh.nix で管理する。

# GitHub トークン（aipf-cpanel 用）
# 注意: 本番環境では環境変数マネージャーを使用してください
# export NODE_AUTH_TOKEN="your_token_here"
if command -v gh >/dev/null 2>&1; then
  NPM_TOKEN="$(gh auth token --hostname github.sakura.codes 2>/dev/null)"
  [[ -n "$NPM_TOKEN" ]] && export NPM_TOKEN || unset NPM_TOKEN
fi

# Copilot CLI 用 GitHub トークン
# security（署名済み標準コマンド）でキーチェーンから読み込むことで、
# copilot 自身（Nix 製・未署名バイナリ）がキーチェーンにアクセスして
# 都度許可を求められる問題を回避する。
# 事前に以下を一度実行してトークンを保存しておくこと:
#   security add-generic-password -a "$USER" -s copilot-github-token -w
GH_TOKEN="$(security find-generic-password -a "$USER" -s copilot-github-token -w 2>/dev/null)"
[[ -n "$GH_TOKEN" ]] && export GH_TOKEN

# sheldon (プラグインマネージャー)
# 使用する場合、以下のコメントを外してください
# eval "$(sheldon source)"

# go-task (タスクランナー)
eval "$(task --completion zsh)"

# HomeManager の構成選択。通常のタスク名・オプションは標準補完へ委譲する。
_task_home_manager() {
  if [[ -f Taskfile.yml && -f hosts/work.nix && -f hosts/personal.nix ]] &&
    [[ ${words[2]} == (home|build:home|darwin|build:darwin|nh:build|nh:home|nh:darwin) && CURRENT -eq 3 ]]; then
    if [[ $PREFIX == PROFILE=* ]]; then
      compset -P 'PROFILE='
      compadd work personal
      return
    elif [[ -z $PREFIX || $PREFIX == P* ]]; then
      compadd 'PROFILE=work' 'PROFILE=personal'
      return
    fi
  fi
  _task "$@"
}
compdef _task_home_manager task

# Git ユーザー切り替え
# ~/.config/git/identities/<名前>.gitconfig にプロファイルを置いておくと、
# `git-user <名前>` で ~/.gitconfig.identity (git.nix から include される
# 無条件 include ファイル) をそのプロファイルへのシンボリックリンクに切り替える。
# 引数無しなら現在のプロファイルと利用可能な一覧を表示する。
#
# `git-user list` で全プロファイルの user.name / email / signingkey / login を一覧表示する。
# `git-user add <名前> [--name N] [--email E] [--signingkey K] [--login L] [-y]` で
# プロファイルを作成・更新する。未指定の項目は対話入力（新規作成時のみ）。
# 既存プロファイルがある場合は現在値を表示して上書き確認し（-y で省略）、
# 指定した項目だけを上書きする。他プロファイルと email / signingkey が重複する場合は警告する。
# --signingkey には公開鍵（ssh-ed25519 AAAA...）を指定する（1Password の SSH 署名用）。
function git-user() {
  local identities_dir="${GIT_IDENTITIES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/git/identities}"
  local identity_file="$HOME/.gitconfig.identity"

  if [ "$1" = "list" ]; then
    local current="" f
    [ -L "$identity_file" ] && current="$(basename "$(readlink "$identity_file")" .gitconfig)"
    local found=0
    for f in "$identities_dir"/*.gitconfig(N); do
      found=1
      local p="${f:t:r}"
      if [ "$p" = "$current" ]; then echo "* $p"; else echo "  $p"; fi
      git config --file "$f" --get-regexp '^(user\.(name|email|signingkey)|github\.login)$' | sed 's/^/      /'
    done
    (( found )) || echo "プロファイルがありません ($identities_dir)"
    echo "(* = 現在のデフォルト)"
    return 0
  fi

  if [ "$1" = "add" ]; then
    shift
    local profile="$1"
    if [ -z "$profile" ] || [[ "$profile" == -* ]]; then
      echo "使い方: git-user add <名前> [--name N] [--email E] [--signingkey K] [--login L] [-y]" >&2
      return 1
    fi
    shift
    # git-identities-sync と同じ命名規則（owner 名として includeIf に使われる）
    if [[ ! "$profile" =~ '^[A-Za-z0-9][A-Za-z0-9_.-]*$' ]]; then
      echo "不正なプロファイル名です: $profile" >&2
      return 1
    fi

    local o_name o_email o_key o_login o_yes
    zparseopts -D -E -F -- -name:=o_name -email:=o_email -signingkey:=o_key -login:=o_login y=o_yes -yes=o_yes || return 1

    local target="$identities_dir/$profile.gitconfig"
    local is_new=0
    [ -f "$target" ] || is_new=1
    mkdir -p "$identities_dir"

    # 既存プロファイルがあれば現在値を表示し、上書きの確認を取る
    if (( ! is_new )); then
      echo "プロファイル '$profile' は既に存在します:"
      git config --file "$target" --list | sed 's/^/  /'
      if (( ${#o_yes} == 0 )); then
        local answer
        read -q "answer?指定した項目を上書きしますか? [y/N] "
        echo
        [ "$answer" = "y" ] || { echo "中止しました"; return 1; }
      fi
    fi

    local name="${o_name[2]}" email="${o_email[2]}" key="${o_key[2]}" login="${o_login[2]}"
    if (( is_new )); then
      [ -z "$name" ] && read "name?user.name: "
      [ -z "$email" ] && read "email?user.email: "
      [ -z "$key" ] && read "key?user.signingkey (公開鍵, 空で省略): "
      [ -z "$login" ] && read "login?github.login (空で省略): "
    fi

    [ -n "$name" ] && git config --file "$target" user.name "$name"
    [ -n "$email" ] && git config --file "$target" user.email "$email"
    [ -n "$key" ] && git config --file "$target" user.signingkey "$key"
    [ -n "$login" ] && git config --file "$target" github.login "$login"
    chmod 600 "$target" 2>/dev/null

    # 他プロファイルと email / signingkey が重複していないか確認する
    local other k v
    for other in "$identities_dir"/*.gitconfig(N); do
      [ "$other" = "$target" ] && continue
      for k in user.email user.signingkey; do
        v="$(git config --file "$target" "$k")"
        [ -n "$v" ] && [ "$v" = "$(git config --file "$other" "$k")" ] &&
          echo "警告: $k が '${other:t:r}' と同じです: $v" >&2
      done
    done

    if (( $+commands[git-identities-sync] )); then
      git-identities-sync
    fi
    echo "プロファイル '$profile' を保存しました ($target):"
    git config --file "$target" --list
    echo "デフォルトにする場合: git-user $profile"
    return 0
  fi

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
  if (( $+commands[git-identities-sync] )); then
    git-identities-sync
  fi
  echo "git user を '$1' に切り替えました:"
  git config --file "$target" --get-regexp '^user\.'
}

_git_user_profiles() {
  local -a profiles
  profiles=(${(f)"$(ls "${GIT_IDENTITIES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/git/identities}" 2>/dev/null | sed 's/\.gitconfig$//')"})
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
