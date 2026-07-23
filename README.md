# Home Manager Configuration

nix-darwin + Home Manager で macOS 環境全体を管理するリポジトリです。

## 前提条件

- Nix がインストールされていること（[Determinate Nix](https://github.com/DeterminateSystems/nix-installer) 推奨）
- Git がインストールされていること

## 構成

```
.
├── flake.nix            # Nix Flake 設定（nix-darwin + home-manager）
├── home.nix             # Home Manager メイン設定
├── modules/             # モジュール
│   ├── darwin.nix       # nix-darwin システム設定・Homebrew 管理
│   ├── packages.nix     # パッケージ管理
│   ├── zsh.nix          # zsh・starship・zoxide・fzf・direnv 設定
│   ├── git.nix          # Git・lazygit 設定
│   ├── editor.nix       # Neovim 設定（programs + dotfiles）
│   ├── terminal.nix     # ターミナル dotfiles（tmux, zellij, wezterm）
│   ├── ai.nix           # AI ツール dotfiles（claude）
│   └── apps.nix         # その他アプリ dotfiles（hammerspoon, gwq）
├── dotfiles/            # 生の dotfiles
│   ├── zsh/
│   │   ├── extra.zsh    # 追加の zsh 設定
│   │   └── prompt.zsh   # プロンプト設定
│   ├── nvim/
│   │   ├── init.lua     # Neovim メイン設定
│   │   └── lua/         # Lua モジュール
│   ├── wezterm/
│   │   └── wezterm.lua  # wezterm 設定
│   ├── tmux/
│   │   └── tmux.conf    # tmux 設定
│   ├── zellij/
│   │   └── config.kdl   # zellij 設定
│   ├── hammerspoon/
│   │   └── init.lua     # Hammerspoon macOS 自動化
│   ├── lazygit/
│   │   ├── config.yml          # lazygit 設定
│   │   └── gen-commit-msg.sh   # コミットメッセージ自動生成スクリプト
│   ├── gwq/
│   │   └── config.toml  # gwq リポジトリ管理設定
│   ├── claude/
│   │   ├── settings.json  # Claude Code 設定
│   │   └── statusline.py  # Claude Code ステータスライン
│   └── nix/
│       └── devshell.nix # Nix devshell テンプレート
└── README.md            # このファイル
```

## 管理範囲

| 対象 | 管理方法 |
|---|---|
| CLI ツール（ripgrep, lazygit 等） | Home Manager（`packages.nix`） |
| シェル・Git・Neovim 設定 | Home Manager（各モジュール） |
| Hammerspoon・gwq 等の dotfiles | Home Manager（`apps.nix`） |
| tmux・zellij・wezterm dotfiles | Home Manager（`terminal.nix`） |
| Claude dotfiles | Home Manager（`ai.nix`） |
| Homebrew formulae（borders 等） | nix-darwin（`darwin.nix`） |
| Homebrew casks（1password, wezterm 等） | nix-darwin（`darwin.nix`） |
| macOS システム設定 | nix-darwin（`darwin.nix`） |

## 初期セットアップ

```bash
# リポジトリをクローン
git clone <this-repo> ~/Github/github.com/y-tsuruoka74/HomeManager
cd ~/Github/github.com/y-tsuruoka74/HomeManager

# 初回のみ: nix-darwin のインストールと設定の適用
nix run nix-darwin -- switch --flake .#y-tsuruoka
```

## 使い方

### 設定の適用

```bash
darwin-rebuild switch --flake .#y-tsuruoka
```

CLI パッケージ、dotfiles、Homebrew、macOS システム設定がすべて一括で適用されます。

### Flake ロックの更新

```bash
nix flake update
darwin-rebuild switch --flake .#y-tsuruoka
```

## モジュールの拡張

### CLI パッケージの追加

`modules/packages.nix` の `home.packages` に追加:

```nix
home.packages = with pkgs; [
  newtool
];
```

### Homebrew cask の追加

`modules/darwin.nix` の `homebrew.casks` に追加:

```nix
homebrew.casks = [
  "new-app"
];
```

### dotfiles の追加

`dotfiles/` に設定ファイルを配置し、`modules/files.nix` から参照:

```nix
home.file.".config/<app>/config.yml".source = ./../dotfiles/app/config.yml;
```

### アプリ別モジュールの追加

1. `modules/<app>.nix` を作成
2. `home.nix` の `imports` に追加

```nix
imports = [
  ./modules/packages.nix
  ./modules/<app>.nix  # 追加
];
```

## バージョン管理

言語・ツールのバージョンは基本的に `packages.nix` で Nix 管理する（グローバルに1バージョン）。
プロジェクト単位で異なるバージョンが必要な場合は **Nix devshell** を使う。

（旧: mise でグローバル管理していたが、プロジェクト単位の切り替えには実際には使っておらず
グローバルインストーラーとしての役割しかなかったため、重複を避けて Nix に統合した）

### Nix devshell（プロジェクト単位）

direnv と組み合わせることでプロジェクトに入ると自動で環境が切り替わります:

```bash
echo "use flake" > .envrc
direnv allow
```

## Git ユーザー管理（複数マシン・複数プロファイル）

`user.name`/`user.email` はマシン・用途ごとに異なるため `modules/git.nix` では管理せず、
`~/.gitconfig.identity`（無条件 `include`、Nix管理外）から読み込む方式にしている。

### 別マシンでのセットアップ

会社Mac以外の新しいマシン（私用Mac等）でこのリポジトリを使う場合の流れ:

0. **事前確認**: `modules/darwin.nix` の `system.primaryUser` / `users.users.y-tsuruoka` と
   `flake.nix` の `home-manager.users.y-tsuruoka` は macOS のユーザー名 `y-tsuruoka` に
   ハードコードされている。ログインユーザー名が異なる場合は事前に合わせるか、
   これらの記述を変更する必要がある。
1. Nix をインストール（[Determinate Nix](https://github.com/DeterminateSystems/nix-installer) 推奨）
2. リポジトリを clone
   ```bash
   git clone <this-repo> ~/Github/github.com/y-tsuruoka74/HomeManager
   ```
3. そのマシン用の Git プロファイルを作成（下記「プロファイルの追加」参照）
4. 初回の nix-darwin 適用
   ```bash
   nix run nix-darwin -- switch --flake .#y-tsuruoka
   ```
   (Intel Mac の場合は `flake.nix` の `system = "aarch64-darwin"` を `x86_64-darwin` に変更)
5. そのマシン専用の SSH 鍵を新規発行し、GitHub に別鍵として登録（会社Macの秘密鍵は使い回さない）
   ```bash
   ssh-keygen -t ed25519 -C "<machine-name>"
   ```
6. 動作確認
   ```bash
   git config --list --show-origin | grep user\\.
   ssh -T git@github.com
   ```

2回目以降は `darwin-rebuild switch --flake .#y-tsuruoka` だけで反映できる。

### プロファイルの追加

`~/.config/git/identities/<名前>.gitconfig` に `[user]`（および任意で `[github]  login = ...`）
セクションを持つファイルを作成する。`github.login` はプロンプト表示（後述）で使用する。

```bash
mkdir -p ~/.config/git/identities
cat > ~/.config/git/identities/personal.gitconfig << 'EOF'
[user]
	name = <名前>
	email = <メールアドレス>
[github]
	login = <GitHubログイン名>
EOF
```

### プロファイルの切り替え（手動）

`dotfiles/zsh/extra.zsh` で定義している `git-user` 関数を使う。

```bash
git-user            # 現在のプロファイルと一覧を表示
git-user work       # work プロファイルに切り替え
git-user personal   # personal プロファイルに切り替え
```

内部では `~/.gitconfig.identity` を該当プロファイルへのシンボリックリンクに張り替えている。
これは「デフォルト」のプロファイルを決めるもので、下記の自動切り替えが無い場合に使われる。

### owner 単位での自動切り替え

`ghq.root = ~/Github` の構成上、リポジトリは `~/Github/<host>/<owner>/<repo>` に
配置される。Home Manager の activation 時に
`~/.config/git/identities/*.gitconfig` のファイル名を owner 名として読み取り、
`~/.config/git/auto-identities.gitconfig` に `includeIf` を自動生成する。

`<owner>.gitconfig` が `~/Github/github.com/<owner>/` に自動的に対応するため、
ユーザー名をNix設定へハードコードする必要はない。

マシン固有の `~/.config/git/identities/<owner>.gitconfig` には `[user]` と `[github]` に加え、
`core.sshCommand` で対応する秘密鍵を指定する。

これにより、対象リポジトリでは `git-user` のデフォルト設定にかかわらず正しいユーザーで
commit と push/fetch が行われる。新しい owner は identity ファイルを追加して
`git-identities-sync` を実行するだけで反映できる。`darwin-rebuild switch` と `git-user` の
実行時にも同じ同期処理が自動実行される。

```gitconfig
[core]
  sshCommand = ssh -F /dev/null -i ~/.ssh/<秘密鍵> -o IdentitiesOnly=yes
```

`~/.ssh/config` の `IdentityFile` が別アカウントの鍵を追加しないよう、複数アカウントでは
`-F /dev/null` を付けて identity ファイル側の鍵だけを使用する。

確認:

```bash
git config github.login
git config core.sshCommand
cat ~/.config/git/auto-identities.gitconfig
ssh -T -i ~/.ssh/<対応する鍵> -o IdentitiesOnly=yes git@github.com
```

`gh` CLI のログイン状態は Git の SSH 認証とは独立している。`gh` コマンドも利用する場合は、
各アカウントを `gh auth login` で登録したうえで `gh auth switch --user <owner>` を使用する。

## lazygitのAIコミットメッセージ生成

files画面で `Ctrl-y` を押すと、ステージ済みの差分から日本語のConventional Commits形式の
コミットメッセージを生成する。既定ではClaude Haikuを先に実行し、Claude CLIが存在しない、
または認証・実行エラーになった場合はCodex CLIの軽量モデルへ自動的にフォールバックする。
Codexはread-onlyで実行する。

```bash
# 既定値
export LAZYGIT_COMMIT_AI_PROVIDER=auto
export LAZYGIT_COMMIT_CODEX_MODEL=gpt-5.4-mini
export LAZYGIT_COMMIT_CODEX_REASONING=low
```

特定のproviderへ固定する場合は、lazygitを起動する前に指定する。

```bash
export LAZYGIT_COMMIT_AI_PROVIDER=claude
# または
export LAZYGIT_COMMIT_AI_PROVIDER=codex
lazygit
```

## トラブルシューティング

### darwin-rebuild コマンドが見つからない

nix-darwin 未インストールのため、初回は `nix run` を使用:

```bash
nix run nix-darwin -- switch --flake .#y-tsuruoka
```

### アーキテクチャの確認

`flake.nix` と `darwin.nix` の `system` / `nixpkgs.hostPlatform` を確認:

- Apple Silicon (M1/M2/M3...): `aarch64-darwin`
- Intel Mac: `x86_64-darwin`

## 参考リンク

- [nix-darwin](https://github.com/lnl7/nix-darwin)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
