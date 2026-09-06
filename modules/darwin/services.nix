{ pkgs, ... }:
let
  watchdog = pkgs.writeShellScript "process-watchdog" ''
    exec ${pkgs.python314}/bin/python3 ${../../scripts/process_watchdog.py} "$@"
  '';
  agent = name: interval: arguments: {
    serviceConfig = {
      ProgramArguments = arguments;
      StartInterval = interval;
      RunAtLoad = false;
      StandardOutPath = "/tmp/${name}.log";
      StandardErrorPath = "/tmp/${name}.log";
    };
  };
  saveTmux = pkgs.writeShellScript "tmux-resurrect-save" ''
    if ${pkgs.tmux}/bin/tmux list-sessions &>/dev/null; then
      ${pkgs.tmux}/bin/tmux run-shell "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"
    fi
  '';
in
{
  launchd.user.agents = {
    tmux-resurrect-save = agent "tmux-resurrect-save" 900 [ "${saveTmux}" ];
    stale-process-watchdog = agent "stale-process-watchdog" 3600 [
      "${watchdog}"
      "count"
    ];
    lazygit-hang-watchdog = agent "lazygit-hang-watchdog" 900 [
      "${watchdog}"
      "cpu"
    ];
    live-server-watchdog = agent "live-server-watchdog" 1800 [
      "${watchdog}"
      "live-server"
    ];
  };
}
