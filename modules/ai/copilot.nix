{ pkgs, config, lib, ... }:

let
  # GitHub Copilot CLIの認証トークンをKeychain(keytar)ではなく~/.copilot/config.jsonに平文保存させる。
  # Nix由来のnodeバイナリはad-hoc署名のためstoreパスが変わるたびにKeychainの信頼情報がリセットされ、
  # 毎回アクセス許可ダイアログが出てしまう。storeTokenPlaintext を有効にするとcopilot-cli自身がkeytarを
  # 使わなくなり、ダイアログが恒久的に出なくなる（トレードオフとしてトークンは平文でホームディレクトリに残る）。
  copilotConfigSync = pkgs.writeShellApplication {
    name = "copilot-config-store-token-plaintext-sync";
    runtimeInputs = [ pkgs.coreutils pkgs.jq ];
    text = ''
      config_dir="${config.home.homeDirectory}/.copilot"
      config_file="$config_dir/config.json"

      mkdir -p "$config_dir"

      if [ -f "$config_file" ]; then
        temporary_file=$(mktemp "$config_file.tmp.XXXXXX")
        trap 'rm -f "$temporary_file"' EXIT
        jq '.storeTokenPlaintext = true' "$config_file" > "$temporary_file"
        mv "$temporary_file" "$config_file"
        trap - EXIT
      else
        printf '{"storeTokenPlaintext": true}\n' > "$config_file"
      fi
    '';
  };

  # Tokiweave連携: Copilot CLIのツール実行・終了イベントをTokiweaveの作業ログへ転送する。
  # フック本体は TOKIWEAVE_HOOK_COMMAND が無ければ即終了するため、Tokiweave経由以外の
  # copilot利用には影響しない。
  tokiweaveCopilotHook = [
    {
      bash = "bash '${config.home.homeDirectory}/.copilot/hooks/tokiweave-agent-hook.sh'";
      timeoutSec = 10;
      type = "command";
    }
  ];
in
{
  home.packages = [ copilotConfigSync ];

  home.activation.copilotConfigStoreTokenPlaintext =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${copilotConfigSync}/bin/copilot-config-store-token-plaintext-sync
    '';

  home.file = {
    # herdr連携: GitHub Copilot CLIのセッションIDを通知し、再起動後にresume可能にする。
    # フック本体はインストール中のHerdrと同じソースを参照してバージョンを同期する。
    ".copilot/hooks/herdr-agent-state.sh" = {
      source = "${pkgs.herdr.src}/src/integration/assets/copilot/herdr-agent-state.sh";
      force = true;
    };

    # Tokiweave連携: 作業ログ用にツール実行と終了イベントを転送するフック。
    ".copilot/hooks/tokiweave-agent-hook.sh" = {
      source = ./../../dotfiles/copilot/tokiweave-agent-hook.sh;
      force = true;
    };

    # settings.json は単一ファイルなので、herdrとTokiweaveのフックをここでまとめて登録する。
    ".copilot/settings.json" = {
      text = builtins.toJSON {
        hooks = {
          SessionStart = [
            {
              bash = "bash '${config.home.homeDirectory}/.copilot/hooks/herdr-agent-state.sh'";
              timeoutSec = 10;
              type = "command";
            }
          ];
          PostToolUse = tokiweaveCopilotHook;
          PostToolUseFailure = tokiweaveCopilotHook;
          Stop = tokiweaveCopilotHook;
          SessionEnd = tokiweaveCopilotHook;
        };
      };
      force = true;
    };
  };
}
