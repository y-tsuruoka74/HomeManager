{ lib, pkgs, ... }:

{
  # Graphify 公式の Codex 向けインストーラーで、
  # ~/.agents/skills/graphify に通常ファイルとして登録する。
  home.activation.graphifyCodexSkill = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    graphify_skill="$HOME/.agents/skills/graphify/SKILL.md"
    if [ -f "$graphify_skill" ]; then
      chmod u+w "$graphify_skill"
    fi
    ${pkgs.graphify}/bin/graphify install --platform codex
  '';

  home.file = {
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
