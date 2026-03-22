# Agents Documentation

このリポジトリで作業するエージェントのためのドキュメント。

## プロジェクト概要

nix-darwin + Home Manager で macOS 環境全体を宣言的に管理するリポジトリ。
CLI パッケージ、dotfiles、Homebrew、macOS システム設定をすべて一元管理する。

## 重要コマンド

### 設定の適用

```bash
# nix-darwin + Home Manager 設定を一括適用
darwin-rebuild switch --flake .#y-tsuruoka
```

### 設定の確認（ドライラン）

```bash
darwin-rebuild build --flake .#y-tsuruoka
```

### Flake ロックの更新

```bash
nix flake update
darwin-rebuild switch --flake .#y-tsuruoka
```

### トラブルシューティング

```bash
# Home Manager ログを確認
cat ~/.local/state/home-manager/home-manager.log
```

## プロジェクト構造

```
.
├── flake.nix            # Nix Flake 設定（nix-darwin + home-manager）
├── home.nix             # Home Manager メイン設定
├── modules/             # モジュール
│   ├── darwin.nix       # nix-darwin システム設定・Homebrew 管理
│   ├── packages.nix     # パッケージ管理
│   ├── zsh.nix          # zsh 設定（starship, fzf, zoxide, direnv 統合）
│   ├── git.nix          # Git 設定
│   ├── neovim.nix       # Neovim プログラム設定
│   └── files.nix        # ファイル管理（home.file.*）
├── dotfiles/            # 生の dotfiles
│   ├── zsh/
│   │   ├── extra.zsh    # エイリアス・関数・環境変数
│   │   └── prompt.zsh   # プロンプト設定
│   ├── nvim/
│   │   ├── init.lua
│   │   └── lua/
│   ├── wezterm/
│   │   └── wezterm.lua
│   ├── hammerspoon/
│   │   └── init.lua     # Hammerspoon macOS 自動化
│   ├── gwq/
│   │   └── config.toml  # gwq リポジトリ管理設定
│   └── nix/
│       └── devshell.nix
├── AGENTS.md            # このファイル
└── README.md            # プロジェクト説明
```

## コード規約

### Nix 設定のスタイル

- インデントは 2 スペース
- `{ config, pkgs, ... }:` パターンを使用
- 設定項目はカテゴリごとにグループ化してコメントを挿入

### モジュール構成

- **home.nix**: 基本設定と imports のみ
- **modules/darwin.nix**: nix-darwin システム設定・Homebrew 管理
- **modules/**: 設定を機能別に分割
- **dotfiles/**: Home Manager モジュール化が難しい設定や複雑な設定ファイル

## Nix Flakes の注意点

### Git 追跡必須

Nix Flakes は Git で追跡されていないファイルを認識しません。新しいファイルを作成したら必ず先に追加:

```bash
git add <新しいファイル>
```

### アーキテクチャ設定

`flake.nix` と `darwin.nix` の `system` / `nixpkgs.hostPlatform` を環境に合わせる:

- Apple Silicon (M1/M2/M3...): `aarch64-darwin`
- Intel Mac: `x86_64-darwin`

## Dotfiles 管理のパターン

### 方法 A: Home Manager プログラムモジュール（推奨）

```nix
# modules/git.nix
programs.git = {
  enable = true;
  userName = "Your Name";
};
```

### 方法 B: 外部ファイルを参照

```nix
# modules/files.nix
home.file.".config/nvim" = {
  source = ./../dotfiles/nvim;
  recursive = true;
  force = true;
};
```

**注意**: `modules/` から `dotfiles/` を参照する場合、相対パス `./../dotfiles/` を使用。

### 方法 C: 直接テキストを挿入

```nix
home.file.".config/app/config".text = ''
  key = value
'';
```

**推奨順位**:
1. Home Manager モジュールが存在 → `programs.*` を使用
2. シンプルな設定 → `home.file."..."` で直接記述
3. 複雑な設定や既存ファイル → `home.file."..."` で外部ファイルを参照

## モジュールの追加手順

1. 必要に応じて `modules/<app>.nix` を作成
2. 必要に応じて `dotfiles/<app>/` に設定ファイルを配置
3. `home.nix` の `imports` に追加:

```nix
imports = [
  ./modules/packages.nix
  ./modules/<app>.nix  # 追加
];
```

4. Git に追加:

```bash
git add modules/<app>.nix dotfiles/<app>/
```

5. 設定を適用:

```bash
darwin-rebuild switch --flake .#y-tsuruoka
```

## 変更の適用手順

1. `modules/`, `dotfiles/`, `home.nix`, `flake.nix` のいずれかを変更
2. 新規ファイルは Git に追加: `git add <file>`
3. 設定を適用: `darwin-rebuild switch --flake .#y-tsuruoka`
4. 動作を確認してコミット

## 一般的なエラーと解決策

### "Path is not tracked by Git"

新しいファイルを `git add` する前に `darwin-rebuild switch` を実行した場合。先に追加が必要。

### 設定が反映されない

- `home.username` が `y-tsuruoka` か確認
- `flake.nix` の `homeConfigurations."y-tsuruoka"` と一致しているか確認
- `nixpkgs.hostPlatform` が `aarch64-darwin` か確認
- `home.nix` の `imports` にモジュールが追加されているか確認
- ログ確認: `cat ~/.local/state/home-manager/home-manager.log`

## 関連リソース

- [nix-darwin](https://github.com/lnl7/nix-darwin)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)
