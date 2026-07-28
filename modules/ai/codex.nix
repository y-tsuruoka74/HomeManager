{ pkgs, ... }:

let
  # graphify スキル（Codex CLI用。python バージョン非依存にするため glob で取得）
  graphifySkillCodex = pkgs.runCommand "graphify-skill-codex.md" { } ''
    cp ${pkgs.graphify}/lib/*/site-packages/graphify/skill-codex.md $out
  '';
in
{
  home.file = {
    # graphify スキル（Codex CLI用。~/.codex/skills は Codex 本体が管理するがサブディレクトリは未使用のため追加可能）
    ".codex/skills/graphify/SKILL.md" = {
      source = graphifySkillCodex;
      force = true;
    };

    # herdr連携: Codex側のセッション通知フック（`herdr integration install codex` 相当）
    # ~/.codex/config.toml はCodexアプリ側でも更新されるためHome Managerで管理しない
    # （packages.nixのcodexWithUsageラッパーで `-c features.hooks=true` を注入する）が、
    # hooks.json とフックスクリプト自体はアプリに書き換えられないため管理下に置く。
    ".codex/herdr-agent-state.sh" = {
      source = ./../../dotfiles/codex/herdr-agent-state.sh;
      force = true;
    };
    ".codex/hooks.json" = {
      source = ./../../dotfiles/codex/hooks.json;
      force = true;
    };
  };
}
