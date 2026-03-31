# HomeManager リポジトリ構造整理 設計書

**日付:** 2026-03-31  
**対象リポジトリ:** y-tsuruoka74/HomeManager

---

## 背景・目的

現状の `modules/files.nix` はすべての dotfile シンボリンクを一箇所で管理しており、ツールが増えるにつれて肥大化している。また `modules/neovim.nix` は `programs.neovim` の有効化のみ（4行）で、実際の Neovim dotfiles は `files.nix` で管理されており、モジュール間の一貫性がない。README の構成ツリーも実態と乖離している。

**目標:**
- `files.nix` を廃止し、カテゴリ別モジュールに分散する
- `programs.*` を持つツールは dotfiles も同一モジュールで管理し一貫性を確保する
- README を実際の構成に合わせて更新する

---

## アーキテクチャ

### モジュール構成（変更後）

```
modules/
├── darwin.nix      # nix-darwin システム設定・Homebrew 管理（変更なし）
├── packages.nix    # パッケージ管理（変更なし）
├── zsh.nix         # zsh・starship・zoxide・fzf・direnv 設定（変更なし）
├── git.nix         # Git 設定 + lazygit dotfiles（lazygit 追加）
├── editor.nix      # Neovim programs 設定 + nvim dotfiles（新規・neovim.nix 統合）
├── terminal.nix    # ターミナル dotfiles: tmux, zellij, wezterm（新規）
├── ai.nix          # AI ツール dotfiles: claude, claude-code-router（新規）
└── apps.nix        # その他アプリ dotfiles: hammerspoon, gwq（新規）
```

### 廃止するファイル

| ファイル | 理由 |
|---|---|
| `modules/files.nix` | カテゴリ別モジュールに分散するため廃止 |
| `modules/neovim.nix` | `editor.nix` に統合するため廃止 |

### `home.nix` imports（変更後）

```nix
imports = [
  ./modules/packages.nix
  ./modules/zsh.nix
  ./modules/git.nix
  ./modules/editor.nix
  ./modules/terminal.nix
  ./modules/ai.nix
  ./modules/apps.nix
];
```

---

## 各モジュールの内容

### `modules/editor.nix`（新規）

`programs.neovim`（旧 `neovim.nix`）と nvim dotfiles（旧 `files.nix`）を統合。

```nix
{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.file.".config/nvim" = {
    source = ./../dotfiles/nvim;
    recursive = true;
    force = true;
  };
}
```

### `modules/terminal.nix`（新規）

tmux, zellij, wezterm の dotfiles を管理。

```nix
{ ... }:
{
  home.file = {
    ".config/wezterm/wezterm.lua" = {
      source = ./../dotfiles/wezterm/wezterm.lua;
      force = true;
    };
    ".config/zellij/config.kdl" = {
      source = ./../dotfiles/zellij/config.kdl;
      force = true;
    };
    ".config/tmux/tmux.conf" = {
      source = ./../dotfiles/tmux/tmux.conf;
      force = true;
    };
  };
}
```

### `modules/ai.nix`（新規）

Claude Code と claude-code-router の設定ファイルを管理。

```nix
{ ... }:
{
  home.file = {
    ".claude/settings.json" = {
      source = ./../dotfiles/claude/settings.json;
      force = true;
    };
    ".claude/statusline.py" = {
      source = ./../dotfiles/claude/statusline.py;
      force = true;
    };
    ".claude-code-router/config.json" = {
      source = ./../dotfiles/ccr/config.json;
      force = true;
    };
  };
}
```

### `modules/apps.nix`（新規）

Hammerspoon と gwq の設定ファイルを管理。

```nix
{ ... }:
{
  home.file = {
    ".hammerspoon/init.lua" = {
      source = ./../dotfiles/hammerspoon/init.lua;
      force = true;
    };
    ".config/gwq/config.toml" = {
      source = ./../dotfiles/gwq/config.toml;
      force = true;
    };
  };
}
```

### `modules/git.nix`（変更）

既存の `programs.git` 設定に lazygit dotfiles を追加。

```nix
# 追加分のみ記載
home.file = {
  "Library/Application Support/lazygit/config.yml" = {
    source = ./../dotfiles/lazygit/config.yml;
    force = true;
  };
  "Library/Application Support/lazygit/gen-commit-msg.sh" = {
    source = ./../dotfiles/lazygit/gen-commit-msg.sh;
    force = true;
  };
};
```

---

## dotfiles ディレクトリ構成（変更なし）

dotfiles ディレクトリ自体の構造は変更しない。モジュール側の参照先のみ整理する。

```
dotfiles/
├── zsh/            # extra.zsh, prompt.zsh
├── nvim/           # init.lua, lua/
├── wezterm/        # wezterm.lua
├── tmux/           # tmux.conf
├── zellij/         # config.kdl
├── hammerspoon/    # init.lua
├── lazygit/        # config.yml, gen-commit-msg.sh
├── gwq/            # config.toml
├── claude/         # settings.json, statusline.py
├── ccr/            # config.json（claude-code-router）
└── nix/            # devshell.nix（devshell テンプレート）
```

---

## README 更新内容

- 構成ツリーを上記の新モジュール構成に更新
- dotfiles ディレクトリツリーに tmux, zellij, lazygit, ccr, claude を追加
- 管理範囲テーブルを更新（`neovim.nix` → `editor.nix`、`files.nix` 行を削除）

---

## 実装手順

1. `modules/editor.nix` を新規作成
2. `modules/terminal.nix` を新規作成
3. `modules/ai.nix` を新規作成
4. `modules/apps.nix` を新規作成
5. `modules/git.nix` に lazygit dotfiles を追加
6. `home.nix` の imports を更新
7. `modules/files.nix` を削除
8. `modules/neovim.nix` を削除
9. `README.md` を更新

---

## 考慮事項

- `force = true` は全 `home.file` エントリに統一して付与する（既存の管理外ファイルとの衝突を防ぐため）
- `darwin.nix`、`packages.nix`、`zsh.nix` は変更しない
- dotfiles ディレクトリ自体は移動・変更しない
