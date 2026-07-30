{ pkgs, config, lib, ... }:

let
  # GitHub Copilot CLIの認証トークンをKeychain(keytar)ではなく~/.copilot/config.jsonに平文保存させる。
  # Nix由来のnodeバイナリはad-hoc署名のためstoreパスが変わるたびにKeychainの信頼情報がリセットされ、
  # 毎回アクセス許可ダイアログが出てしまう。storeTokenPlaintext を有効にするとcopilot-cli自身がkeytarを
  # 使わなくなり、ダイアログが恒久的に出なくなる（トレードオフとしてトークンは平文でホームディレクトリに残る）。
  copilotConfigSync = pkgs.writeShellApplication {
    name = "copilot-config-sync";
    runtimeInputs = [ pkgs.coreutils pkgs.jq ];
    text = ''
      config_dir="${config.home.homeDirectory}/.copilot"
      config_file="$config_dir/config.json"

      mkdir -p "$config_dir"

      if [ ! -f "$config_file" ]; then
        printf '{}\n' > "$config_file"
      fi

      temporary_file=$(mktemp "$config_file.tmp.XXXXXX")
      trap 'rm -f "$temporary_file"' EXIT
      jq --argjson hooks "$COPILOT_HOOKS_JSON" \
        '.storeTokenPlaintext = true | .hooks = $hooks' \
        "$config_file" > "$temporary_file"
      mv "$temporary_file" "$config_file"
      trap - EXIT
    '';
  };

  hookCommand = script: [
    {
      bash = "bash '${config.home.homeDirectory}/.copilot/hooks/${script}'";
      timeoutSec = 10;
      type = "command";
    }
  ];

  # Tokiweave連携: Copilot CLIのツール実行・終了イベントをTokiweaveの作業ログへ転送する。
  # フック本体は TOKIWEAVE_HOOK_COMMAND が無ければ即終了するため、Tokiweave経由以外の
  # copilot利用には影響しない。
  tokiweaveCopilotHook = hookCommand "tokiweave-agent-hook.sh";

  # ユーザーレベルのフックは ~/.copilot/config.json の hooks キーに置く必要がある。
  # ~/.copilot/settings.json に置いても読まれず、一切発火しない
  # （`copilot help config`: "In global config.json these act as user-level hooks;
  # in repo settings.json they act as repo-level hooks"）。
  # config.json はcopilot自身がトークンを書き込むため、静的ファイルとして宣言せず
  # activationでマージする。
  copilotHooks = {
    # herdr連携: セッションIDを通知し、再起動後にresume可能にする。
    SessionStart = hookCommand "herdr-agent-state.sh";
    # ターミナルで追加入力した依頼を作業ログへ残すために必要。
    # 登録しないとpromptが届かず、依頼内容が空になる。
    UserPromptSubmit = tokiweaveCopilotHook;
    PostToolUse = tokiweaveCopilotHook;
    PostToolUseFailure = tokiweaveCopilotHook;
    Stop = tokiweaveCopilotHook;
    SessionEnd = tokiweaveCopilotHook;
  };
in
{
  home.packages = [ copilotConfigSync ];

  home.activation.copilotConfigSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    COPILOT_HOOKS_JSON=${
      lib.escapeShellArg (builtins.toJSON copilotHooks)
    } ${copilotConfigSync}/bin/copilot-config-sync
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
  };
}
