{ config, pkgs, ... }:

{
  # システムのステートバージョン
  system.stateVersion = 5;

  # Determinate Nix を使用しているため nix-darwin の Nix 管理を無効化
  nix.enable = false;

  # nixpkgs 設定
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  # プライマリユーザー（homebrew 等のユーザー依存オプションに必要）
  system.primaryUser = "y-tsuruoka";

  # ユーザー設定
  users.users.y-tsuruoka = {
    name = "y-tsuruoka";
    home = "/Users/y-tsuruoka";
  };

  # Homebrew 管理（nixpkgs 未対応パッケージのみ）
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall"; # 設定外のパッケージを自動削除
    };

    taps = [
      "1password/tap"       # 1password, 1password-cli
      "felixkratz/formulae" # borders
      "d-kuro/tap"          # gwq
      "charmbracelet/tap"   # crush
      "sacloud/usacloud"    # usacloud
      "manaflow-ai/cmux"    # cmux
    ];

    brews = [
      "borders"    # macOS ウィンドウボーダー
      "gwq"        # リポジトリ管理
      "usacloud"   # さくらクラウド CLI
      "crush"
      "fluent-bit" # aarch64-darwin の nixpkgs ビルドが壊れているため
    ];

    casks = [
      "1password"
      "1password-cli"
      "bruno"
      "claude"
      "devtoys"
      "docker-desktop"
      "electron"
      "electron-fiddle"
      "font-hackgen"
      "font-hackgen-nerd"
      "hammerspoon"
      "multipass"
      "obsidian"
      "raycast"
      "visual-studio-code"
      "wezterm"
      "zen"
      "zoom"
      "cmux"
    ];
  };
}
