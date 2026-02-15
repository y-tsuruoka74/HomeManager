{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "$(whoami)";
  home.homeDirectory = "/Users/$(whoami)";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.05";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # ここにインストールしたいパッケージを追加
    pkgs.git
    pkgs.neovim
    pkgs.htop
  ];

  # Home Manager はデフォルトで ~/.config/profile を作成しない
  # 必要な dotfile を以下のように管理する

  # シェル設定の例 (bash, zsh, fish など)
  home.file.".zshrc".text = ''
    # Home Manager によって管理されるシェル設定
    export PATH="$HOME/.local/bin:$PATH"
  '';

  # 既存の dotfile をシンボリックリンクとして管理する場合
  # home.file.".config/nvim/init.lua".source = ./config/nvim/init.lua;

  # Git 設定の例
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your-email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };

  # zsh の設定 (使用している場合)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  # Starship プロンプトの設定
  # programs.starship = {
  #   enable = true;
  #   settings = {
  #     add_newline = false;
  #   };
  # };
}