{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Yuki Tsuruoka";
    userEmail = "y-tsuruoka@sakura.ad.jp";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      ghq.root = "~/Github";
    };
  };

  # dotfiles/git/gitconfig を配置
  home.file.".gitconfig".source = ./../dotfiles/git/gitconfig;
}