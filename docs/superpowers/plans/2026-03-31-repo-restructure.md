# HomeManager リポジトリ構造整理 実装プラン

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `modules/files.nix` と `modules/neovim.nix` を廃止し、カテゴリ別モジュール（editor/terminal/ai/apps）に再編して一貫性を確保し、README を実態に合わせて更新する。

**Architecture:** `files.nix` に集約されていたすべての `home.file` 設定をカテゴリ別モジュールに分散する。`programs.neovim` は新設する `editor.nix` に移動し、同ファイルで nvim dotfiles も管理する。`git.nix` には lazygit dotfiles を追加する。

**Tech Stack:** Nix Flakes, nix-darwin, Home Manager

---

## ファイルマップ

| 操作 | パス | 内容 |
|---|---|---|
| 新規作成 | `modules/editor.nix` | `programs.neovim` + nvim dotfiles |
| 新規作成 | `modules/terminal.nix` | tmux, zellij, wezterm dotfiles |
| 新規作成 | `modules/ai.nix` | claude, ccr dotfiles |
| 新規作成 | `modules/apps.nix` | hammerspoon, gwq dotfiles |
| 変更 | `modules/git.nix` | lazygit dotfiles を追加 |
| 変更 | `home.nix` | imports を更新 |
| 削除 | `modules/files.nix` | カテゴリ別モジュールに分散済み |
| 削除 | `modules/neovim.nix` | editor.nix に統合済み |
| 変更 | `README.md` | 構成ツリーと管理範囲テーブルを更新 |

---

## Task 1: editor.nix を作成する

**Files:**
- Create: `modules/editor.nix`

- [ ] **Step 1: `modules/editor.nix` を作成する**

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

- [ ] **Step 2: flake の構文チェックを実行する**

```bash
nix flake check
```

Expected: エラーなし（この時点では home.nix がまだ editor.nix を import していないので警告のみ）

- [ ] **Step 3: コミットする**

```bash
git add modules/editor.nix
git commit -m "feat: editor.nix を追加（programs.neovim + nvim dotfiles）"
```

---

## Task 2: terminal.nix を作成する

**Files:**
- Create: `modules/terminal.nix`

- [ ] **Step 1: `modules/terminal.nix` を作成する**

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

- [ ] **Step 2: コミットする**

```bash
git add modules/terminal.nix
git commit -m "feat: terminal.nix を追加（tmux, zellij, wezterm dotfiles）"
```

---

## Task 3: ai.nix を作成する

**Files:**
- Create: `modules/ai.nix`

- [ ] **Step 1: `modules/ai.nix` を作成する**

superpowers（Claude Code プラグイン）は `pkgs.fetchFromGitHub` で取得するため、`pkgs` を引数に含める。

```nix
{ pkgs, ... }:

let
  superpowersSrc = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v5.0.6";
    hash = "sha256-r/Z+UxSFQIx99HnSPoU/toWMddXDcnLsbFXpQfLfj1k=";
  };
in
{
  home.file = {
    # superpowers Claude Code プラグイン
    ".claude/plugins/superpowers" = {
      source = superpowersSrc;
      recursive = true;
    };

    # superpowers スキル
    ".claude/skills" = {
      source = "${superpowersSrc}/skills";
      recursive = true;
    };

    # Claude Code 設定
    ".claude/settings.json" = {
      source = ./../dotfiles/claude/settings.json;
      force = true;
    };
    ".claude/statusline.py" = {
      source = ./../dotfiles/claude/statusline.py;
      force = true;
    };

    # claude-code-router 設定
    ".claude-code-router/config.json" = {
      source = ./../dotfiles/ccr/config.json;
      force = true;
    };
  };
}
```

- [ ] **Step 2: コミットする**

```bash
git add modules/ai.nix
git commit -m "feat: ai.nix を追加（superpowers, claude, claude-code-router dotfiles）"
```

---

## Task 4: apps.nix を作成する

**Files:**
- Create: `modules/apps.nix`

- [ ] **Step 1: `modules/apps.nix` を作成する**

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

- [ ] **Step 2: コミットする**

```bash
git add modules/apps.nix
git commit -m "feat: apps.nix を追加（hammerspoon, gwq dotfiles）"
```

---

## Task 5: git.nix に lazygit dotfiles を追加する

**Files:**
- Modify: `modules/git.nix`

- [ ] **Step 1: `modules/git.nix` の現在の内容を確認する**

```bash
cat modules/git.nix
```

Expected: `programs.git { ... }` ブロックのみ存在する。

- [ ] **Step 2: `modules/git.nix` に lazygit dotfiles を追加する**

ファイル末尾の `}` の前に以下を追加する（`programs.git { ... }` ブロックの後）：

```nix
{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Yuki Tsuruoka";
        email = "y-tsuruoka@sakura.ad.jp";
      };
      init.defaultBranch = "main";
      core.editor = "nvim";
      ghq.root = "~/Github";
      push.autoSetupRemote = true;
      pull.rebase = false;
      merge.conflictstyle = "zdiff3";
    };
    includes = [
      {
        condition = "gitdir:~/work/";
        path = "~/.gitconfig.work";
      }
    ];
  };

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
}
```

- [ ] **Step 3: コミットする**

```bash
git add modules/git.nix
git commit -m "feat: git.nix に lazygit dotfiles を追加"
```

---

## Task 6: home.nix を更新し、files.nix と neovim.nix を削除する

**Files:**
- Modify: `home.nix`
- Delete: `modules/files.nix`
- Delete: `modules/neovim.nix`

- [ ] **Step 1: `home.nix` の imports を更新する**

`home.nix` を以下の内容に置き換える：

```nix
{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "y-tsuruoka";
  home.homeDirectory = "/Users/y-tsuruoka";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.05";

  # モジュール設定の読み込み
  imports = [
    ./modules/packages.nix
    ./modules/zsh.nix
    ./modules/git.nix
    ./modules/editor.nix
    ./modules/terminal.nix
    ./modules/ai.nix
    ./modules/apps.nix
  ];
}
```

- [ ] **Step 2: `modules/files.nix` と `modules/neovim.nix` を削除する**

```bash
git rm modules/files.nix modules/neovim.nix
```

Expected: 2ファイルが削除される。

- [ ] **Step 3: flake の構文チェックを実行する**

```bash
nix flake check
```

Expected: エラーなし。

- [ ] **Step 4: コミットする**

```bash
git add home.nix
git commit -m "refactor: home.nix を更新し、files.nix と neovim.nix を廃止"
```

---

## Task 7: README.md を更新する

**Files:**
- Modify: `README.md`

- [ ] **Step 1: README.md の構成セクションを更新する**

README.md の `## 構成` セクション内のコードブロックを以下に置き換える：

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

- [ ] **Step 2: 管理範囲テーブルを更新する**

README.md の `## 管理範囲` テーブルを以下に置き換える：

```markdown
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
```

- [ ] **Step 3: コミットする**

```bash
git add README.md
git commit -m "docs: README を新モジュール構成に合わせて更新"
```

---

## 最終確認

- [ ] **全タスク完了後、`nix flake check` を実行してエラーがないことを確認する**

```bash
nix flake check
```

Expected: エラーなし。

- [ ] **（任意）設定を実際に適用してみる**

```bash
darwin-rebuild switch --flake .#y-tsuruoka
```

Expected: すべての dotfiles が正しくシンボリンクされ、エラーなく完了する。
