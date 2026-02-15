# Home Manager Configuration

Home Manager を用いて dotfiles を管理するリポジトリです。

## 前提条件

- Nix がインストールされていること（[Nix Install](https://nixos.org/download.html)）
- Git がインストールされていること

## 構成

```
.
├── flake.nix     # Nix Flake 設定
├── home.nix      # Home Manager 設定
└── README.md     # このファイル
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
home-manager switch

# Flake を使用して適用
home-manager switch --flake .#$(whoami)
```

### 2. 設定の更新

```bash
# Flake ロックを更新
nix flake update

# 設定を再適用
home-manager switch --flake .#$(whoami)
```

### 3. dotfiles の追加

以下の方法で dotfiles を管理できます:

#### 方法 A: `home.file` で直接記述

```nix
home.file.".config/example/config.yml".text = ''
  setting1 = value
  setting2 = value
'';
```

#### 方法 B: 外部ファイルをシンボリックリンク

```nix
home.file.".config/example/config.yml".source = ./config/example/config.yml;
```

#### 方法 C: プログラム設定を使用

```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your@email.com";
};
```

### 4. パッケージの追加

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
home-manager switch --flake .#$(whoami) --dry-run
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

### Git 追跡前に Flake を初期化

flake.nix を作成したら、先に Git に追加してください:

```bash
git add flake.nix home.nix
git commit -m "Initial Home Manager configuration"
nix flake update
```

## 参考リンク

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)