{
  description = "各言語の開発用シェル";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: {
    devShells.${system}.default = let
      pkgs = nixpkgs.legacyPackages.${system};
    in pkgs.mkShell {
      buildInputs = with pkgs; [
        # Node.js
        nodejs_22

        # Python
        python312
        python312Packages.pip

        # Go
        go

        # Rust
        rustc
        cargo

        # ビルドツール
        pkg-config
        openssl

        # その他必要なツール
        hugo
      ];

      shellHook = ''
        echo "開発環境が有効化されました"
        echo "Node: $(node --version)"
        echo "Python: $(python --version)"
        echo "Go: $(go version)"
      '';
    };
  };
}