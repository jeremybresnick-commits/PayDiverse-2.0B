$ErrorActionPreference = 'Stop'

# ---- Constants ----
$PR  = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source'
$SRC = Join-Path $PR 'force-app\main\default'
$RPT = Join-Path $SRC 'reports'
$DAS = Join-Path $SRC 'dashboards'
$F_DEV = 'PayDiverse_Analytics'
$F_LBL = 'PayDiverse Analytics'

Write-Host "=== Stage 1: Quarantine Blockers ===" -ForegroundColor Cyan
Write-Host ""

# A) Quarantine any root-level validationRules folder
$vr_path = Join-Path $SRC 'validationRules'
if (Test-Path $vr_path) {
    $hold = Join-Path $SRC ("_holding_validationRules_{0}" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
    Write-Host "Moving validationRules folder to: $hold" -ForegroundColor Yellow
    Move-Item $vr_path $hold
} else {
    Write-Host "No validationRules folder found (OK)" -ForegroundColor Green
}

# B) Consolidate duplicate folders
$RPT_SPACE = Join-Path $RPT $F_LBL
$DAS_SPACE = Join-Path $DAS $F_LBL
$RPT_UNDER = Join-Path $RPT $F_DEV
$DAS_UNDER = Join-Path $DAS $F_DEV

# Ensure canonical directories exist
New-Item -ItemType Directory -Force -Path $RPT_UNDER,$DAS_UNDER | Out-Null
Write-Host "Ensured canonical folders exist:" -ForegroundColor Green
Write-Host "  $RPT_UNDER"
Write-Host "  $DAS_UNDER"
Write-Host ""

# Move report files from space-folder into underscore-folder (if any)
if (Test-Path $RPT_SPACE) {
    Write-Host "Found space-named report folder, consolidating..." -ForegroundColor Yellow
    $moved = 0
    Get-ChildItem $RPT_SPACE -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring(($RPT_SPACE+'\').Length)
        $dest = Join-Path $RPT_UNDER $rel
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Move-Item -Force $_.FullName $dest
        $moved++
    }
    Remove-Item -Recurse -Force $RPT_SPACE
    Write-Host "  Moved $moved report files" -ForegroundColor Green
} else {
    Write-Host "No space-named report folder (OK)" -ForegroundColor Green
}

# Move dashboard files similarly
if (Test-Path $DAS_SPACE) {
    Write-Host "Found space-named dashboard folder, consolidating..." -ForegroundColor Yellow
    $moved = 0
    Get-ChildItem $DAS_SPACE -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring(($DAS_SPACE+'\').Length)
        $dest = Join-Path $DAS_UNDER $rel
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Move-Item -Force $_.FullName $dest
        $moved++
    }
    Remove-Item -Recurse -Force $DAS_SPACE
    Write-Host "  Moved $moved dashboard files" -ForegroundColor Green
} else {
    Write-Host "No space-named dashboard folder (OK)" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Stage 1 Complete ===" -ForegroundColor Green
