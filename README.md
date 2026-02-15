# Home Manager Configuration

Home Manager を用いて dotfiles を管理するリポジトリです。

## 前提条件

- Nix がインストールされていること（[Nix Install](https://nixos.org/download.html)）
- Git がインストールされていること

## 構成

```
.
├── flake.nix            # Nix Flake 設定
├── home.nix             # Home Manager メイン設定
├── modules/             # Home Manager モジュール
│   ├── packages.nix     # パッケージ管理
│   ├── zsh.nix          # zsh 設定
│   ├── git.nix          # Git 設定
│   ├── neovim.nix       # Neovim プログラム設定
│   └── files.nix        # ファイル管理（home.file.*）
├── dotfiles/            # 生の dotfiles
│   ├── zsh/
│   │   ├── extra.zsh    # 追加の zsh 設定
│   │   └── prompt.zsh   # プロンプト設定
│   ├── git/
│   │   └── gitconfig    # Git 設定ファイル
│   ├── nvim/
│   │   ├── init.lua     # Neovim メイン設定
│   │   └── lua/         # Lua モジュール
│   ├── wezterm/
│   │   └── wezterm.lua  # wezterm 設定
│   ├── nix/
│   │   ├── devshell.nix    # Nix devshell テンプレート
│   │   └── VERSION_MANAGEMENT.md  # バージョン管理ドキュメント
│   └── homebrew/
│       └── Brewfile        # Homebrew に残すパッケージ
└── README.md            # このファイル
```

## 初期セットアップ

Home Manager を初めて使用する場合:

```bash
# インストール（bash）
nix run home-manager/master -- init --switch

# または（zsh）
nix run home-manager/master -- init --switch
```

## 使い方

### 1. 設定の適用

```bash
# 設定を適用
home-manager switch --flake .#y-tsuruoka

# home-manager コマンドが見つからない場合
nix run github:nix-community/home-manager -- switch --flake .#y-tsuruoka
```

### 2. 設定の更新

```bash
# Flake ロックを更新
nix flake update

# 設定を再適用
home-manager switch --flake .#y-tsuruoka
```

### 3. モジュールと dotfiles の管理

このリポジトリではモジュール化と生の dotfiles を組み合わせて管理しています。

#### アプリ別モジュールの追加

1. `modules/` に新しい `<app>.nix` ファイルを作成
2. `home.nix` の `imports` に追加

```nix
# home.nix
imports = [
  ./modules/packages.nix
  ./modules/zsh.nix
  ./modules/git.nix
  ./modules/neovim.nix
  ./modules/<app>.nix  # 追加
];
```

#### 生の dotfiles の追加

`dotfiles/` に設定ファイルを配置し、モジュールから参照:

```nix
# modules/<app>.nix
home.file.".config/<app>/config.yml".source = ./../dotfiles/app/config.yml;
# またはディレクトリ全体
home.file.".config/<app>".source = ./../dotfiles/app;
```

#### 設定方法の選択

- **Home Manager モジュールが提供されるもの** → `programs.*` を使用（例: `programs.git`）
- **Nix 化が容易な設定** → `home.file."..."` で直接記述
- **複雑な設定や既存のファイル** → `home.file."..."` で外部ファイルを参照

### 4. パッケージの追加

`modules/packages.nix` の `home.packages` に追加:

```nix
home.packages = with pkgs; [
  # パッケージをここに追加
  neovim
  git
  htop
  # ...
];
```

## 主な設定項目

### システム設定を変更前に確認

現在の設定から変更される内容を確認:

```bash
home-manager switch --flake .#y-tsuruoka --dry-run
```

### ログの確認

```bash
# Home Manager ログ
cat ~/.local/state/home-manager/home-manager.log
```

## トラブルシューティング

### システム設定を確認

システムアーキテクチャに合わせて `flake.nix` の `system` を確認:

- Apple Silicon (M1/M2/M3...): `aarch64-darwin`
- Intel Mac: `x86_64-darwin`
- Linux (x86-64): `x86_64-linux`

### ユーザー名の設定

`home.nix` と `flake.nix` でユーザー名が一致しているか確認:

```bash
# 現在のユーザー名を確認
whoami
```

## Homebrew からの移行

Home Manager は Homebrew と異なり、**ユーザー環境のみ**を管理します。以下の使い分けを推奨:

**Home Manager で管理:**
- CLI ツール（fzf, ripgrep, ghq, lazygit など）
- 開発ツール（Neovim, mise など）
- シェル設定（zsh, Starship など）

**Homebrew に残す:**
- GUI アプリ
- macOS 固有のシステムツール
- 依存関係が複雑なツール

### Homebrew パッケージの移行

現在 Homebrew でインストールされているパッケージを確認:

```bash
brew list --formula
brew list --cask
```

### 移行手順例

Homebrew → Home Manager へ移行する例:

```bash
# Homebrew で管理されていたパッケージを削除
brew uninstall fzf ripgrep neovim ghq lazygit

# Home Manager 設定を適用
home-manager switch --flake .#y-tsuruoka
```

### 移行したパッケージ一例

この設定では以下の Homebrew パッケージを Home Manager に移行済み:

| Homebrew | Home Manager |
|----------|--------------|
| fzf      | fzf          |
| ripgrep  | ripgrep      |
| neovim   | neovim       |
| ghq      | ghq          |
| lazygit  | lazygit      |
| lazydocker | lazydocker |
| lsd      | eza          |
| zellij   | zellij       |
| mise     | mise （Nix devshell でも代用可） |

## バージョン管理

**mise** と **Nix devshell** のどちらを使うか選択できます。

### mise を使う（既存の anyenv/asdf ワークフロー）

```bash
# modules/packages.nix でmiseのコメントを外す
# modules/zsh.nix でmise初期化のコメントを外す

# 言語のインストール
mise install node@lts
mise use -g node@lts
```

**メリット:**
- 既存のワークフローに近い
- グローバルバージョン管理が簡単

### Nix devshell を使う（Nix ネイティブ）

`dotfiles/nix/VERSION_MANAGEMENT.md` に詳細があります。

```bash
# プロジェクトの flake.nix で開発環境を定義
cd ~/my-project
nix develop

# または direnv と組み合わせる（.envrc: "use flake"）
```

**メリット:**
- 完全に宣言的で再現性が高い
- プロジェクト環境の分離が確実

**推奨:**
- 新規ユーザー: mise から開始
- Nix に慣れている: Nix devshell で一元管理
- 混合: 既存プロジェクトは mise、新しいプロジェクトは Nix devshell

### anyenv/asdf → mise → Nix devshell への移行

```bash
# 昔の anyenv/asdf の設定例（dotfiles/zsh/extra.zsh から削除済み）
# export PATH="$HOME/.anyenv/bin:$PATH"
# eval "$(anyenv init - zsh)"
```

## 参考リンク

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)