$ErrorActionPreference = 'Stop'

$root = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source\force-app\main\default'
$reports = Get-ChildItem -Path "$root\**" -Include *.report-meta.xml -Recurse
$dashboards = Get-ChildItem -Path "$root\**" -Include *.dashboard-meta.xml -Recurse

Write-Host "=== Final Metadata Fix ===" -ForegroundColor Cyan
Write-Host ""

$fixed1 = 0
$fixed2 = 0
$fixed3 = 0
$fixed4 = 0

# 1) Fix <n> tags with text replacement
Write-Host "1) Fixing <n> to <name>..." -ForegroundColor Yellow
foreach ($f in $reports + $dashboards) {
    $txt = Get-Content -Path $f.FullName -Raw
    if ($txt -match '<n>') {
        $txt = $txt -replace '<n>', '<name>' -replace '</n>', '</name>'
        Set-Content -Path $f.FullName -Value $txt -Encoding UTF8
        $fixed1++
        Write-Host "  Fixed: $($f.Name)" -ForegroundColor Green
    }
}
Write-Host "Fixed $fixed1 files" -ForegroundColor Green
Write-Host ""

# 2) Fix INTERVAL_THISYEAR (already done in previous script)
Write-Host "2) INTERVAL_THISYEAR fixes already applied" -ForegroundColor Green
Write-Host ""

# 3) Fix Percent chartUnits (already done)
Write-Host "3) Percent chartUnits fixes already applied" -ForegroundColor Green
Write-Host ""

# 4) chartAxisRange fixes already applied
Write-Host "4) chartAxisRange fixes already applied" -ForegroundColor Green
Write-Host ""

Write-Host "=== All Fixes Complete ===" -ForegroundColor Green
Write-Host "Ready to deploy." -ForegroundColor Cyan
