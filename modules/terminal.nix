{ ... }:

{
  home.file = {
    ".config/wezterm/wezterm.lua" = {
      source = ./../dotfiles/wezterm/wezterm.lua;
      force = true;
    };
    ".config/zellij/config.kdl" = {
      source = ./../dotfiles/zellij/config.kdl;
      force = true;
    };
    ".config/tmux/tmux.conf" = {
      source = ./../dotfiles/tmux/tmux.conf;
      force = true;
    };
  };
}
