{ config, pkgs, ... }:

{
  # tmux セッションを15分ごとに自動保存する launchd エージェント
  launchd.user.agents.tmux-resurrect-save = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "-c"
        ''
          if ${pkgs.tmux}/bin/tmux list-sessions &>/dev/null; then
            ${pkgs.tmux}/bin/tmux run-shell "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"
          fi
        ''
      ];
      StartInterval = 900;
      RunAtLoad = false;
      StandardOutPath = "/tmp/tmux-resurrect-save.log";
      StandardErrorPath = "/tmp/tmux-resurrect-save.log";
    };
  };

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
    ];

    brews = [
      "borders"    # macOS ウィンドウボーダー
      "gwq"        # リポジトリ管理
      "usacloud"   # さくらクラウド CLI
      "crush"
      "fluent-bit"    # aarch64-darwin の nixpkgs ビルドが壊れているため
      "ccusage"       # Claude Code トークン使用量の集計
      "schemathesis"  # API テストツール（nixpkgs 未対応）
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
    ];
  };
}
