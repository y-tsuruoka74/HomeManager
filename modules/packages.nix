{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # 基本的なツール
    git
    neovim
    htop

    # 開発ツール
    fzf
    ripgrep
    jq
    bat
    eza # ls の代替
    zoxide # cd の代替

    # システムユーティリティ
    coreutils
    findutils
  ];
}