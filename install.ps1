#!/usr/bin/env pwsh
# usagen インストーラ（Windows タスクトレイ常駐アプリ・未署名 / install.sh の Windows 版）。
#
# 利用者はこの1コマンドで導入できる（PowerShell）:
#   irm https://raw.githubusercontent.com/johnjohn-k/usagen-dist/main/install.ps1 | iex
#
# やること: 配布 repo の最新 Release から usagen-windows.zip を取得 → %LOCALAPPDATA%\Programs\usagen へ配置 →
# 未署名アプリの Mark-of-the-Web（ダウンロード来歴）を除去して SmartScreen ブロックを回避 →
# スタートメニューにショートカット作成 → 起動。
#
# 上書き可（環境変数）: DIST_REPO（既定 johnjohn-k/usagen-dist）
# 自動起動を有効化したい場合はローカルに保存して: pwsh install-windows.ps1 -Startup
[CmdletBinding()]
param(
    [string]$DistRepo = $(if ($env:DIST_REPO) { $env:DIST_REPO } else { "johnjohn-k/usagen-dist" }),
    [switch]$Startup
)
$ErrorActionPreference = "Stop"

# Windows 専用（PowerShell 5.1 / 7 の両方で判定できる方法）。
if (-not [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
    throw "usagen トレイは Windows 専用です。macOS は install.sh を使ってください。"
}

$Asset = "usagen-windows.zip"
$AppExe = "Usagen.Tray.exe"
$Url  = "https://github.com/$DistRepo/releases/latest/download/$Asset"
$Dest = Join-Path $env:LOCALAPPDATA "Programs\usagen"

# 隣にショートカットを作るヘルパー（WScript.Shell COM, Windows 標準）。
# COM と .lnk の TargetPath はセパレータに敏感なので、パスは必ずバックスラッシュへ正規化する。
function New-Shortcut([string]$LinkPath, [string]$TargetExe) {
    $LinkPath  = [System.IO.Path]::GetFullPath($LinkPath)
    $TargetExe = [System.IO.Path]::GetFullPath($TargetExe)
    New-Item -ItemType Directory -Force -Path (Split-Path $LinkPath) | Out-Null
    $shell = New-Object -ComObject WScript.Shell
    $sc = $shell.CreateShortcut($LinkPath)
    $sc.TargetPath = $TargetExe
    $sc.WorkingDirectory = Split-Path $TargetExe
    $sc.Description = "usagen — サブスク生成AIの使用量トレイ"
    $sc.Save()
}

$Tmp = Join-Path $env:TEMP ("usagen-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $Tmp | Out-Null
try {
    $Zip = Join-Path $Tmp $Asset
    Write-Host "==> ダウンロード: $Url"
    $ProgressPreference = "SilentlyContinue"  # Invoke-WebRequest の進捗描画は遅いので抑止
    Invoke-WebRequest -Uri $Url -OutFile $Zip -UseBasicParsing

    Write-Host "==> 展開"
    $Unpack = Join-Path $Tmp "unpack"
    Expand-Archive -Path $Zip -DestinationPath $Unpack -Force

    # zip のトップは 'usagen' フォルダ。見つからなければ再帰探索でフォールバック。
    $Src = Join-Path $Unpack "usagen"
    if (-not (Test-Path (Join-Path $Src $AppExe))) {
        $found = Get-ChildItem -Path $Unpack -Recurse -Filter $AppExe | Select-Object -First 1
        if (-not $found) { throw "$AppExe が zip に見つかりません。" }
        $Src = $found.Directory.FullName
    }

    # 実行中の旧プロセスがあると上書きに失敗するので停止。
    Get-Process -Name "Usagen.Tray" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    Write-Host "==> 配置: $Dest"
    if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
    New-Item -ItemType Directory -Force -Path (Split-Path $Dest) | Out-Null
    Move-Item $Src $Dest

    Write-Host "==> Mark-of-the-Web 除去（未署名アプリの SmartScreen ブロック回避）"
    Get-ChildItem -Path $Dest -Recurse -File | Unblock-File -ErrorAction SilentlyContinue

    $Exe = Join-Path $Dest $AppExe

    Write-Host "==> スタートメニューに登録"
    New-Shortcut (Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\usagen.lnk") $Exe
    if ($Startup) {
        New-Shortcut (Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup\usagen.lnk") $Exe
        Write-Host "   ログイン時の自動起動を設定しました（解除: Startup フォルダの usagen.lnk を削除）。"
    }

    Write-Host "==> 起動"
    Start-Process $Exe
    Write-Host ""
    Write-Host "OK 完了: $Dest （タスクトレイに常駐します）"
    Write-Host "   使い方: トレイのアイコン右クリック → 更新。Claude Code / Codex に本機でログイン済みなら使用量が出ます。"
    if (-not $Startup) {
        Write-Host "   ログイン時に自動起動したい場合: このスクリプトを保存して  pwsh install-windows.ps1 -Startup"
    }
}
finally {
    Remove-Item -Recurse -Force $Tmp -ErrorAction SilentlyContinue
}
