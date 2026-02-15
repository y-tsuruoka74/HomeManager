# Agents Documentation

このリポジトリで作業するエージェントのためのドキュメント。

## プロジェクト概要

Home Manager を使用して dotfiles を管理するリポジトリ。Nix Flake ベースの構成で、Home Manager を通じてシェル設定、アプリケーション設定、パッケージ管理などを宣言的に管理します。

## 重要コマンド

### 設定の適用

```bash
# Home Manager 設定を適用
home-manager switch --flake .#$(whoami)
```

### 設定の更新

```bash
# Flake ロックファイルを更新
nix flake update

# 設定を再適用
home-manager switch --flake .#$(whoami)
```

### 設定の確認

```bash
# ドライランで変更内容を確認（実際には適用しない）
home-manager switch --flake .#$(whoami) --dry-run
```

### トラブルシューティング

```bash
# Home Manager ログを確認
cat ~/.local/state/home-manager/home-manager.log
```

## プロジェクト構造

```
.
├── flake.nix     # Nix Flake 設定 - Home Manager と Nixpkgs の入力を定義
├── home.nix      # Home Manager 設定 - 主な設定はここに記述
└── README.md     # プロジェクト説明
```

## コード規約

### Nix 設定のスタイル

- インデントは 2 スペース
- 一貫性を保つため、`{ config, pkgs, ... }:` パターンを使用
- 設定項目はカテゴリごとにグループ化してコメントを挿入

### home.nix の構成

1. **基本情報**: `home.username`, `home.homeDirectory`
2. **パッケージ**: `home.packages`
3. **ファイル管理**: `home.file`
4. **プログラム設定**: `programs.*`

## Nix Flakes の注意点

### Git 追跡必須

Nix は Git で追跡されていないファイルを Flakes として扱いません。新しい設定ファイルを作成した際は必ず先に Git に追加してください:

```bash
git add flake.nix home.nix
git commit -m "Commit message"
```

### System 設定

`flake.nix` の `system` は実行環境に合わせて変更が必要:

- Apple Silicon (M1/M2/M3...): `aarch64-darwin`
- Intel Mac: `x86_64-darwin`
- Linux (x86-64): `x86_64-linux`

## Dotfiles 管理のパターン

### 方法 A: 直接テキストを挿入

簡単な設定ファイルに適した方法:

```nix
home.file.".zshrc".text = ''
  export PATH="$HOME/.local/bin:$PATH"
'';
```

### 方法 B: 外部ファイルを参照

複雑な設定や既存の設定ファイルを使用する場合:

```nix
home.file.".config/nvim/init.lua".source = ./config/nvim/init.lua;
```

### 方法 C: Home Manager プログラムモジュール

Home Manager が提供する設定モジュールを使用:

```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your@email.com";
};
```

**推奨**: Home Manager が提供するモジュールがあれば優先的に使用。設定できる項目は [Home Manager Options](https://nix-community.github.io/home-manager/options.html) を参照。

## 変更の適用手順

1. 設定を `home.nix` または `flake.nix` に追加
2. Git に変更を追加: `git add .`
3. 設定を適用: `home-manager switch --flake .#$(whoami)`
4. 動作を確認
5. 必要に応じてコミット

## 一般的なエラーと解決策

### "Path is not tracked by Git"

新しいファイルを作成した場合、先に Git に追加する必要があります。

### 設定が反映されない

- `home.username` が現在のユーザー名と一致しているか確認
- システム設定が正しいか確認 (`aarch64-darwin` など)
- ログを確認: `cat ~/.local/state/home-manager/home-manager.log`

## 関連リソース

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)