{ machine, ... }:

{
  # nh: nix-darwin / Home Manager のリビルドを nom + nvd で見やすくするラッパー
  programs.nh = {
    enable = true;
    # NH_FLAKE として設定され、`nh darwin switch` で flake パスを省略できる
    flake = "${machine.homeDirectory}/Github/github.com/y-tsuruoka74/HomeManager";
  };
}
