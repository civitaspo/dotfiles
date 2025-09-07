# AGENTS.md

このファイルは、AIコーディングエージェントがこのdotfilesリポジトリで効果的に作業するためのガイドラインです。

## プロジェクト概要

このリポジトリは、Nix Darwin・Home Manager・Aquaを使用した個人のdotfilesを管理するプロジェクトです。macOS上でNixエコシステムによる宣言的なシステム管理を行っています。

## 環境セットアップ

### 初回セットアップ
```bash
./setup.sh  # Nix・Homebrew・Aquaのインストール
```

### 設定の適用
```bash
./build-switch.sh  # システム設定をNix Darwinで適用
```

### Nix関連のコマンド
```bash
nix flake check  # Flakeの設定チェック
nix-darwin-rebuild switch --flake .  # システム設定の適用
```

## 重要なファイルとディレクトリ構造

- `flake.nix` - Nix Flakeの設定ファイル（システム全体の設定）
- `home/` - ユーザーレベルの設定ファイル
- `machines/` - マシン固有の設定
- `pkgs/` - カスタムパッケージ定義
- `lib/` - 共通ライブラリ
- `.claude/` - Claude Code固有の設定
- `aqua*.yaml` - Aquaパッケージマネージャーの設定（シンボリックリンク）

## 開発ガイドライン

### コードスタイル
- 末尾の改行を必ず挿入すること
- Nixの設定変更後は `nix flake check` を実行すること
- semantic commit messageを使用すること（例: `feat(nix): add new package`）

### パッケージ管理
- システムレベルのパッケージ: Nix Flakeで管理
- 開発ツール: Aquaで管理
- Aqua設定ファイルは `home/xdg/aquaproj-aqua/` に配置され、ルートにシンボリックリンク

### システム構成の管理
- システム設定: `home/darwin.nix` でmacOSシステム全体の設定
- ユーザー設定: `home/home-manager.nix` とその他の`home/`配下でHome Manager設定
- マシン固有設定: `machines/` でデバイス別の設定
- カスタムパッケージ: `pkgs/` で独自パッケージを定義

### 権限設定
Claude Codeでは以下のコマンドが許可されています：
- `aqua install`, `aqua search`, `aqua list`, `aqua g`
- `rm` コマンド
- `nix flake check`

## テストとビルド

### 設定の検証
```bash
nix flake check  # Flakeの構文と依存関係をチェック
```

### システムへの適用
```bash
./build-switch.sh  # 設定を適用（慎重に実行）
```

## トラブルシューティング

### よくある問題
- Nix Flakeエラー: `flake.lock` を更新 (`nix flake update`)
- 権限エラー: Claude Code設定で適切な権限が設定されているか確認
- シンボリックリンクの問題: `home/xdg/aquaproj-aqua/` の実ファイルを確認

### デバッグ
- Nix設定のデバッグ: `nix flake show` で構造を確認
- システム状態の確認: `darwin-rebuild check`

## 注意事項

- システム設定の変更は影響範囲が大きいため、事前に `nix flake check` で検証
- `build-switch.sh` はシステム全体に影響するため、慎重に実行
- このリポジトリは個人用dotfilesなので、個人の設定に関する質問も歓迎

## 技術スタック

### 主要技術
- **Nix Darwin**: macOSのシステム設定を宣言的に管理
- **Home Manager**: ユーザーレベルの設定とパッケージ管理
- **Aqua**: バージョン管理されたコマンドラインツール群
- **Nix Flakes**: 依存関係とビルドの再現性を保証

### 設定ファイルの対応関係
- `flake.nix` → システム全体の構成定義
- `home/darwin.nix` → macOS固有のシステム設定
- `home/home-manager.nix` → ユーザー環境設定
- `home/programs/` → 個別アプリケーション設定
- `aqua*.yaml` → コマンドラインツールのバージョン管理

## 関連リンク

- [Nix Darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Aqua](https://aquaproj.github.io/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)


