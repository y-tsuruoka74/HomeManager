{ config, lib, pkgs, ... }:

let
  neovimStateDir = "${config.home.homeDirectory}/.local/state/nvim";
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
  };

  home.file.".config/nvim" = {
    source = ./../dotfiles/nvim;
    recursive = true;
    force = true;
  };

  # lazy.nvim updates its lockfile when it installs missing plugins, so it
  # cannot write directly to the read-only Home Manager symlink in ~/.config.
  home.activation.syncNeovimLockfile =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg neovimStateDir}
      run ${pkgs.coreutils}/bin/install -m 0644 \
        ${./../dotfiles/nvim/lazy-lock.json} \
        ${lib.escapeShellArg "${neovimStateDir}/lazy-lock.json"}
    '';
}
