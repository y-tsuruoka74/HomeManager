{ lib, pkgs, ... }:

let
  # nixpkgs への反映を待たず、公式の安定版をハッシュ付きで固定する。
  # 更新時は version と両アーキテクチャの sha256 を更新する（README 参照）。
  codexRelease = {
    version = "0.153.4";
    targets = {
      aarch64-darwin = {
        target = "aarch64-apple-darwin";
        sha256 = "35438da1fbf7a6db7ddb3bcec84448fa6015ba188461472a97d9d1da7d9c4353";
      };
      x86_64-darwin = {
        target = "x86_64-apple-darwin";
        sha256 = "3ee638d7155c856ef31f3f4a85cb2195de1939962d3924c935b24f0514564a3d";
      };
    };
  };
  codexTarget = codexRelease.targets.${pkgs.stdenv.hostPlatform.system};
  codexPackage = pkgs.stdenvNoCC.mkDerivation {
    pname = "codex";
    inherit (codexRelease) version;
    src = pkgs.fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v${codexRelease.version}/codex-package-${codexTarget.target}.tar.gz";
      inherit (codexTarget) sha256;
    };
    sourceRoot = ".";
    dontBuild = true;
    # 署名済みバイナリと同梱の実行環境を、そのままの配置で保持する。
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R bin codex-package.json codex-path codex-resources "$out/"
      runHook postInstall
    '';
    meta = {
      description = "OpenAI Codex CLI (official release bundle)";
      homepage = "https://github.com/openai/codex";
      license = lib.licenses.asl20;
      platforms = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      mainProgram = "codex";
    };
  };

  # ~/.codex/config.toml は Codex アプリ側でも更新されるため、ファイル全体を
  # Home Manager で管理せず、CLI 起動時にステータスラインだけを上書きする。
  # Codex のステータスラインは1行のみのため、狭いpaneでも利用状況が残る順に並べる。
  codexWithUsage = pkgs.writeShellScriptBin "codex" ''
    exec ${codexPackage}/bin/codex \
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
