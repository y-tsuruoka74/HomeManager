{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    initContent = ''
      # 補完キャッシュが古い場合は再生成
      if [[ -f ~/.zcompdump && ~/.zcompdump -ot ${config.home.profileDirectory} ]]; then
        rm -f ~/.zcompdump
        compinit
      fi

      # dotfiles/zsh の設定を読み込み
      source ${./../dotfiles/zsh/prompt.zsh}
      source ${./../dotfiles/zsh/extra.zsh}
    '';
  };

  # zoxide（インストール + shell 統合）
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # fzf（インストール + shell 統合）
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # direnv（インストール + shell 統合 + nix-direnv）
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Starship プロンプトの設定
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true ;
      format = "$directory$git_branch\${custom.git_user}$git_commit$git_state$git_status$nix_shell$cmd_duration$jobs$line_break$character";
      directory = {
        truncate_to_repo = false;
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
      custom.git_user = {
        command = "git config github.login";
        when = "git rev-parse --is-inside-work-tree 2>/dev/null";
        format = "[$output](dimmed white) ";
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
