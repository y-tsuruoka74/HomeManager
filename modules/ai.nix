{ pkgs, config, ... }:

let
  superpowersSrc = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v5.0.6";
    hash = "sha256-r/Z+UxSFQIx99HnSPoU/toWMddXDcnLsbFXpQfLfj1k=";
  };

  # Claude Code 公式プラグインマーケットプレイス
  claudePluginsOfficialSrc = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "e3e378cbbb205673a5d7254ded32679cafa6179d";
    hash = "sha256-04vjOPpnieiLri1muM+h1/GHxne6XrPjP0lp62nxNY4=";
  };

  # knowledge-work-plugins マーケットプレイス（engineering プラグイン等）
  knowledgeWorkPluginsSrc = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "knowledge-work-plugins";
    rev = "82aae7825cdb807c2d413a42e4ca1ed7d4858fc9";
    hash = "sha256-nxxe3iytbLkblxma8KahrqXA+vKyfo2gdQRKcbnC5qA=";
  };

  claudeDir = "${config.home.homeDirectory}/.claude";

  # graphify スキル定義（Claude Code / Codex 共通のパッケージから抽出。python バージョン非依存にするため glob で取得）
  graphifySkillClaude = pkgs.runCommand "graphify-skill-claude.md" { } ''
    cp ${pkgs.graphify}/lib/*/site-packages/graphify/skill.md $out
  '';
  graphifySkillCodex = pkgs.runCommand "graphify-skill-codex.md" { } ''
    cp ${pkgs.graphify}/lib/*/site-packages/graphify/skill-codex.md $out
  '';
in
{
  home.file = {
    # superpowers Claude Code プラグイン
    ".claude/plugins/superpowers" = {
      source = superpowersSrc;
      recursive = true;
      force = true;
    };

    # superpowers スキル
    ".claude/skills" = {
      source = "${superpowersSrc}/skills";
      recursive = true;
      force = true;
    };

    # graphify スキル（コード/ドキュメント/画像/動画をナレッジグラフ化。Claude Code用）
    ".claude/skills/graphify/SKILL.md" = {
      source = graphifySkillClaude;
      force = true;
    };

    # graphify スキル（Codex CLI用。~/.codex/skills は Codex 本体が管理するがサブディレクトリは未使用のため追加可能）
    ".codex/skills/graphify/SKILL.md" = {
      source = graphifySkillCodex;
      force = true;
    };

    # Claude Code 公式プラグインマーケットプレイス
    ".claude/plugins/marketplaces/claude-plugins-official" = {
      source = claudePluginsOfficialSrc;
      recursive = true;
      force = true;
    };

    # knowledge-work-plugins マーケットプレイス
    ".claude/plugins/marketplaces/knowledge-work-plugins" = {
      source = knowledgeWorkPluginsSrc;
      recursive = true;
      force = true;
    };

    # マーケットプレイス登録情報（`claude plugin marketplace add` 相当）
    ".claude/plugins/known_marketplaces.json" = {
      text = builtins.toJSON {
        claude-plugins-official = {
          source = {
            source = "github";
            repo = "anthropics/claude-plugins-official";
          };
          installLocation = "${claudeDir}/plugins/marketplaces/claude-plugins-official";
          lastUpdated = "2026-07-23T00:00:00.000Z";
        };
        knowledge-work-plugins = {
          source = {
            source = "github";
            repo = "anthropics/knowledge-work-plugins";
          };
          installLocation = "${claudeDir}/plugins/marketplaces/knowledge-work-plugins";
          lastUpdated = "2026-07-23T00:00:00.000Z";
        };
      };
      force = true;
    };

    # Claude Code 設定
    ".claude/settings.json" = {
      source = ./../dotfiles/claude/settings.json;
      force = true;
    };
    ".claude/statusline.py" = {
      source = ./../dotfiles/claude/statusline.py;
      force = true;
    };
    ".claude/hooks/gh-api-guard.py" = {
      source = ./../dotfiles/claude/hooks/gh-api-guard.py;
      force = true;
    };
    # herdr連携: セッション開始をherdrに通知するフック（`herdr integration install claude` 相当）
    ".claude/hooks/herdr-agent-state.sh" = {
      source = ./../dotfiles/claude/hooks/herdr-agent-state.sh;
      force = true;
    };
    # Herdr表示用: 最新プロンプトをpaneタイトルとして1時間表示する。
    # 状態（working/blocked/idle）は変更せず、公式連携の画面検出と競合させない。
    ".claude/hooks/herdr-pane-title.py" = {
      source = ./../dotfiles/claude/hooks/herdr-pane-title.py;
      force = true;
    };

    # herdr連携: Codex側のセッション通知フック（`herdr integration install codex` 相当）
    # ~/.codex/config.toml はCodexアプリ側でも更新されるためHome Managerで管理しない
    # （packages.nixのcodexWithUsageラッパーで `-c features.hooks=true` を注入する）が、
    # hooks.json とフックスクリプト自体はアプリに書き換えられないため管理下に置く。
    ".codex/herdr-agent-state.sh" = {
      source = ./../dotfiles/codex/herdr-agent-state.sh;
      force = true;
    };
    ".codex/hooks.json" = {
      source = ./../dotfiles/codex/hooks.json;
      force = true;
    };

    # herdr連携: GitHub Copilot CLIのセッションIDを通知し、再起動後にresume可能にする。
    # フック本体はインストール中のHerdrと同じソースを参照してバージョンを同期する。
    ".copilot/hooks/herdr-agent-state.sh" = {
      source = "${pkgs.herdr.src}/src/integration/assets/copilot/herdr-agent-state.sh";
      force = true;
    };
    ".copilot/settings.json" = {
      text = builtins.toJSON {
        hooks.SessionStart = [
          {
            bash = "bash '${config.home.homeDirectory}/.copilot/hooks/herdr-agent-state.sh'";
            timeoutSec = 10;
            type = "command";
          }
        ];
      };
      force = true;
    };

    # herdr連携: OpenCodeのライフサイクル状態とセッションIDを直接通知する。
    ".config/opencode/plugins/herdr-agent-state.js" = {
      source = "${pkgs.herdr.src}/src/integration/assets/opencode/herdr-agent-state.js";
      force = true;
    };
  };
}
