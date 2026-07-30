{ pkgs, config, lib, ... }:

let
  # herdrのフックだけを~/.copilot/config.jsonへ登録する。
  #
  # 外部のアプリも同じファイルへフックを登録するため、`.hooks`を丸ごと
  # 置き換えてはいけない。置き換えると他が登録したイベントが`switch`のたびに
  # 消える。自分が足すキーだけを差し込む。
  #
  # config.jsonはCopilot自身がトークンなどを書き込むファイルなので、静的ファイルとして
  # 宣言せずactivationでマージする。ユーザーレベルのフックはこのファイルにしか
  # 置けない（settings.jsonに置いても読まれず一切発火しない）。
  #
  # 認証情報の保存方法（storeTokenPlaintext）には触らない。以前はKeychainの
  # 許可ダイアログを避けるため平文保存を強制していたが、トークンがホームに
  # 平文で残るため外した。ダイアログが煩わしくても、ここへ戻さないこと。
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
      jq --argjson entries "$HERDR_SESSION_START_JSON" \
        '.hooks.SessionStart = $entries' \
        "$config_file" > "$temporary_file"
      mv "$temporary_file" "$config_file"
      trap - EXIT
    '';
  };

  # herdr連携: セッションIDを通知し、再起動後にresume可能にする。
  herdrSessionStart = [
    {
      bash = "bash '${config.home.homeDirectory}/.copilot/hooks/herdr-agent-state.sh'";
      timeoutSec = 10;
      type = "command";
    }
  ];
in
{
  home.packages = [ copilotConfigSync ];

  home.activation.copilotConfigSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    HERDR_SESSION_START_JSON=${
      lib.escapeShellArg (builtins.toJSON herdrSessionStart)
    } ${copilotConfigSync}/bin/copilot-config-sync
  '';

  home.file = {
    # herdr連携: GitHub Copilot CLIのセッションIDを通知し、再起動後にresume可能にする。
    # フック本体はインストール中のHerdrと同じソースを参照してバージョンを同期する。
    ".copilot/hooks/herdr-agent-state.sh" = {
      source = "${pkgs.herdr.src}/src/integration/assets/copilot/herdr-agent-state.sh";
      force = true;
    };
  };
}
