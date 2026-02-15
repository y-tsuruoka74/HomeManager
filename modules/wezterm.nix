{ config, pkgs, ... }:

{
  # wezterm 設定ファイルの配置
  home.file.".config/wezterm/wezterm.lua".source = ./../dotfiles/wezterm/wezterm.lua;
}