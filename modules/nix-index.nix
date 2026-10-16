{ inputs, ... }:

{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  # コマンド名からパッケージを検索（コマンドが見つからない時の提案）
  programs.nix-index.enable = true;
  # comma: `, <command>` で未インストールのコマンドを一時実行する（ビルド済み DB を使用）
  programs.nix-index-database.comma.enable = true;
}
