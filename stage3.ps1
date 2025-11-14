$ErrorActionPreference = 'Stop'

# ---- Constants ----
$PR  = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source'
$SRC = Join-Path $PR 'force-app\main\default'
$LOG = Join-Path $PR 'logs'

Write-Host "=== Stage 3: Purge <n> tags ===" -ForegroundColor Cyan
Write-Host ""

$pattern = '(<\s*/?\s*)n(\s*>)'
$repl    = '$1name$2'

$changed = 0
$files = Get-ChildItem $SRC -Recurse -Include *.xml -ErrorAction SilentlyContinue

Write-Host "Scanning $($files.Count) XML files..." -ForegroundColor Cyan

foreach ($file in $files) {
    $content = Get-Content -Raw $file.FullName
    if ([regex]::IsMatch($content, $pattern)) {
        $newContent = [regex]::Replace($content, $pattern, $repl)
        $newContent | Set-Content -Encoding UTF8 $file.FullName
        $changed++
        Write-Host "Fixed: $($file.Name)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Changed $changed files" -ForegroundColor Green

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$logFile = Join-Path $LOG "name_fix_$timestamp.log"
"NAME_FIX_CHANGED_FILES,$changed" | Out-File -Encoding utf8 $logFile
Write-Host "Log written: $logFile" -ForegroundColor Green

Write-Host ""
Write-Host "Verifying no <n> tags remain..." -ForegroundColor Cyan
$xmlFiles = Get-ChildItem $SRC -Recurse -Include *.xml -ErrorAction SilentlyContinue
$remaining = $xmlFiles | Select-String -Pattern '(<\s*/?\s*)n(\s*>)' -ErrorAction SilentlyContinue

if ($remaining) {
    Write-Host "WARNING: Found remaining <n> tags:" -ForegroundColor Red
    $remaining | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
} else {
    Write-Host "All <n> tags successfully replaced" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Stage 3 Complete ===" -ForegroundColor Green
