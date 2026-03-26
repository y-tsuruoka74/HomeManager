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

    # 開発ツール
    ripgrep      # 高速ファイル検索
    eza          # ls の代替
    nodejs
    uv
    ansible      # 構成管理ツール
    mise         # バージョン管理（programs.mise で shell 統合）

    # Kubernetes ツール
    kdash        # Kubernetes ダッシュボード TUI

    # データベース
    mariadb-connector-c  # MySQL/MariaDB クライアントライブラリ
    mysql80              # MySQL 8.0 クライアント

    # Lua
    luarocks     # Lua パッケージマネージャ

    # Git 関連
    ghq          # リポジトリ管理
    lazygit      # Git ターミナル UI
    lazydocker   # Docker ターミナル UI

    # その他 CLI ツール
    peco         # 対話的フィルタリングツール
    tmux         # ターミナルマルチプレクサ
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

    # 注: 以下のパッケージは Homebrew で管理:
    #   - gwq        (d-kuro/tap) - nixpkgs 未対応
    #   - borders    (felixkratz/formulae) - macOS ウィンドウボーダー、nixpkgs 未対応
    #   - usacloud   (sacloud/usacloud) - さくらクラウド CLI、nixpkgs 未対応
    #   - crush      (charmbracelet/tap) - nixpkgs 未対応
    #   - fluent-bit - nixpkgs の aarch64-darwin ビルドが壊れているため
  ];
}
