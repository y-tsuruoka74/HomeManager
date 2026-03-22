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

    # Hammerspoon 設定
    ".hammerspoon/init.lua" = {
      source = ./../dotfiles/hammerspoon/init.lua;
      force = true;
    };

    # gwq 設定
    ".config/gwq/config.toml" = {
      source = ./../dotfiles/gwq/config.toml;
      force = true;
    };

    # Claude Code 設定
    ".claude/settings.json" = {
      source = ./../dotfiles/claude/settings.json;
      force = true;
    };
    ".claude/statusline.py" = {
      source = ./../dotfiles/claude/statusline.py;
      force = true;
    };
  };
}