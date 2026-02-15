{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin"; # macOS Silicon の場合は "aarch64-darwin", Intel Mac の場合は "x86_64-darwin", Linux の場合は "x86_64-linux"
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."$(whoami)" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}