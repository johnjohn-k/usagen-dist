# usagen 配布（macOS / Windows）

サブスク型生成 AI（Claude Code / Codex）の**使用量・レート制限・リセット時刻**を、macOS メニューバー /
Windows タスクトレイから確認するツール。このリポジトリは**配布専用**（ビルド済みアプリと install スクリプトのみ）。
ソースは別リポジトリ。

## インストール（コマンド1つ）

### macOS（Apple Silicon・ターミナル）

```bash
curl -fsSL https://raw.githubusercontent.com/johnjohn-k/usagen-dist/main/install.sh | bash
```

最新版を `/Applications`（書けなければ `~/Applications`）に入れて起動します。
**未署名アプリのため通常出る Gatekeeper の確認を、スクリプトが隔離属性の除去で自動回避**します。

- アンインストール: `rm -rf /Applications/usagen.app`（`~/Applications` に入った場合はそちら）

### Windows（PowerShell）

```powershell
irm https://raw.githubusercontent.com/johnjohn-k/usagen-dist/main/install.ps1 | iex
```

最新版を `%LOCALAPPDATA%\Programs\usagen` に入れて起動し、スタートメニューに登録します。
**未署名アプリのため通常出る SmartScreen の警告を、スクリプトが Mark-of-the-Web の除去で自動回避**します。
.NET も Windows App SDK ランタイムもアプリに同梱済みなので、別途インストールは不要です。

- ログイン時に自動起動したい場合: スクリプトを保存して `pwsh install.ps1 -Startup`
- アンインストール: `%LOCALAPPDATA%\Programs\usagen` フォルダと、スタートメニューの `usagen.lnk` を削除

## 使い方

1. メニューバー / タスクトレイの usagen アイコンをクリック（Windows は右クリック → 更新）
2. 本機で **Claude Code / Codex にログイン済み**なら、使用量・リセット時刻が表示されます
3. macOS で Claude が「未設定」なら **「既存ログインを読み込む（推奨）」** → 初回だけ Keychain 承認で **「常に許可」**
   （ログイン済みの資格情報を読み取り専用で取り込む。書き込みは一切しません）

## 注意（未署名配布の制約）

- Apple Developer ID 署名・公証、および Windows のコード署名はしていません（無料配布方針）。
- install スクリプトを使わず zip を手動で開く場合は初回にブロックされます:
  - macOS: システム設定 > プライバシーとセキュリティ >「このまま開く」
  - Windows: SmartScreen「詳細情報」→「実行」
- macOS は**更新時に Keychain の再承認が必要**な場合があります（未署名ゆえ版ごとに署名 ID が変わるため）。

## 手動ダウンロード

スクリプトを使いたくない場合は [Releases](../../releases/latest) から取得:

- macOS: `usagen-macos.zip` を解凍して `usagen.app` を `/Applications` へ
- Windows: `usagen-windows.zip` を解凍して `Usagen.Tray.exe` を実行

初回起動は上記「注意」のとおり手動で許可してください。
