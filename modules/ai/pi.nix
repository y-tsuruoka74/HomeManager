{ pkgs, ... }:

{
  home.file = {
    # herdr連携: pi-coding-agentのライフサイクル状態とセッションIDを直接通知する。
    ".pi/agent/extensions/herdr-agent-state.ts" = {
      source = "${pkgs.herdr.src}/src/integration/assets/pi/herdr-agent-state.ts";
      force = true;
    };
  };
}
