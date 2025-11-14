$ErrorActionPreference = 'Stop'

# --- Settings
$root = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source\force-app\main\default'
$reports    = Get-ChildItem -Path "$root\**" -Include *.report-meta.xml -Recurse
$dashboards = Get-ChildItem -Path "$root\**" -Include *.dashboard-meta.xml -Recurse

Write-Host "=== Metadata Normalization Script ===" -ForegroundColor Cyan
Write-Host "Found $($reports.Count) reports and $($dashboards.Count) dashboards" -ForegroundColor Cyan
Write-Host ""

# Helper: load XML without namespace to simplify edits
function Get-XmlNoNs([string]$path){
    $xml = [xml](Get-Content -Path $path -Raw)
    if ($xml.DocumentElement -and $xml.DocumentElement.Attributes["xmlns"]) {
        $xml.InnerXml = $xml.InnerXml -replace 'xmlns="[^"]+"',''
        $xml = [xml]$xml.OuterXml
    }
    return $xml
}

# 1) Purge <n> tags -> <name>
Write-Host "1) Purging <n> tags and replacing with <name>..." -ForegroundColor Yellow
$fixed1 = 0
foreach ($f in $reports + $dashboards) {
    $txt = Get-Content -Path $f.FullName -Raw
    if ($txt -match '<n>|</n>') {
        $txt = $txt -replace '<n>', '<name>' -replace '</n>', '</name>'
        Set-Content -Path $f.FullName -Value $txt -Encoding UTF8
        $fixed1++
        Write-Host "  Fixed: $($f.Name)" -ForegroundColor Green
    }
}
Write-Host "Fixed $fixed1 files with <n> tags" -ForegroundColor Green
Write-Host ""

# 2) Fix invalid UserDateInterval in REPORTS
Write-Host "2) Fixing INTERVAL_THISYEAR -> INTERVAL_CURRENT in reports..." -ForegroundColor Yellow
$fixed2 = 0
foreach ($f in $reports) {
    $xml = Get-XmlNoNs $f.FullName
    $changed = $false

    # normalize invalid 'INTERVAL_THISYEAR' -> 'INTERVAL_CURRENT'
    $nodes = $xml.SelectNodes("//userDateInterval[text()='INTERVAL_THISYEAR']")
    if ($nodes) {
        foreach ($n in $nodes) { 
            $n.InnerText = "INTERVAL_CURRENT"
            $changed = $true
        }
    }

    if ($changed) {
        $xml.Save($f.FullName)
        $fixed2++
        Write-Host "  Fixed: $($f.Name)" -ForegroundColor Green
    }
}
Write-Host "Fixed $fixed2 reports with INTERVAL_THISYEAR" -ForegroundColor Green
Write-Host ""

# 3) Fix ChartUnits (displayUnits) = 'Percent' -> 'Auto'
Write-Host "3) Fixing ChartUnits Percent -> Auto..." -ForegroundColor Yellow
$fixed3 = 0
foreach ($f in $dashboards + $reports) {
    $xml = Get-XmlNoNs $f.FullName
    $changed = $false

    # Dashboard components: <displayUnits>Percent</displayUnits> -> Auto
    foreach ($n in $xml.SelectNodes("//displayUnits[text()='Percent']")) {
        $n.InnerText = "Auto"
        $changed = $true
    }
    # Report charts: <chartUnits>Percent</chartUnits> -> Auto
    foreach ($n in $xml.SelectNodes("//chartUnits[text()='Percent']")) {
        $n.InnerText = "Auto"
        $changed = $true
    }

    if ($changed) { 
        $xml.Save($f.FullName)
        $fixed3++
        Write-Host "  Fixed: $($f.Name)" -ForegroundColor Green
    }
}
Write-Host "Fixed $fixed3 files with Percent" -ForegroundColor Green
Write-Host ""

# 4) Move chartAxisRange to correct place (Reports should use summaryAxisRange)
Write-Host "4) Moving chartAxisRange to summaryAxisRange in reports..." -ForegroundColor Yellow
$fixed4 = 0
foreach ($f in $reports) {
    $xml = Get-XmlNoNs $f.FullName
    $changed = $false
    foreach ($n in $xml.SelectNodes("//chartAxisRange")) {
        # convert to summaryAxisRange
        $new = $xml.CreateElement("summaryAxisRange")
        $new.InnerText = $n.InnerText
        $n.ParentNode.InsertBefore($new, $n) | Out-Null
        $n.ParentNode.RemoveChild($n) | Out-Null
        $changed = $true
    }
    if ($changed) { 
        $xml.Save($f.FullName)
        $fixed4++
        Write-Host "  Fixed: $($f.Name)" -ForegroundColor Green
    }
}
Write-Host "Fixed $fixed4 reports with chartAxisRange" -ForegroundColor Green
Write-Host ""

Write-Host "=== All Fixes Complete ===" -ForegroundColor Green
Write-Host "  <n> tags fixed: $fixed1"
Write-Host "  INTERVAL_THISYEAR fixed: $fixed2"
Write-Host "  Percent ChartUnits fixed: $fixed3"
Write-Host "  chartAxisRange fixed: $fixed4"
Write-Host ""
Write-Host "Ready to deploy." -ForegroundColor Cyan
