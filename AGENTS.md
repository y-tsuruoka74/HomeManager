# Agents Documentation

このリポジトリで作業するエージェントのためのドキュメント。

## プロジェクト概要

Home Manager を使用して dotfiles を管理するリポジトリ。Nix Flake ベースの構成で、Home Manager を通じてシェル設定、アプリケーション設定、パッケージ管理などを宣言的に管理します。

## 重要コマンド

### 設定の適用

```bash
# Home Manager 設定を適用（y-tsuruoka は固定ユーザー名）
home-manager switch --flake .#y-tsuruoka
```

### 設定の更新

```bash
# Flake ロックファイルを更新
nix flake update

# 設定を再適用
home-manager switch --flake .#y-tsuruoka
```

### 設定の確認

```bash
# ドライランで変更内容を確認（実際には適用しない）
home-manager switch --flake .#y-tsuruoka --dry-run
```

### トラブルシューティング

```bash
# Home Manager ログを確認
cat ~/.local/state/home-manager/home-manager.log
```

## プロジェクト構造

```
.
├── flake.nix            # Nix Flake 設定
├── home.nix             # Home Manager メイン設定
├── modules/             # Home Manager モジュール
│   ├── packages.nix     # パッケージ管理
│   ├── zsh.nix          # zsh 設定
│   ├── git.nix          # Git 設定
│   ├── neovim.nix       # Neovim 設定
│   └── files.nix        # ファイル管理（home.file.*）
├── dotfiles/            # 生の dotfiles
│   ├── zsh/
│   │   ├── extra.zsh
│   │   └── prompt.zsh
│   ├── git/
│   │   └── gitconfig
│   ├── nvim/
│   │   ├── init.lua
│   │   └── lua/
│   ├── nix/
│   │   ├── devshell.nix
│   │   └── VERSION_MANAGEMENT.md
│   └── homebrew/
│       └── Brewfile
├── AGENTS.md            # このファイル
└── README.md            # プロジェクト説明
```

## コード規約

### Nix 設定のスタイル

- インデントは 2 スペース
- 一貫性を保つため、`{ config, pkgs, ... }:` パターンを使用
- 設定項目はカテゴリごとにグループ化してコメントを挿入

### モジュール構成

- **home.nix**: 基本設定と imports のみを記述
- **modules/**: 設定を機能別に分割
- **dotfiles/**: Home Manager モジュール化が難しい設定や複雑な設定ファイル

## Nix Flakes の注意点

### Git 追跡必須

Nix は Git で追跡されていないファイルを Flakes として扱いません。新しい設定ファイルを作成した際は必ず先に Git に追加してください:

```bash
git add flake.nix home.nix modules/ dotfiles/
git commit -m "Commit message"
```

### System 設定

`flake.nix` の `system` は実行環境に合わせて変更が必要:

- Apple Silicon (M1/M2/M3...): `aarch64-darwin`
- Intel Mac: `x86_64-darwin`
- Linux (x86-64): `x86_64-linux`

### ユーザー名設定

`home.nix` と `flake.nix` でユーザー名が一致しているか確認:

```bash
whoami  # y-tsuruoka
```

## Dotfiles 管理のパターン

### 方法 A: Home Manager プログラムモジュール（推奨）

Home Manager が提供する設定モジュールを使用:

```nix
# modules/git.nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your@email.com";
};
```

### 方法 B: 外部ファイルを参照

`dotfiles/` に配置した外部ファイルをシンボリックリンク:

```nix
# modules/neovim.nix
home.file.".config/nvim".source = ./../dotfiles/nvim;
```

**注意**: `modules/` から `dotfiles/` を参照する場合、相対パス `./../dotfiles/` を使用

### 方法 C: 直接テキストを挿入

簡単な設定ファイルに適した方法:

```nix
home.file.".zshrc".text = ''
  export PATH="$HOME/.local/bin:$PATH"
'';
```

**推奨順位**:
1. Home Manager モジュールが存在 → `programs.*` を使用
2. Nix 化が容易 → `home.file."..."` で直接記述
3. 複雑な設定や既存のファイル → `home.file."..."` で外部ファイルを参照

## モジュールの追加手順

新しいアプリの設定を追加する場合:

1. `modules/<app>.nix` を作成
2. 必要に応じて `dotfiles/<app>/` に設定ファイルを配置
3. `home.nix` の `imports` に追加:

```nix
 imports = [
   ./modules/packages.nix
   ./modules/zsh.nix
   ./modules/git.nix
   ./modules/neovim.nix
   ./modules/<app>.nix  # 追加
 ];
```

4. Git に追加してコミット:
```bash
git add modules/<app>.nix dotfiles/<app>/ home.nix
git commit -m "Add <app> module"
```

5. 設定を適用:
```bash
home-manager switch --flake .#y-tsuruoka
```

## 変更の適用手順

1. 設定を `modules/`, `dotfiles/`, `home.nix`, `flake.nix` のいずれかに追加/変更
2. Git に変更を追加: `git add .`
3. 設定を適用: `home-manager switch --flake .#y-tsuruoka`
4. 動作を確認
5. 必要に応じてコミット

## 一般的なエラーと解決策

### "Path is not tracked by Git"

新しいファイルを作成した場合、先に Git に追加する必要があります。

### 設定が反映されない

- `home.username` が `y-tsuruoka` であるか確認
- `flake.nix` の `homeConfigurations."y-tsuruoka"` と一致しているか確認
- システム設定が正しいか確認 (`aarch64-darwin` など)
- モジュールの imports に追加したか確認
- ログを確認: `cat ~/.local/state/home-manager/home-manager.log`

## 関連リソース

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)