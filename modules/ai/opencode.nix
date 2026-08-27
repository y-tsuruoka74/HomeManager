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
          "preview/gemma-4-31B-it" = {
            name = "AI Engine Dev - preview/gemma-4-31B-it";
            limit = {
              context = 128000;
              output = 5000;
            };
          };
          "preview/Kimi-K2.7-Code" = {
            name = "AI Engine Dev - preview/Kimi-K2.7-Code";
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
          "preview/Kimi-K2.7-Code" = {
            name = "AI Engine Prod - preview/Kimi-K2.7-Code";
            limit = {
              context = 1048576;
              output = 5000;
            };
          };
          "preview/Kimi-K2.6" = {
            name = "AI Engine Prod - preview/Kimi-K2.6";
            limit = {
              context = 1048576;
              output = 5000;
            };
          };
          "gpt-oss-120b" = {
            name = "AI Engine Prod - gpt-oss-120b";
            limit = {
              context = 128000;
              output = 5000;
            };
          };
          "preview/Qwen3.6-35B-A3B" = {
            name = "AI Engine Prod - preview/Qwen3.6-35B-A3B";
            limit = {
              context = 128000;
              output = 5000;
            };
          };
          "preview/Qwen3-VL-30B-A3B-Instruct" = {
            name = "AI Engine Prod - preview/Qwen3-VL-30B-A3B-Instruct";
            limit = {
              context = 128000;
              output = 5000;
            };
          };
          "llm-jp-3.1-8x13b-instruct4" = {
            name = "AI Engine Prod - llm-jp-3.1-8x13b-instruct4";
            limit = {
              context = 128000;
              output = 5000;
            };
          };
          "preview/gemma-4-31B-it" = {
            name = "AI Engine Prod - preview/gemma-4-31B-it";
            limit = {
              context = 128000;
              output = 5000;
            };
          };
        };
      };
      gx10-ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "GX10 - Ollama";
        options = {
          baseURL = "http://127.0.0.1:11434/v1";
        };
        models = {
          "qwen3.8:27B" = {
            name = "GX10 - Qwen 3.8 27B";
            limit = {
              context = 262144;
              output = 8192;
            };
          };
        };
      };
      gx10 = {
        npm = "@ai-sdk/openai-compatible";
        name = "GX10 llama.cpp";
        options = {
          baseURL = "http://127.0.0.1:8080/v1";
          apiKey = "local";
        };
        models = {
          "qwen3-8-flash-next-gguf-ud-q4-k-xl" = {
            name = "Qwen3.8 Flash Next Q4";
            limit = {
              context = 32768;
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
