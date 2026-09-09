# Home Manager Configuration

nix-darwin + Home Manager で macOS 環境全体を管理するリポジトリです。

## 前提条件

- Nix がインストールされていること（[Determinate Nix](https://github.com/DeterminateSystems/nix-installer) 推奨）
- Git がインストールされていること

## 構成

```
.
├── flake.nix            # Nix Flake 設定（nix-darwin + home-manager）
├── machine.nix          # ユーザー名・ホーム・アーキテクチャの共通定義
├── home.nix             # Home Manager メイン設定
├── modules/             # モジュール
│   ├── darwin.nix       # darwin/ の読み込み
│   ├── darwin/          # system.nix / homebrew.nix / services.nix
│   ├── packages.nix     # 設定を持たない汎用CLI
│   ├── zsh.nix          # zsh・starship・zoxide・fzf・direnv 設定
│   ├── git.nix          # Git・lazygit 設定
│   ├── editor.nix       # Neovim 設定（programs + dotfiles）
│   ├── terminal.nix     # ターミナル dotfiles（tmux, zellij, wezterm, herdr）
│   ├── ai/              # AI ツール別設定（claude/codex/copilot/opencode/pi）
│   │   ├── default.nix  # 5ファイルをまとめて import
│   │   ├── claude.nix
│   │   ├── codex.nix
│   │   ├── copilot.nix
│   │   ├── opencode.nix
│   │   └── pi.nix
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
│   ├── herdr/
│   │   └── config.toml  # herdr（ターミナル常駐AIエージェントマルチプレクサ）設定
│   ├── hammerspoon/
│   │   └── init.lua     # Hammerspoon macOS 自動化
│   ├── lazygit/
│   │   ├── config.yml                 # lazygit 設定
│   │   ├── gen-commit-msg.sh          # コミットメッセージ自動生成スクリプト
│   │   └── prune-merged-branches.sh   # マージ済みブランチ削除スクリプト
│   ├── gwq/
│   │   └── config.toml  # gwq リポジトリ管理設定
│   ├── claude/
│   │   ├── settings.json  # Claude Code 設定
│   │   ├── statusline.py  # Claude Code ステータスライン
│   │   └── hooks/         # Claude Code フック
│   ├── codex/
│   │   ├── hooks.json             # Codex CLI フック設定
│   │   └── herdr-agent-state.sh   # herdr連携スクリプト
│   └── nix/
│       └── devshell.nix # Nix devshell テンプレート
├── scripts/             # 監視処理・設定マージ
├── tests/               # 判断ロジックの回帰テスト
├── Taskfile.yml         # 整形・検証・適用タスク
└── README.md            # このファイル
```

## 管理範囲

| 対象 | 管理方法 |
|---|---|
| 汎用CLI（ripgrep 等） | Home Manager（`packages.nix`） |
| 設定を持つCLI（lazygit 等） | Home Manager（対応する機能モジュール） |
| シェル・Git・Neovim 設定 | Home Manager（各モジュール） |
| Hammerspoon・gwq 等の dotfiles | Home Manager（`apps.nix`） |
| tmux・zellij・wezterm・herdr dotfiles | Home Manager（`terminal.nix`） |
| Claude/Codex/Copilot/OpenCode/Pi dotfiles | Home Manager（`ai/`） |
| Homebrew formulae / casks | nix-darwin（`darwin/homebrew.nix`） |
| macOS システム設定 | nix-darwin（`darwin/system.nix`） |
| 定期実行・プロセス監視 | nix-darwin（`darwin/services.nix`）と `scripts/process_watchdog.py` |

設定とパッケージ・専用ラッパーは同じ機能モジュールに置きます。
静的dotfilesは `home.file`、アプリが更新するファイルは管理対象部分だけを更新する処理を使います。
Copilotは所有するHerdrコマンドだけを差し替え、他のイベント・同じイベントの別フックを保持します。
OpenCodeは宣言した設定全体を生成するため、変更は `modules/ai/opencode.nix` に記述します。
APIキーは従来どおりGit管理外の `secrets.json` に置きます。

lazygit監視は15分ごとのCPU観測が30%以上のまま60分継続した場合に終了します。
観測間隔が30分を超えた場合・低CPU・プロセスの消滅やPID再利用では履歴をリセットします。
これは観測点での判定であり、その間のCPU使用率の連続測定ではありません。
履歴は `~/.local/state/process-watchdog/lazygit.json`、live-serverの終了条件は従来どおり起動後120分です。

### 変更の検証

新規ファイルを `git add` してから、`task check` で整形・静的解析・回帰テスト・両構成のビルドを実行します。
検証は設定を適用しません。個別には `task fmt`、`task lint`、`task test`、
`task build:home`、`task build:darwin` を使えます。
必要なツールは既存構成に含む `go-task`、`nixfmt`、`statix`、`python3`、`jq`、`zsh` です。
statixの `repeated_keys` は、用途ごとにドット区切りのオプションを記述する規約に合わせて無効にしています。

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

### Codex CLI の更新

Codex CLI は Home Manager の `modules/ai/codex.nix` だけで管理します。
公式の安定版パッケージをバージョンと SHA-256 で固定し、同梱の実行環境も保持します。
standalone インストーラー・npm・Homebrew での Codex CLI の追加インストールは行いません。
`~/.codex` の認証・設定・会話履歴・スキルは引き続き保持します。

`nix flake update` ではこの Codex のバージョンは更新されません。更新時は以下を実施します。

1. [公式の最新安定版](https://github.com/openai/codex/releases/latest) を確認する。
2. `modules/ai/codex.nix` の `codexRelease.version` と、
   `codex-package-{aarch64,x86_64}-apple-darwin.tar.gz` の各 SHA-256 を更新する。
   ハッシュは GitHub Releases API の各 asset の `digest` で確認できる。
3. `task check` で検証し、`task home`（Home Manager のみ）または `task darwin` で適用する。
4. 新しいターミナルで `type -a codex` と `codex --version` を確認する。

CLI の起動は Home Manager のラッパーを経由し、ステータスラインと hooks の設定を適用します。

## モジュールの拡張

### CLI パッケージの追加

`modules/packages.nix` の `home.packages` に追加:

```nix
home.packages = with pkgs; [
  newtool
];
```

### 個人用・会社用 Mac の使い分け

共通アプリは `modules/darwin/homebrew.nix`、個人用は `hosts/personal.nix`、
会社用は `hosts/work.nix` で管理します。TradingView は個人用にのみ含まれます。
ユーザー名・ホームディレクトリ・アーキテクチャは、どの構成でも `machine.nix` を参照します。

```bash
# 個人用 Mac: ビルド確認後に適用
task build:darwin PROFILE=personal
task darwin PROFILE=personal

# 会社用 Mac
task build:darwin PROFILE=work
task darwin PROFILE=work
```

Home Manager の共通設定は `home.nix`、会社用は `hosts/home-work.nix`、
個人用は `hosts/home-personal.nix` で管理します。現在は両方とも共通設定のみです。
Darwin への一括適用でも、選んだ構成と同じ Home Manager 設定が使われます。

```bash
# Home Manager のみ確認・適用（会社用がデフォルト）
task build:home
task home

# 個人用
task build:home PROFILE=personal
task home PROFILE=personal
```

`task home`・`task darwin` と各 `build:` タスクは、引数なしでは会社用の `work` を選びます。
既存の `.#y-tsuruoka` は共通設定のみです。
構成名にかかわらず、設定対象のユーザーは `machine.nix` のユーザー名です。
zsh ではリポジトリ直下で `task home `・`task darwin `・各 `build:` タスクの後に Tab を押すと、
`PROFILE=work` と `PROFILE=personal` を補完できます（`task home` で反映後、新しいシェルで有効）。
端末の自動判別はしないため、会社用 Mac では `personal` を指定しないでください。
個人用 Mac では毎回 `PROFILE=personal` を指定してください。共通・会社用構成へ
切り替えると、`cleanup = "uninstall"` により TradingView は削除対象になります。
`task home` は Homebrew アプリを変更しません。

### Homebrew cask の追加

`modules/darwin/homebrew.nix` の `homebrew.casks` に追加:

```nix
homebrew.casks = [
  "new-app"
];
```

### dotfiles の追加

`dotfiles/` に設定ファイルを配置し、該当カテゴリのモジュール（`terminal.nix`, `ai/<tool>.nix`, `apps.nix` 等）から参照:

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

`machine.nix` の `system` を確認（Darwinと単体Home Managerの両方に渡されます）:

- Apple Silicon (M1/M2/M3...): `aarch64-darwin`
- Intel Mac: `x86_64-darwin`

## 参考リンク

- [nix-darwin](https://github.com/lnl7/nix-darwin)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
