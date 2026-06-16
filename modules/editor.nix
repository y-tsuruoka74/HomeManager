{ config, pkgs, ... }:

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
}
