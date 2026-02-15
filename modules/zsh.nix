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
      theme = "robbyrussell";
    };
    initExtra = ''
      eval "$(zoxide init zsh)"

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
}