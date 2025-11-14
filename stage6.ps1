$ErrorActionPreference = 'Stop'

# ---- Constants ----
$PR  = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source'
$SRC = Join-Path $PR 'force-app\main\default'
$RPT = Join-Path $SRC 'reports'
$DAS = Join-Path $SRC 'dashboards'
$F_DEV = 'PayDiverse_Analytics'
$ORG = 'dev-ed'
$LOG = Join-Path $PR 'logs'

Write-Host "=== Stage 6: Deploy in Sequence ===" -ForegroundColor Cyan
Write-Host ""

# Change to project root for SF CLI
Set-Location $PR
Write-Host "Working directory: $PR" -ForegroundColor Cyan
Write-Host ""

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$logPrev = Join-Path $LOG "deploy_preview_$ts.log"
$logRep  = Join-Path $LOG "deploy_reports_$ts.log"
$logDas  = Join-Path $LOG "deploy_dashboards_$ts.log"

# Optional plan (may be noisy on Dev Edition)
Write-Host "Running deployment preview..." -ForegroundColor Cyan
sf project deploy preview --target-org $ORG --source-dir $SRC | Tee-Object $logPrev
Write-Host ""

# Stage A: Folders (safe to skip if already present)
Write-Host "Stage A: Deploying folder metadata..." -ForegroundColor Cyan
$RF = Join-Path $RPT "$F_DEV.reportFolder-meta.xml"
$DF = Join-Path $DAS "$F_DEV.dashboardFolder-meta.xml"

Write-Host "  Deploying report folder..."
sf project deploy start --target-org $ORG --source-dir $RF --ignore-conflicts

Write-Host "  Deploying dashboard folder..."
sf project deploy start --target-org $ORG --source-dir $DF --ignore-conflicts
Write-Host ""

# Stage B: Reports
Write-Host "Stage B: Deploying reports..." -ForegroundColor Cyan
$RPT_UNDER = Join-Path $RPT $F_DEV
sf project deploy start --target-org $ORG --source-dir $RPT_UNDER --ignore-conflicts | Tee-Object $logRep
Write-Host ""

# Stage C: Dashboards
Write-Host "Stage C: Deploying dashboards..." -ForegroundColor Cyan
$DAS_UNDER = Join-Path $DAS $F_DEV
sf project deploy start --target-org $ORG --source-dir $DAS_UNDER --ignore-conflicts | Tee-Object $logDas

Write-Host ""
Write-Host "=== Stage 6 Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Logs written:" -ForegroundColor Cyan
Write-Host "  $logPrev"
Write-Host "  $logRep"
Write-Host "  $logDas"
