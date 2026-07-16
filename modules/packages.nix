{ config, pkgs, ... }:

let
  # ~/.codex/config.toml は Codex アプリ側でも更新されるため、ファイル全体を
  # Home Manager で管理せず、CLI 起動時にステータスラインだけを上書きする。
  codexWithUsage = pkgs.writeShellScriptBin "codex" ''
    exec ${pkgs.codex}/bin/codex \
      -c 'tui.status_line=["model-with-reasoning","current-dir","git-branch","context-remaining","five-hour-limit","weekly-limit","total-input-tokens","total-output-tokens"]' \
      "$@"
  '';
in
{
  home.packages = with pkgs; [
    # プログラム言語
    go_1_25

    # 基本的なツール
    htop
    jq
    bat
    curl
    wget
    tree

    # AI ツール
    claude-code         # Claude Code CLI
    ollama              # ローカル LLM ランナー
    github-copilot-cli  # GitHub Copilot CLI
    codexWithUsage      # OpenAI Codex CLI（モデル・コンテキスト・利用量を常時表示）

    # 開発ツール
    ripgrep      # 高速ファイル検索
    fd           # find の代替
    eza          # ls の代替
    bottom       # htop の代替（グラフ表示付き TUI）
    dust         # du の代替（ディスク使用量をツリー表示）
    nodejs
    yarn
    pnpm
    python314
    rustc
    cargo
    ruff         # Python linter/formatter
    uv
    pipx         # Python アプリケーションのインストール
    ansible      # 構成管理ツール
    opencode     # AI コーディングエージェント CLI

    # Kubernetes / インフラツール
    kubernetes-helm  # helm
    kind             # Kubernetes in Docker
    kubectl
    terraform
    # kdash        # ハッシュ不一致のため一時無効化（flake update 後に復活）

    # データベース
    mariadb-connector-c  # MySQL/MariaDB クライアントライブラリ
    mysql84              # MySQL 8.4 クライアント

    # Lua
    luarocks     # Lua パッケージマネージャ

    # Git 関連
    ghq          # リポジトリ管理
    gwq          # Git worktree 管理（fuzzy finder 付き）
    gh           # GitHub CLI
    lazygit      # Git ターミナル UI
    lazydocker   # Docker ターミナル UI

    # その他 CLI ツール
    peco         # 対話的フィルタリングツール
    zellij       # ターミナルセッションマネージャ
    tree-sitter  # パーサージェネレーター
    go-task      # タスクランナー (task)
    pkgconf      # パッケージ設定ツール
    tectonic     # Modern LaTeX

    # システムユーティリティ
    coreutils
    findutils
    gnugrep
    gnutar

    # HTTP ツール
    xh          # HTTP クライアント
    hey         # HTTP ベンチマークツール

    # その他
    crush              # Glamourous AI coding agent
    usacloud            # さくらクラウド CLI
    _1password-cli      # 1Password CLI

    # 注: 以下のパッケージは Homebrew で管理:
    #   - fluent-bit - nixpkgs の aarch64-darwin ビルドが壊れているため
  ];
}
