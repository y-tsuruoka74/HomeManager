# Homebrew Casks 移行管理

このファイルは Homebrew Casks を brew-nix に移行する進行状況を管理します。

## 現在の状態 (2026-02-15)

- **Homebrew Casks**: 18 個
- **移行済み**: 0 個
- **残り**: 18 個

## 移行フェーズ

### Phase 1: 重要なアプリ (現在進行中)

| アプリ | ステータス | Homebrew 削除日 |
|--------|----------|---------------|
| visual-studio-code | 🔄 移行中 | - |
| google-chrome | 🔄 移行中 | - |

**手順:**
```bash
# 1. 設定を適用
nix flake update
home-manager switch --flake .#y-tsuruoka

# 2. アプリケーションを開いて動作確認
#    - VSCode 起動して拡張機能が正常か確認
#    - Chrome 起動してブックマークや設定が保持されているか確認

# 3. Homebrew から削除
brew uninstall --cask visual-studio-code google-chrome
```

### Phase 2: 日常使用アプリ

| アプリ | ステータス |
|--------|----------|
| 1password | ⏳ 待機 |
| obsidian | ⏳ 待機 |
| wezterm | ⏳ 待機 |

**Phase 1 が成功したら開始**

### Phase 3: 開発ツール

| アプリ | ステータス |
|--------|----------|
| bruno | ⏳ 待機 |
| devtoys | ⏳ 待機 |
| font-hackgen | ⏳ 待機 |
| font-hackgen-nerd | ⏳ 待機 |
| zoom | ⏳ 待機 |

### Phase 4: 要テスト

| アプリ | ステータス | 備考 |
|--------|----------|------|
| hammerspoon | ⏳ 待機 | システム統合 |
| multipass | ⏳ 待機 | VM 管理 |
| raycast | ⏳ 待機 | シ統深部統合 |

### Homebrew に残す（移行しない）

| アプリ | 理由 |
|--------|------|
| docker-desktop | 依存関係が複雑 |
| electron | フレームワーク依存 |
| electron-fiddle | electron に依存 |
| 1password-cli | CLI ツールなので Nixpkgs などの代替が好ましい |

## トラブルシューティング

### ハッシュエラーが出た場合

```
error: hash mismatch in fixed-output derivation for ...
```

解決手順:
1. 注釈がある最後のビルド出力を表示されます

```bash
# 1. 一時的に fakeHash を使用
home.packages = with pkgs; [
  (brewCasks.my-app.overrideAttrs (oldAttrs: {
    src = pkgs.fetchurl {
      url = builtins.head oldAttrs.src.urls;
      hash = lib.fakeHash;
    };
  }))
];
```

2. ビルドしてエラー出力から実際のハッシュを取得

```bash
nix build --no-link .#homeConfigurations.y-tsuruoka.placeholderPackage
```

エラーメッセージから `"got: sha256-..."` の部分をコピーして `fakeHash` を置き換えます

### アプリが起動できない場合

**Nix Store 内の `.app` を確認:**
```bash
# パッケージのパスを確認
nix-store -q $(which code) 2>/dev/null || nix-store -q -R ~/.nix-profile | grep "visual-studio-code" | head -1
```

**Path またはLaunchpadから起動：** `.app` ファイルが Nix Store にある場合、その `.app` を直接起動するか、Home Manager 設定を確認します

**または**、最初に brew-nix から削除して Homebrew に戻ります

```bash
# Home Manager から削除
# modules/brew-casks.nix から該当行を削除

# Homebrew で再インストール
brew install --cask visual-studio-code
```

## 移行完了のマーク

各フェーズが完了したら以下の情報を更新:

- 移行したアプリのステータスを "✅ 完成" に変更
- Homebrew 削除日を記入 (YYYY-MM-DD)
- 残りカウントを更新:

```markdown
- **Homebrew Casks**: X 個
- **移行済み**: Y 個
- **残り**: (X-Y) 個
```

## 参考情報

- [brew-nix GitHub](https://github.com/BatteredBunny/brew-nix)
- [Homebrew Casks List](https://formulae.brew.sh/cask/)
- 現在の Homebrew Casks 一覧:
  ```bash
  brew list --cask
  ```