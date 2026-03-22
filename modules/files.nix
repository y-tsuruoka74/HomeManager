{ config, ... }:

{
  # すべての home.file 設定をここで管理
  home.file = {
    # Neovim 設定
    ".config/nvim" = {
      source = ./../dotfiles/nvim;
      recursive = true;
      force = true;
    };

    # wezterm 設定
    ".config/wezterm/wezterm.lua" = {
      source = ./../dotfiles/wezterm/wezterm.lua;
      force = true;
    };

    # 追加の dotfiles はここに追加してください
    # 例:
    # ".config/myapp/config.yml".source = ./../dotfiles/myapp/config.yml;
  };
}