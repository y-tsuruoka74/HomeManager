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
  };
}
