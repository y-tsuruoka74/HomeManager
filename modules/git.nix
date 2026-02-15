{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Yuki Tsuruoka";
        email = "y-tsuruoka@sakura.ad.jp";
      };
      init.defaultBranch = "main";
      core.editor = "nvim";
      ghq.root = "~/Github";
    };
  };
}