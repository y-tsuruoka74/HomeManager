{ config, ... }:

{
  # すべての home.file 設定をここで管理
  home.file = {
    # シェル設定
    ".zshrc".text = ''
      # Home Manager によって管理されるシェル設定（最低限）
    '';

    # Git 設定
    ".gitconfig".source = ./../dotfiles/git/gitconfig;

    # Neovim 設定
    ".config/nvim".source = ./../dotfiles/nvim;

    # wezterm 設定
    ".config/wezterm/wezterm.lua".source = ./../dotfiles/wezterm/wezterm.lua;

    # 追加の dotfiles はここに追加してください
    # 例:
    # ".config/myapp/config.yml".source = ./../dotfiles/myapp/config.yml;
  };
}