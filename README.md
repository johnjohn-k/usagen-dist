# usagen（macOS）配布

サブスク型生成 AI（Claude Code / Codex）の**使用量・レート制限・リセット時刻**を macOS メニューバーから確認するツール。
このリポジトリは**配布専用**（ビルド済みアプリと install スクリプトのみ）。ソースは別リポジトリ。

## インストール（コマンド1つ）

```bash
curl -fsSL https://raw.githubusercontent.com/johnjohn-k/usagen-dist/main/install.sh | bash
```

これだけで、最新版を `/Applications`（書けなければ `~/Applications`）に入れて起動します。
**未署名アプリのため通常は出る Gatekeeper の確認を、スクリプトが隔離属性の除去で自動回避**します。

- 対象: macOS（Apple Silicon）
- アンインストール: `rm -rf /Applications/usagen.app`（`~/Applications` に入った場合はそちら）

## 使い方

1. メニューバーの usagen アイコンをクリック
2. Claude が「未設定」なら **「既存ログインを読み込む（推奨）」**
3. 初回だけ macOS の Keychain 承認ダイアログで **「常に許可」**（ログイン済みの Claude Code / Codex を読み取り専用で取り込む）
4. 以降は使用量・リセット時刻が表示されます

## 注意（未署名配布の制約）

- このアプリは Apple Developer ID 署名・公証をしていません（無料配布方針）。install スクリプトを使わず zip を手動で開く場合は、
  macOS が初回にブロックします（システム設定 > プライバシーとセキュリティ >「このまま開く」）。
- **更新時に Keychain の再承認が必要**な場合があります（未署名ゆえ版ごとに署名 ID が変わるため）。

## 手動ダウンロード

スクリプトを使いたくない場合は [Releases](../../releases/latest) から `usagen-macos.zip` を取得し、
解凍して `usagen.app` を `/Applications` へ。初回起動は上記のとおり手動で許可してください。
