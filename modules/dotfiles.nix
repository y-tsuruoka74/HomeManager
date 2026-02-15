{ config, ... }:

{
  # Dotfiles を Home Manager で管理
  # ここに外部ファイルを参照する設定を追加します

  home.file = {
    # Neovim 設定
    ".config/nvim".source = ./../dotfiles/nvim;

    # wezterm 設定
    ".config/wezterm/wezterm.lua".source = ./../dotfiles/wezterm/wezterm.lua;

    # 追加の dotfiles はここに追加してください
    # 例:
    # ".config/myapp/config.yml".source = ./../dotfiles/myapp/config.yml;
  };
}