{
  # Homebrew 管理（nixpkgs 未対応パッケージのみ）
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall"; # 設定外のパッケージを自動削除
      # Homebrew 4.6+ は --cleanup 時に確認プロンプトを出すため、
      # --force-cleanup を付けて darwin-rebuild switch が対話待ちで
      # 止まらないようにする
      extraFlags = [ "--force-cleanup" ];
    };

    taps = [
      "stablyai/orca" # Orca (AIコーディングエージェント並列実行ADE) 用
    ];

    brews = [
      "fluent-bit" # aarch64-darwin の nixpkgs ビルドが壊れているため
      "ccusage" # Claude Code トークン使用量の集計
      "schemathesis" # API テストツール（nixpkgs 未対応）
      "terminal-notifier" # pin されている nixpkgs 版が x86_64 のみのため
    ];

    casks = [
      "1password"
      "bruno"
      "chatgpt" # ChatGPT デスクトップアプリ（Codex 機能を統合、codex-app の後継）
      "claude"
      "devtoys"
      "docker-desktop"
      "electron"
      "electron-fiddle"
      "elgato-stream-deck" # Stream Deck 設定ツール
      "font-hackgen"
      "font-hackgen-nerd"
      "google-chrome"
      "hammerspoon"
      "logi-options+" # Logicool マウス/キーボード設定ツール
      "monitorcontrol" # 外部モニターの輝度・音量をキーボード/メニューバーから制御
      "multipass"
      "nvidia-sync" # リモートLinux/DGX上のIDE・コンテナをSSH経由で起動・管理
      "obsidian"
      "onedrive"
      "raycast"
      "slack"
      "stablyai/orca/orca" # 複数のコーディングエージェントを並列実行するADE
      "visual-studio-code"
      "wezterm"
      "zed"
      "zen"
      "zoom"
    ];
  };
}
