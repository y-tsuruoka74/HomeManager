{ config, pkgs, lib, ... }:

let
  superpowersSrc = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v5.0.6";
    hash = "sha256-r/Z+UxSFQIx99HnSPoU/toWMddXDcnLsbFXpQfLfj1k=";
  };
in
{
  # すべての home.file 設定をここで管理
  home.file = {
    # superpowers Claude Code プラグイン
    ".claude/plugins/superpowers" = {
      source = superpowersSrc;
      recursive = true;
    };

    # superpowers スキル
    ".claude/skills" = {
      source = "${superpowersSrc}/skills";
      recursive = true;
    };
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

    # zellij 設定
    ".config/zellij/config.kdl" = {
      source = ./../dotfiles/zellij/config.kdl;
      force = true;
    };

    # tmux 設定
    ".config/tmux/tmux.conf" = {
      source = ./../dotfiles/tmux/tmux.conf;
      force = true;
    };

    # lazygit 設定
    "Library/Application Support/lazygit/config.yml" = {
      source = ./../dotfiles/lazygit/config.yml;
      force = true;
    };
    "Library/Application Support/lazygit/gen-commit-msg.sh" = {
      source = ./../dotfiles/lazygit/gen-commit-msg.sh;
      force = true;
    };

    # claude-code-router 設定
    ".claude-code-router/config.json" = {
      source = ./../dotfiles/ccr/config.json;
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