{ config, pkgs, ... }:

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
    claude-code-router  # Claude Code リクエストを複数モデルにルーティング
    ollama              # ローカル LLM ランナー
    github-copilot-cli  # GitHub Copilot CLI

    # 開発ツール
    ripgrep      # 高速ファイル検索
    eza          # ls の代替
    nodejs
    uv
    ansible      # 構成管理ツール
    mise         # バージョン管理（programs.mise で shell 統合）

    # Kubernetes ツール
    # kdash        # ハッシュ不一致のため一時無効化（flake update 後に復活）

    # データベース
    mariadb-connector-c  # MySQL/MariaDB クライアントライブラリ
    mysql84              # MySQL 8.4 クライアント

    # Lua
    luarocks     # Lua パッケージマネージャ

    # Git 関連
    ghq          # リポジトリ管理
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
