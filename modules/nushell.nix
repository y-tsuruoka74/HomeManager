{ config, pkgs, ... }:

{
  # ログインシェルはzshのまま。ターミナルで `nu` と打って試すためのサブシェルとして導入。
  # starship/zoxide/direnv のNushell連携は各モジュールのenableNushellIntegration
  # (デフォルト有効、programs.nushell.enableを検知して自動でON)によりここでの追加設定不要。
  programs.nushell = {
    enable = true;

    settings = {
      show_banner = false;
    };

    environmentVariables = {
      EDITOR = "nvim";
    };

    shellAliases = {
      # ls/du/find は構造化データを返すNushell標準コマンドを優先し、あえて上書きしない。
      # 生のeza/dust/fdを使いたい場合はコマンド名そのまま呼び出す。
      ll = "eza -la";
      la = "eza -a";
      lt = "eza --tree";
      cat = "bat";
      grep = "rg";
      top = "btm";
      htop = "btm";
    };

    extraConfig = ''
      # ghq + fzf でリポジトリへcd（zshのpeco-src相当）
      def --env gcd [] {
        let dir = (ghq list -p | fzf)
        if ($dir | is-not-empty) {
          cd $dir
        }
      }
    '';
  };
}
