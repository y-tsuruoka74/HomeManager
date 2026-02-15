# Nix を使ったバージョン管理

mise と Nix の比較と使い分け:

## mise vs Nix のバージョン管理

### mise を使う場合

```bash
# Node.js バージョンをインストール
mise install node@22
mise use -g node@22

# プロジェクトごとのバージョン
cd ~/my-project
mise use node@20

# バージョン確認
node --version  # v20.x.x
```

**メリット:**
- 既存のワークフローに馴染みやすい
- グローバルバージョン管理が簡単
- プロジェクトの `.tool-versions` ファイルで共有

**デメリット:**
- 環境が完全に分離されない
- 依存関係の再現性が Nix ほど高くない

### Nix を使う場合

#### 開発シェル (devshell)

プロジェクトの `flake.nix` で開発環境を定義:

```nix
{
  description = "My project dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: {
    devShells.${system}.default = let
      pkgs = nixpkgs.legacyPackages.${system};
    in pkgs.mkShell {
      buildInputs = with pkgs; [
        nodejs_22
        python312
        go
      ];
    };
  };
}
```

使用方法:

```bash
# プロジェクトディレクトリで
cd ~/my-project

# シェルを起動
nix develop

# バージョンが固定された環境で開発
node --version  # v22.x.x
python --version  # v3.12.x
```

#### direnv と組み合わせる

プロジェクトディレクトリで自動的にシェルを有効化:

```bash
# .envrc
use flake
```

ディレクトリに入ると自動的に開発環境が読み込まれます。

**メリット:**
- 完全に宣言的で再現性が高い
- プロジェクトごとの分離が確実
- チームメンバーが全く同じ環境を得られる

**デメリット:**
- 学習コストが高い
- 既存のワークフローとは異なる

## 推奨される使い分け

### パターン A: Nix 優先（ガチ派）

- バージョン管理: Nix devshell
- グローバルツール: Home Manager

```bash
# プロジェクトの依存関係は Nix で完全管理
cd ~/my-project
nix develop
```

### パターン B: mise + Nix（実用派）

- バージョン管理: mise
- パッケージ管理: Home Manager + Nix

```bash
# グローバルバージョンは mise
mise use -g node@lts

# プロジェクト依存はプロジェクトの .tool-versions
cd ~/my-project
mise use node@20
```

### パターン C: 混合利用（漸進的移行）

- 既存プロジェクト: mise のまま
- 新しいプロジェクト: Nix devshell
- グローバルツール: Home Manager

## Nix でバージョンを指定する例

### 特定バージョンの Node.js

```nix
# 最新の Node.js 22
nodejs_22

# 特定バージョンのために nixpkgs の古いコミットを使用
nodejs_20  # 古い版が必要な場合
```

### Python

```nix
# Python 3.12
python312

# Python 3.11
python311
```

### Go

```nix
# Go
go
```

### 複数のバージョンを共存

プロジェクトシェルで必要なバージョンを指定:

```nix
buildInputs = with pkgs; [
  (callPackage ./nix/node-20.nix {})  # Node 20
  (callPackage ./nix/node-22.nix {})  # Node 22
];
```

## 現在の構成での推奨

既に Home Manager を導入しているため、以下のアプローチがおすすめ:

1. **ミックス**: mise をそのまま使いつつ、新しいプロジェクトから Nix devshell を試す
2. **完全移行**: Nix devshell に完全に移行するには学習時間が必要
3. **当面の解決**: mise を使いつつ、Home Manager でパッケージ管理を強化

## 移行手順（Nix devshell 完全移行）

```bash
# 1. プロジェクトに flake.nix を作成
cp dotfiles/nix/devshell.nix ~/my-project/flake.nix

# 2. devshell を起動
cd ~/my-project
nix develop

# 3. 必要に応じて direnv 設定
echo "use flake" > .envrc
direnv allow
```