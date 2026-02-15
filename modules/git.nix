{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = ""; # TODO: 自分のユーザー名を設定
    userEmail = ""; # TODO: 自分のメールアドレスを設定
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };

  # dotfiles/git/gitconfig を配置
  home.file.".gitconfig".source = ./../dotfiles/git/gitconfig;
}