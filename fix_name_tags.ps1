$ErrorActionPreference = 'Stop'

# --- Settings  
$root = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source\force-app\main\default'
$reports    = Get-ChildItem -Path "$root\**" -Include *.report-meta.xml -Recurse
$dashboards = Get-ChildItem -Path "$root\**" -Include *.dashboard-meta.xml -Recurse

Write-Host "=== Fix Remaining <n> Tags ===" -ForegroundColor Cyan
Write-Host ""

$fixed = 0
foreach ($f in $reports + $dashboards) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    $original = $content
    
    # Replace <n> with <n> using regex
    $content = $content -replace '<n>', '<n>'
    $content = $content -replace '</n>', '</n>'
    
    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.UTF8Encoding]::new($false))
        $fixed++
        Write-Host "Fixed: $($f.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Fixed $fixed files with <n> tags" -ForegroundColor Green
