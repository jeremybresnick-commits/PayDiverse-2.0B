$ErrorActionPreference = 'Stop'

# ---- Constants ----
$PR  = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source'
$SRC = Join-Path $PR 'force-app\main\default'
$RPT = Join-Path $SRC 'reports'
$DAS = Join-Path $SRC 'dashboards'
$F_DEV = 'PayDiverse_Analytics'
$F_LBL = 'PayDiverse Analytics'

Write-Host "=== Stage 2: Overwrite Folder Metadata ===" -ForegroundColor Cyan
Write-Host ""

$RF = Join-Path $RPT "$F_DEV.reportFolder-meta.xml"
$DF = Join-Path $DAS "$F_DEV.dashboardFolder-meta.xml"

# Write report folder metadata
$reportFolderXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<ReportFolder xmlns="http://soap.sforce.com/2006/04/metadata">
  <accessType>Public</accessType>
  <name>$F_LBL</name>
</ReportFolder>
"@

$reportFolderXml | Set-Content -Encoding UTF8 -LiteralPath $RF
Write-Host "Created: $RF" -ForegroundColor Green

# Write dashboard folder metadata
$dashboardFolderXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<DashboardFolder xmlns="http://soap.sforce.com/2006/04/metadata">
  <accessType>Public</accessType>
  <name>$F_LBL</name>
</DashboardFolder>
"@

$dashboardFolderXml | Set-Content -Encoding UTF8 -LiteralPath $DF
Write-Host "Created: $DF" -ForegroundColor Green
Write-Host ""

# Remove any wrong space-named folder meta files
$RF_BAD = Join-Path $RPT "$F_LBL.reportFolder-meta.xml"
$DF_BAD = Join-Path $DAS "$F_LBL.dashboardFolder-meta.xml"

if (Test-Path $RF_BAD) { 
    Remove-Item -Force $RF_BAD
    Write-Host "Removed bad report folder file: $RF_BAD" -ForegroundColor Yellow
}
if (Test-Path $DF_BAD) { 
    Remove-Item -Force $DF_BAD
    Write-Host "Removed bad dashboard folder file: $DF_BAD" -ForegroundColor Yellow
}

# Parse-check (will throw if malformed)
Write-Host ""
Write-Host "Validating XML..." -ForegroundColor Cyan
[xml](Get-Content -Raw $RF) | Out-Null
Write-Host "Report folder XML valid" -ForegroundColor Green
[xml](Get-Content -Raw $DF) | Out-Null
Write-Host "Dashboard folder XML valid" -ForegroundColor Green

Write-Host ""
Write-Host "=== Stage 2 Complete ===" -ForegroundColor Green
