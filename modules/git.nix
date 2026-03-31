{ pkgs, ... }:

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
      push.autoSetupRemote = true;
      pull.rebase = false;
      merge.conflictstyle = "zdiff3";
    };
    includes = [
      {
        condition = "gitdir:~/work/";
        path = "~/.gitconfig.work";
      }
    ];
  };

  home.file = {
    "Library/Application Support/lazygit/config.yml" = {
      source = ./../dotfiles/lazygit/config.yml;
      force = true;
    };
    "Library/Application Support/lazygit/gen-commit-msg.sh" = {
      source = ./../dotfiles/lazygit/gen-commit-msg.sh;
      force = true;
    };
  };
}