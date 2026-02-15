{ config, pkgs, ... }:

{
  # Homebrew Casks via brew-nix
  # これらのパッケージは Homebrew をインストールせずに Nix から管理されます
  # 注意: nix run は動かない場合が多い、ビルド後に使用してください

  home.packages = with pkgs; [
    # 【移行フェーズ 1】重要なアプリを徐々に追加

    # エディタ
    brewCasks.visual-studio-code

    # ブラウザ
    brewCasks.google-chrome

    # 以下は移行フェーズ 2〜3 で追加予定
    # パスワード管理: brewCasks."1password"
    # ノート: brewCasks.obsidian
    # 開発ツール: brewCasks.bruno
    # 開発者ツール: brewCasks.devtoys
    # ターミナル: brewCasks.wezterm
    # フォント: brewCasks.font-hackgen, brewCasks.font-hackgen-nerd
  ];

  # 注意点:
  # 1. Casks に特殊文字が含まれる場合は引用符で囲む
  #    例: brewCasks."firefox@developer-edition"
  #
  # 2. 約700個の Casks はハッシュを指定する必要があります
  #    最初のビルドでエラーが出た場合、fakeHash を使用してハッシュを取得:
  #
  #    (brewCasks.my-app.overrideAttrs (oldAttrs: {
  #      src = pkgs.fetchurl {
  #        url = builtins.head oldAttrs.src.urls;
  #        hash = lib.fakeHash;  # 最初は fakeHash
  #      };
  #    }))
  #
  #    次にビルドした後にエラーメッセージに表示される実際のハッシュを fakeHash に置き換える
  #
  # 3. 特定の macOS バージョン向けのバージョンを指定する場合:
  #
  #    (brewCasks.acrobat-reader.override { variation = "sequoia"; })
  #
  # 4. brew-nix はディスク容量を消費します。不要な Casks を定期的に削除してください
  #    $ nix-collect-garbage -d
  #
  # 詳細: https://github.com/BatteredBunny/brew-nix
}