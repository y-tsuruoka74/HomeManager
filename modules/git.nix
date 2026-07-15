{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      ghq.root = "~/Github";
      push.autoSetupRemote = true;
      pull.rebase = false;
      merge.conflictstyle = "zdiff3";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
    includes = [
      # user.name/email はマシンごとに異なるため Nix 管理から外し、
      # 各マシンで手動作成するローカルファイルから読み込む
      # (例: [user]\n  name = ...\n  email = ...)
      # デフォルトは git-user コマンドで切り替えるプロファイル
      {
        path = "~/.gitconfig.identity";
      }
      # ghq.root 配下は "~/Github/<host>/<owner>/<repo>" 構造になるため、
      # ホスト単位で強制的にアイデンティティを出し分ける
      # (github.com = 私用, github.sakura.codes = 会社、で完全に分かれているため)
      {
        condition = "gitdir:~/Github/github.com/";
        path = "~/.config/git/identities/personal.gitconfig";
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
    "Library/Application Support/lazygit/prune-merged-branches.sh" = {
      source = ./../dotfiles/lazygit/prune-merged-branches.sh;
      force = true;
    };
  };
}