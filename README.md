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
│   ├── ai.nix           # AI ツール dotfiles（claude, claude-code-router）
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
│   ├── ccr/
│   │   └── config.json  # claude-code-router 設定
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
| Claude・ccr dotfiles | Home Manager（`ai.nix`） |
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

**mise** と **Nix devshell** を使い分けられます。

### mise（グローバル管理）

```bash
mise install node@lts
mise use -g node@lts
```

### Nix devshell（プロジェクト単位）

direnv と組み合わせることでプロジェクトに入ると自動で環境が切り替わります:

```bash
echo "use flake" > .envrc
direnv allow
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
