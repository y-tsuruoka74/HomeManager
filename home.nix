{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "y-tsuruoka";
  home.homeDirectory = "/Users/y-tsuruoka";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.05";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # 基本的なツール
    git
    neovim
    htop

    # 開発ツール
    fzf
    ripgrep
    jq
    bat
    eza # ls の代替
    zoxide # cd の代替

    # システムユーティリティ
    coreutils
    findutils
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
    userName = ""; # TODO: 自分のユーザー名を設定
    userEmail = ""; # TODO: 自分のメールアドレスを設定
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
    # zoxide と Starship の初期化
    initExtra = ''
      eval "$(zoxide init zsh)"
    '';
  };

  # zoxide の設定
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Starship プロンプトの設定
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$direnv$nix_shell$git_branch$git_commit$git_state$git_status$cmd_duration$jobs$line_break$character";
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[×](bold red)";
      };
      git_branch = {
        symbol = "";
        format = "[$symbol$branch]($style) ";
      };
      git_status = {
        style = "bold yellow";
      };
      nix_shell = {
        format = "[$symbol]($style) ";
        symbol = "";
      };
      cmd_duration = {
        min_time = 1000;
        format = "took [$duration]($style) ";
      };
    };
  };

  # Neovim の設定
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}