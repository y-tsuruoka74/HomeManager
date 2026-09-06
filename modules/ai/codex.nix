{ lib, pkgs, ... }:

let
  # ~/.codex/config.toml は Codex アプリ側でも更新されるため、ファイル全体を
  # Home Manager で管理せず、CLI 起動時にステータスラインだけを上書きする。
  # Codex のステータスラインは1行のみのため、狭いpaneでも利用状況が残る順に並べる。
  codexWithUsage = pkgs.writeShellScriptBin "codex" ''
    exec ${pkgs.codex}/bin/codex \
      -c 'tui.status_line=["model-with-reasoning","context-remaining","five-hour-limit","weekly-limit","project-name","git-branch","total-input-tokens","total-output-tokens"]' \
      -c 'features.hooks=true' \
      "$@"
  '';
in
{
  home.packages = [ codexWithUsage ];
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
    # （このモジュールのcodexWithUsageラッパーで `-c features.hooks=true` を注入する）が、
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
