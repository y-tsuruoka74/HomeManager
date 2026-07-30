{
  pkgs,
  config,
  lib,
  ...
}:

let
  # OpenCode設定: provider/modelの構造はNixで宣言し、APIキーはGit管理外の
  # ~/.config/opencode/secrets.json から実行時にマージする。
  # このHomeManagerリポジトリはpublicなため、キーをNix store（世界中から読める）に
  # 直接置くことはできない。secrets.jsonはリポジトリの外（$HOME直下）にあるため
  # そもそもGit管理の対象にならない。
  opencodeConfigBase = {
    "$schema" = "https://opencode.ai/config.json";
    model = "ai-engine-prod/preview/Kimi-K2.7-Code";
    provider = {
      ai-engine-dev = {
        npm = "@ai-sdk/openai-compatible";
        name = "AI Engine Dev";
        options = {
          baseURL = "https://gateway.aipf-dev.sakuraha.jp/v1";
        };
        models = {
          "GLM-4.7" = {
            name = "AI Engine Dev - glm-4.7";
            limit = {
              context = 128000;
              output = 5000;
            };
          };
          "Qwen3-Coder-480B-A35B-Instruct-FP8" = {
            name = "AI Engine Dev - qwen3-coder-480b-a35b-instruct-fp8";
            limit = {
              context = 1048576;
              output = 5000;
            };
          };
          "preview/Kimi-K2.5" = {
            name = "AI Engine Dev - preview/Kimi-K2.5";
            limit = {
              context = 1048576;
              output = 5000;
            };
          };
        };
      };
      ai-engine-prod = {
        npm = "@ai-sdk/openai-compatible";
        name = "AI Engine Prod";
        options = {
          baseURL = "https://api.ai.sakura.ad.jp/v1";
        };
        models = {
          "Qwen3-Coder-480B-A35B-Instruct-FP8" = {
            name = "AI Engine Prod - qwen3-coder-480b-a35b-instruct-fp8";
            limit = {
              context = 1048576;
              output = 5000;
            };
          };
          "preview/Kimi-K2.7-Code" = {
            name = "AI Engine Prod - preview/Kimi-K2.7-Code";
            limit = {
              context = 1048576;
              output = 5000;
            };
          };
        };
      };
      local-ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Local LLM - Ollama";
        options = {
          baseURL = "http://localhost:11434/v1";
        };
        models = {
          "glm-4.7-flash:latest" = {
            name = "Local LLM - glm-4.7-flash";
            limit = {
              context = 128000;
              output = 8192;
            };
          };
        };
      };
    };
  };

  opencodeConfigBaseFile = pkgs.writeText "opencode-config-base.json" (
    builtins.toJSON opencodeConfigBase
  );

  # secrets.json でAPIキーを補う対象のprovider一覧
  opencodeSecretProviders = [
    "ai-engine-dev"
    "ai-engine-prod"
  ];

  opencodeConfigSync = pkgs.writeShellApplication {
    name = "opencode-config-sync";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    text = ''
      config_dir="${config.home.homeDirectory}/.config/opencode"
      config_file="$config_dir/opencode.json"
      secrets_file="$config_dir/secrets.json"

      mkdir -p "$config_dir"

      merged=$(cat ${opencodeConfigBaseFile})

      if [ -f "$secrets_file" ]; then
        for provider in ${lib.escapeShellArgs opencodeSecretProviders}; do
          key=$(jq -r --arg p "$provider" '.[$p] // empty' "$secrets_file")
          if [ -n "$key" ]; then
            merged=$(echo "$merged" | jq --arg p "$provider" --arg k "$key" '.provider[$p].options.apiKey = $k')
          else
            echo "opencode-config-sync: secrets.json に $provider のAPIキーがありません（スキップ）" >&2
          fi
        done
      else
        echo "opencode-config-sync: $secrets_file が見つかりません。APIキーなしで書き込みます: $config_file" >&2
      fi

      temporary_file=$(mktemp "$config_file.tmp.XXXXXX")
      trap 'rm -f "$temporary_file"' EXIT
      echo "$merged" | jq '.' > "$temporary_file"
      mv "$temporary_file" "$config_file"
      trap - EXIT
    '';
  };
in
{
  home.packages = [ opencodeConfigSync ];

  home.activation.opencodeConfigSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${opencodeConfigSync}/bin/opencode-config-sync
  '';

  home.file = {
    # herdr連携: OpenCodeのライフサイクル状態とセッションIDを直接通知する。
    ".config/opencode/plugins/herdr-agent-state.js" = {
      source = "${pkgs.herdr.src}/src/integration/assets/opencode/herdr-agent-state.js";
      force = true;
    };
  };
}
