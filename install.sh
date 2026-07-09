#!/usr/bin/env bash
# usagen インストーラ（未署名 macOS メニューバーアプリ・Apple Silicon）。
#
# 利用者はこの1コマンドで導入できる:
#   curl -fsSL https://raw.githubusercontent.com/johnjohn-k/usagen-dist/main/install.sh | bash
#
# やること: 配布 repo の最新 Release から usagen-macos.zip を取得 → /Applications（不可なら
# ~/Applications）へ配置 → 未署名アプリの Gatekeeper 隔離属性を除去 → 起動。
# 上書き可: DIST_REPO（既定 johnjohn-k/usagen-dist）
set -euo pipefail

DIST_REPO="${DIST_REPO:-johnjohn-k/usagen-dist}"
ASSET="usagen-macos.zip"
APP="usagen.app"
URL="https://github.com/${DIST_REPO}/releases/latest/download/${ASSET}"

[ "$(uname -s)" = "Darwin" ] || { echo "usagen は macOS 専用です。" >&2; exit 1; }
command -v curl >/dev/null || { echo "curl が必要です。" >&2; exit 1; }
command -v ditto >/dev/null || { echo "ditto（macOS 標準）が必要です。" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> ダウンロード: $URL"
curl -fL --retry 3 -o "$TMP/$ASSET" "$URL"

echo "==> 展開"
ditto -x -k "$TMP/$ASSET" "$TMP/unpacked"
[ -d "$TMP/unpacked/$APP" ] || { echo "$APP が zip に見つかりません。" >&2; exit 1; }

# 配置先: /Applications を優先、書けなければ ~/Applications（管理者権限なしでも入る）。
DEST="/Applications"
[ -w "$DEST" ] || { DEST="$HOME/Applications"; mkdir -p "$DEST"; }

echo "==> 配置: $DEST/$APP"
rm -rf "${DEST:?}/$APP"
mv "$TMP/unpacked/$APP" "$DEST/$APP"

echo "==> Gatekeeper 隔離属性を除去（未署名アプリのため。これで初回の手動許可が不要になる）"
xattr -dr com.apple.quarantine "$DEST/$APP" 2>/dev/null || true

echo "==> 起動"
open "$DEST/$APP" || true
echo "✅ 完了: $DEST/$APP （メニューバーに常駐します）"
echo "   使い方: メニューバーのアイコン →「既存ログインを読み込む（推奨）」→ Keychain 承認で「常に許可」"
