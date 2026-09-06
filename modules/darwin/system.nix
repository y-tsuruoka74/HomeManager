{ machine, ... }:
{
  # システムのステートバージョン
  system.stateVersion = 5;

  # Determinate Nix を使用しているため nix-darwin の Nix 管理を無効化
  nix.enable = false;

  # nixpkgs 設定
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = machine.system;

  # Homebrew のバイナリを PATH に追加
  # (.zprofile 等は home-manager が管理しており、brew shellenv による追加が反映されないため)
  environment.systemPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  # プライマリユーザー（homebrew 等のユーザー依存オプションに必要）
  system.primaryUser = machine.username;

  # ユーザー設定
  users.users.${machine.username} = {
    name = machine.username;
    home = machine.homeDirectory;
  };

}
