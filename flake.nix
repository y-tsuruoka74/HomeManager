{
  description = "nix-darwin + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
    in
    {
      darwinConfigurations."y-tsuruoka" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit self inputs; };
        modules = [
          ./modules/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.y-tsuruoka = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit self inputs; };
          }
        ];
      };

      # home.nix 配下（packages.nix, ai/ 等）のみを sudo なしで適用するための単体構成。
      # Homebrew/launchd watchdog/システム設定など darwin.nix 側の変更は
      # 引き続き `sudo darwin-rebuild switch` が必要。
      homeConfigurations."y-tsuruoka" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit self inputs; };
        modules = [ ./home.nix ];
      };
    };
}
