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

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      machine = import ./machine.nix;
      inherit (machine) system;
      mkDarwin =
        extraModules: extraHomeModules:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit self inputs machine; };
          modules = [
            ./modules/darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${machine.username}.imports = [ ./home.nix ] ++ extraHomeModules;
              home-manager.extraSpecialArgs = { inherit self inputs machine; };
            }
          ]
          ++ extraModules;
        };
      mkHome =
        extraModules:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit self inputs machine; };
          modules = [ ./home.nix ] ++ extraModules;
        };
      workHomeModules = [ ./hosts/home-work.nix ];
      personalHomeModules = [ ./hosts/home-personal.nix ];
    in
    {
      darwinConfigurations = {
        # 既存の適用先は共通設定のみ。個人用アプリは明示的に選択する。
        ${machine.username} = mkDarwin [ ] [ ];
        work = mkDarwin [ ./hosts/work.nix ] workHomeModules;
        personal = mkDarwin [ ./hosts/personal.nix ] personalHomeModules;
      };

      # home.nix 配下（packages.nix, ai/ 等）のみを sudo なしで適用するための単体構成。
      # Homebrew/launchd watchdog/システム設定など darwin.nix 側の変更は
      # 引き続き `sudo darwin-rebuild switch` が必要。
      homeConfigurations = {
        ${machine.username} = mkHome [ ];
        work = mkHome workHomeModules;
        personal = mkHome personalHomeModules;
      };
    };
}
