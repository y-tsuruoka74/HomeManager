{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # 基本的なツール
    git
    htop
    jq
    bat
    curl
    wget

    # 開発ツール
    fzf          # 対話的フィルタリングツール
    ripgrep      # 高速ファイル検索
    eza          # ls の代替
    zoxide       # cd の代替（スマートなディレクトリ移動）

    # Git 関連
    ghq          # リポジトリ管理
    lazygit      # Git ターミナル UI
    lazydocker   # Docker ターミナル UI

    # その他 CLI ツール
    lsd          # ls の代替（アイコン付き）
    peco         # 対話的フィルタリングツール
    zellij       # ターミナルセッションマネージャ
    tree-sitter  # パーサージェネレーター
    direnv       # 環境変数管理
    go-task      # タスクランナー (task)
    # mise         # バージョン管理（Nix devshell で代替可能: dotfiles/nix/VERSION_MANAGEMENT.md 参照）
    tectonic     # Modern LaTeX

    # システムユーティリティ
    coreutils
    findutils
    gnugrep
    gnutar

    # HTTP ツール
    xh          # HTTP クライアント
    hey         # HTTP ベンチマークツール

    # TUI / ターミナルツール
    crush       # 人気ツール収集・発見
    borders     # macOS ウィンドウ枠可視化
    kdash       # Kubernetes TUI 管理ツール

    # GitHub 拡張
    gwq         # GitHub CLI 拡張（ワークフロー改善）

    # データベース
    mysql       # MySQL クライアント
  ];
}