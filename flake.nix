{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # brew-nix for managing Homebrew Casks via Nix
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, brew-nix, brew-api, ... }:
    let
      system = "aarch64-darwin"; # macOS Silicon の場合は "aarch64-darwin", Intel Mac の場合は "x86_64-darwin", Linux の場合は "x86_64-linux"
      pkgs = nixpkgs.legacyPackages.${system}.extend brew-nix.overlays.default;
    in {
      homeConfigurations."y-tsuruoka" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit self inputs brew-nix; };
        modules = [
          ./home.nix
        ];
      };
    };
}