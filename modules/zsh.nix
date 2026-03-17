{ config, pkgs, ... }:

{
  # zoxide と Starship の初期化
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "";  # Starship がプロンプトを管理
    };
    initContent = ''
      # mise バージョン管理（Nix devshell で代替可能）
      # 必要な場合は modules/packages.nix で mise を有効化し、以下のコメントを外してください:
      # eval "$(mise activate zsh)"

      # dotfiles/zsh の設定を読み込み
      source ${./../dotfiles/zsh/prompt.zsh}
      source ${./../dotfiles/zsh/extra.zsh}
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
      add_newline = true ;
      format = "$directory$git_branch$git_commit$git_state$git_status$nix_shell$cmd_duration$jobs$line_break$character";
      directory = {
        truncate_to_repo = false;
        fish_style_pwd_dir_length = 1;
      };
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
}
