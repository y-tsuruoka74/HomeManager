{ config, ... }:

{
  home.sessionVariables.LANG = "ja_JP.UTF-8";
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  programs.zsh = {
    shellAliases = {
      ll = "eza -la";
      ls = "eza";
      la = "eza -a";
      lt = "eza --tree";
      cat = "bat";
      grep = "rg";
      find = "fd";
      du = "dust";
      top = "btm";
      htop = "btm";
    };
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
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Starship プロンプトの設定
  # パワーライン風に区間を背景色でつなぐ配色。custom.shell_zsh/shell_nu は
  # starship標準の[shell]モジュールがシェルごとに色を変えられないため、
  # STARSHIP_SHELL を条件に片方だけ表示する代替実装。
  # 注意: whenフィールドはSTARSHIP_SHELLの値に応じて評価シェルが変わる
  # （zsh起動時はPOSIX sh、nu起動時はNushell自身）ため、判定式の構文が異なる。
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 1000;
      palette = "mine";
      format = "\${custom.shell_zsh}\${custom.shell_nu}$directory$git_branch\${custom.git_user}$git_commit$git_state$git_status$nix_shell$cmd_duration$jobs$line_break$character";

      palettes.mine = {
        color_zsh = "#89b4fa";
        color_nu = "#a6e3a1";
        color_dir = "#45475a";
        color_git = "#fab387";
        color_dark = "#11111b";
        color_light = "#cdd6f4";
      };

      custom.shell_zsh = {
        command = "echo -n";
        when = ''test "$STARSHIP_SHELL" = "zsh"'';
        format = "[](fg:color_zsh)[  zsh ](bg:color_zsh fg:color_dark)[](fg:color_zsh bg:color_dir)";
      };
      custom.shell_nu = {
        command = "echo -n";
        when = ''$env.STARSHIP_SHELL == "nu"'';
        format = "[](fg:color_nu)[ 󰆍 nu ](bg:color_nu fg:color_dark)[](fg:color_nu bg:color_dir)";
      };

      directory = {
        style = "bg:color_dir fg:color_light";
        format = "[ $path ]($style)";
        truncate_to_repo = false;
      };

      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[×](bold red)";
      };

      git_branch = {
        symbol = "";
        style = "bg:color_git fg:color_dark";
        format = "[](fg:color_dir bg:color_git)[ $symbol $branch ]($style)";
      };
      git_status = {
        style = "bg:color_git fg:color_dark";
        format = "[$all_status$ahead_behind ]($style)[](fg:color_git)";
      };
      custom.git_user = {
        command = "git config github.login";
        require_repo = true;
        style = "bg:color_git fg:color_dark";
        format = "[$output]($style)";
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
