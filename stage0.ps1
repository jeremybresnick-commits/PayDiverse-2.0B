$ErrorActionPreference = 'Stop'

# ---- Constants ----
$PR  = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source'
$SRC = Join-Path $PR 'force-app\main\default'
$RPT = Join-Path $SRC 'reports'
$DAS = Join-Path $SRC 'dashboards'
$F_DEV = 'PayDiverse_Analytics'
$F_LBL = 'PayDiverse Analytics'
$ORG = 'dev-ed'

# ---- Paths must exist ----
Write-Host ""
Write-Host "Verifying paths..." -ForegroundColor Cyan
foreach ($path in @($SRC,$RPT,$DAS)) { 
    if (-not (Test-Path $path)) { 
        throw "Missing path: $path" 
    } else {
        Write-Host "Found: $path" -ForegroundColor Green
    }
}

# ---- Logs/artifacts ----
$LOG = Join-Path $PR 'logs'
$ART = Join-Path $PR 'artifacts'
New-Item -ItemType Directory -Force -Path $LOG,$ART | Out-Null
Write-Host ""
Write-Host "Logs directory: $LOG" -ForegroundColor Green
Write-Host "Artifacts directory: $ART" -ForegroundColor Green
Write-Host ""
Write-Host "=== Stage 0 Complete ===" -ForegroundColor Green
