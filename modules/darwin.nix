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

  # lazygitが同時に複数起動していないか定期チェックし、該当があれば通知する
  # （複数開きっぱなしにするとgitサブプロセスの並列実行でPCが重くなるため）
  launchd.user.agents.stale-process-watchdog = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "-c"
        ''
          set -uo pipefail

          notify() {
            local title="$1" body="$2"
            /opt/homebrew/bin/terminal-notifier -title "$title" -message "$body"
          }

          check_lazygit_count() {
            local threshold="$1"
            local count
            count=$(pgrep -f "bin/lazygit" | wc -l | tr -d ' ')
            if [ "$count" -ge "$threshold" ]; then
              notify "lazygitが''${count}個起動中" "閉じ忘れがないか確認してください"
            fi
          }

          check_lazygit_count 3
        ''
      ];
      StartInterval = 3600;
      RunAtLoad = false;
      StandardOutPath = "/tmp/stale-process-watchdog.log";
      StandardErrorPath = "/tmp/stale-process-watchdog.log";
    };
  };

  # lazygitが長時間高CPUで張り付いていないか定期チェックし、該当があれば強制終了する
  # （lazygitがUIループのハングでCPUを専有し続け、ファンが高回転になる事象が発生したため）
  launchd.user.agents.lazygit-hang-watchdog = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "-c"
        ''
          set -uo pipefail

          notify() {
            local title="$1" body="$2"
            /opt/homebrew/bin/terminal-notifier -title "$title" -message "$body"
          }

          # ps の etime (例: "05:54:12" / "1-05:54:12" / "12:34") を秒数に変換
          etime_to_seconds() {
            local etime="$1" days=0 rest="$1" h=0 m=0 s=0
            if [[ "$etime" == *-* ]]; then
              days="''${etime%%-*}"
              rest="''${etime#*-}"
            fi
            IFS=: read -ra parts <<< "$rest"
            case "''${#parts[@]}" in
              3) h="''${parts[0]}"; m="''${parts[1]}"; s="''${parts[2]}" ;;
              2) m="''${parts[0]}"; s="''${parts[1]}" ;;
              1) s="''${parts[0]}" ;;
            esac
            echo $(( 10#$days*86400 + 10#$h*3600 + 10#$m*60 + 10#$s ))
          }

          check_stuck_lazygit() {
            local min_minutes="$1" min_cpu="$2"
            while read -r pid pcpu etime; do
              [ -z "$pid" ] && continue
              local total_seconds total_minutes cpu_int
              total_seconds=$(etime_to_seconds "$etime")
              total_minutes=$(( total_seconds / 60 ))
              cpu_int="''${pcpu%.*}"
              if [ "$total_minutes" -ge "$min_minutes" ] && [ "$cpu_int" -ge "$min_cpu" ]; then
                kill -9 "$pid" 2>/dev/null
                notify "lazygitを自動終了しました" "PID ''${pid} が ''${total_minutes}分間 CPU ''${pcpu}% で稼働していたため終了しました"
              fi
            done < <(ps -axo pid=,pcpu=,etime=,comm= | grep "bin/lazygit" | awk '{print $1, $2, $3}')
          }

          check_stuck_lazygit 60 30
        ''
      ];
      StartInterval = 900;
      RunAtLoad = false;
      StandardOutPath = "/tmp/lazygit-hang-watchdog.log";
      StandardErrorPath = "/tmp/lazygit-hang-watchdog.log";
    };
  };

  # システムのステートバージョン
  system.stateVersion = 5;

  # Determinate Nix を使用しているため nix-darwin の Nix 管理を無効化
  nix.enable = false;

  # nixpkgs 設定
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Homebrew のバイナリを PATH に追加
  # (.zprofile 等は home-manager が管理しており、brew shellenv による追加が反映されないため)
  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

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
      # Homebrew 4.6+ は --cleanup 時に確認プロンプトを出すため、
      # --force-cleanup を付けて darwin-rebuild switch が対話待ちで
      # 止まらないようにする
      extraFlags = [ "--force-cleanup" ];
    };

    taps = [];

    brews = [
      "fluent-bit"          # aarch64-darwin の nixpkgs ビルドが壊れているため
      "ccusage"             # Claude Code トークン使用量の集計
      "schemathesis"        # API テストツール（nixpkgs 未対応）
      "terminal-notifier"   # pin されている nixpkgs 版が x86_64 のみのため
    ];

    casks = [
      "1password"
      "bruno"
      "chatgpt"     # ChatGPT デスクトップアプリ（Codex 機能を統合、codex-app の後継）
      "claude"
      "devtoys"
      "docker-desktop"
      "electron"
      "electron-fiddle"
      "elgato-stream-deck"  # Stream Deck 設定ツール
      "font-hackgen"
      "font-hackgen-nerd"
      "google-chrome"
      "hammerspoon"
      "logi-options+"       # Logicool マウス/キーボード設定ツール
      "monitorcontrol"      # 外部モニターの輝度・音量をキーボード/メニューバーから制御
      "multipass"
      "nvidia-sync"         # リモートLinux/DGX上のIDE・コンテナをSSH経由で起動・管理
      "obsidian"
      "onedrive"
      "raycast"
      "slack"
      "visual-studio-code"
      "wezterm"
      "zed"
      "zen"
      "zoom"
    ];
  };
}
