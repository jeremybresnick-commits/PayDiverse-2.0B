$ErrorActionPreference = 'Stop'

# ---- Constants ----
$PR  = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source'
$SRC = Join-Path $PR 'force-app\main\default'
$DAS = Join-Path $SRC 'dashboards'
$F_DEV = 'PayDiverse_Analytics'
$F_LBL = 'PayDiverse Analytics'
$ORG = 'dev-ed'

Write-Host "=== Stage 5: Normalize Dashboard Report References ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Querying reports from org..." -ForegroundColor Cyan
$query = "SELECT Name,DeveloperName FROM Report WHERE FolderName='$F_LBL'"
$csvData = sf data query --target-org $ORG -q $query -r csv

# Build Title->DeveloperName map
$map = @{}
$csvData | Select-String -NotMatch 'Name,DeveloperName' | ForEach-Object {
    $parts = $_.ToString().Split(',')
    if ($parts.Count -ge 2) { 
        $title = $parts[0].Trim()
        $devName = $parts[1].Trim()
        $map[$title] = $devName
        Write-Host "  $title -> $devName" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Found $($map.Count) report mappings" -ForegroundColor Green
Write-Host ""

$DASF = Join-Path $DAS $F_DEV
$dashFiles = Get-ChildItem $DASF -Filter *.dashboard-meta.xml -ErrorAction SilentlyContinue

$normalized = 0
foreach ($file in $dashFiles) {
    $txt = Get-Content -Raw $file.FullName
    $original = $txt
    
    # Normalize any accidental label usage in folder path
    $txt = $txt -replace [regex]::Escape('PayDiverse Analytics/'), ($F_DEV + '/')
    
    # Convert any title paths to DeveloperName paths
    foreach ($title in $map.Keys) {
        $titlePath = "$F_DEV/$title"
        $devPath = "$F_DEV/" + $map[$title]
        $txt = $txt -replace [regex]::Escape($titlePath), $devPath
    }
    
    if ($txt -ne $original) {
        $txt | Set-Content -Encoding UTF8 $file.FullName
        $normalized++
        Write-Host "Normalized: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Normalized $normalized dashboard files" -ForegroundColor Green
Write-Host ""
Write-Host "=== Stage 5 Complete ===" -ForegroundColor Green
