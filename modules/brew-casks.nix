{ config, pkgs, ... }:

{
  # Homebrew Casks via brew-nix
  # これらのパッケージは Homebrew をインストールせずに Nix から管理されます
  # 注意: nix run は動かない場合が多い、ビルド後に使用してください

  home.packages = with pkgs; [
    # 以下は例。必要な Casks を追加してください

    # 開発ツール
    # brewCasks."visual-studio-code"
    # brewCasks."cursor"

    # ブラウザ
    # brewCasks."arc"
    # brewCasks."firefox@developer-edition"

    # その他
    # brewCasks."raycast"
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
  #        hash = lib.fakeHash;
  #      };
  #    }))
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