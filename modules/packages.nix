{
  pkgs,
  inputs,
  ...
}:

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

    # 環境管理
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default # `task home` 用のCLI

    # AI ツール
    ollama # ローカル LLM ランナー
    graphify # コード/ドキュメントをナレッジグラフ化する AI コーディングスキル
    llmfit # 手元のRAM/CPU/GPUに合うローカルLLMモデルを判定するTUI/CLI
    hunk # AIエージェントが生成した変更をレビューするターミナル差分ビューアー

    # 開発ツール
    ripgrep # 高速ファイル検索
    fd # find の代替
    eza # ls の代替
    bottom # htop の代替（グラフ表示付き TUI）
    dust # du の代替（ディスク使用量をツリー表示）
    nodejs
    yarn
    pnpm
    python314
    rustc
    cargo
    clippy # cargo clippy
    rust-analyzer # Rust language server（nvim rustaceanvim用）
    rustfmt # Rust formatter（cargo fmt）
    ruff # Python linter/formatter
    uv
    pipx # Python アプリケーションのインストール
    nil # Nix language server
    nixfmt # Nix formatter
    statix # Nix linter
    markdownlint-cli2 # Markdown linter/formatter
    marp-cli # Markdown からスライド生成
    ansible # 構成管理ツール

    # Kubernetes / インフラツール
    kubernetes-helm # helm
    kind # Kubernetes in Docker
    kubectl
    terraform
    # kdash        # ハッシュ不一致のため一時無効化（flake update 後に復活）

    # データベース
    mariadb-connector-c # MySQL/MariaDB クライアントライブラリ
    mysql84 # MySQL 8.4 クライアント

    # Lua
    luarocks # Lua パッケージマネージャ

    # Docker
    lazydocker # Docker ターミナル UI

    # その他 CLI ツール
    peco # 対話的フィルタリングツール
    tree-sitter # パーサージェネレーター
    go-task # タスクランナー (task)
    pkgconf # パッケージ設定ツール
    tectonic # Modern LaTeX

    # システムユーティリティ
    coreutils
    findutils
    gnugrep
    gnutar

    # HTTP ツール
    xh # HTTP クライアント
    hey # HTTP ベンチマークツール

    # その他
    crush # Glamourous AI coding agent
    usacloud # さくらクラウド CLI
    _1password-cli # 1Password CLI

    # 注: 以下のパッケージは Homebrew で管理:
    #   - fluent-bit - nixpkgs の aarch64-darwin ビルドが壊れているため
  ];
}
