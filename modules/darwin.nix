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

  # lazygit / nvim --embed が長時間起動しっぱなしになっていないか定期チェックし、
  # 該当があれば tmux 上の場所（session:window.pane と作業ディレクトリ）を通知する
  launchd.user.agents.stale-process-watchdog = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "-c"
        ''
          set -uo pipefail

          # "[[dd-]hh:]mm:ss" 形式の ps etime を秒数に変換
          etime_to_seconds() {
            local etime="$1"
            local days=0
            local rest="$etime"
            if [[ "$etime" == *-* ]]; then
              days="''${etime%%-*}"
              rest="''${etime#*-}"
            fi
            local a b c
            IFS=: read -r a b c <<< "$rest"
            if [ -n "''${c:-}" ]; then
              echo $(( days*86400 + 10#$a*3600 + 10#$b*60 + 10#$c ))
            else
              echo $(( days*86400 + 10#$a*60 + 10#''${b:-0} ))
            fi
          }

          # tty から tmux のペイン (session:window.pane と作業ディレクトリ) を逆引き
          pane_for_tty() {
            local tty="/dev/$1"
            ${pkgs.tmux}/bin/tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}|#{pane_tty}|#{pane_current_path}" 2>/dev/null \
              | awk -F'|' -v t="$tty" '$2==t {print $1" - "$3; f=1} END{exit !f}'
          }

          notify() {
            local title="$1" body="$2"
            /opt/homebrew/bin/terminal-notifier -title "$title" -message "$body"
          }

          check_pattern() {
            local pattern="$1" label="$2" threshold_h="$3"
            local threshold_sec=$(( threshold_h * 3600 ))
            local pid etime sec tty loc
            while read -r pid; do
              [ -z "$pid" ] && continue
              etime=$(ps -o etime= -p "$pid" 2>/dev/null | tr -d ' ') || continue
              [ -z "$etime" ] && continue
              sec=$(etime_to_seconds "$etime")
              if [ "$sec" -ge "$threshold_sec" ]; then
                tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
                if loc=$(pane_for_tty "$tty"); then
                  notify "''${label} が長時間起動 (''${etime})" "$loc"
                else
                  notify "''${label} が長時間起動 (''${etime})" "tty=''${tty} (tmux外)"
                fi
              fi
            done < <(pgrep -f "$pattern")
          }

          check_pattern "nvim --embed" "nvim" 6
          check_pattern "bin/lazygit" "lazygit" 24
        ''
      ];
      StartInterval = 3600;
      RunAtLoad = false;
      StandardOutPath = "/tmp/stale-process-watchdog.log";
      StandardErrorPath = "/tmp/stale-process-watchdog.log";
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
