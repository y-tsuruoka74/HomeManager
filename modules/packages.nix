{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # 基本的なツール
    git
    neovim
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
    # mise         # バージョン管理（Nix devshell で代替可能: dotfiles/nix/VERSION_MANAGEMENT.md 参照）
    tectonic     # Modern LaTeX

    # システムユーティリティ
    coreutils
    findutils
    gnugrep
    gnutar
  ];
}