{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Neovim 設定ファイルの配置
  # dotfiles/nvim/init.lua が存在する場合、シンボリックリンクを作成
  home.file.".config/nvim".source = ./../dotfiles/nvim;
}