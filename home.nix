{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "y-tsuruoka";
  home.homeDirectory = "/Users/y-tsuruoka";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.05";

  # GUIアプリを /Applications にリンク
  home.activation.linkApplications = config.lib.dag.entryAfter ["writeBoundary"] ''
    mkdir -p /Applications
    rm -rf /Applications/Google\ Chrome.app
    ln -sf /Users/y-tsuruoka/.nix-profile/Applications/Google\ Chrome.app /Applications/Google\ Chrome.app
    rm -rf /Applications/Visual\ Studio\ Code.app
    ln -sf /Users/y-tsuruoka/.nix-profile/Applications/Visual\ Studio\ Code.app /Applications/Visual\ Studio\ Code.app
  '';

  # 基本ファイル配置
  home.file.".zshrc".text = ''
    # Home Manager によって管理されるシェル設定（最低限）
  '';

  # モジュール設定の読み込み
  imports = [
    ./modules/packages.nix
    ./modules/zsh.nix
    ./modules/git.nix
    ./modules/neovim.nix
    ./modules/brew-casks.nix  # Homebrew Casks via brew-nix
  ];
}