$ErrorActionPreference = 'Stop'

# --- Settings
$root = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source\force-app\main\default'
$reports    = Get-ChildItem -Path "$root\**" -Include *.report-meta.xml -Recurse
$dashboards = Get-ChildItem -Path "$root\**" -Include *.dashboard-meta.xml -Recurse

Write-Host "=== Metadata Normalization Script (Fixed) ===" -ForegroundColor Cyan
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

# 1) Fix <n> tags -> <n> (as element name with content)
Write-Host "1) Fixing <n> element to <n>..." -ForegroundColor Yellow
$fixed1 = 0
foreach ($f in $reports + $dashboards) {
    $xml = Get-XmlNoNs $f.FullName
    $changed = $false
    
    # Find all <n> elements and rename to <n>
    $nodes = $xml.SelectNodes("//n")
    if ($nodes.Count -gt 0) {
        foreach ($node in $nodes) {
            $newNode = $xml.CreateElement("n")
            $newNode.InnerText = $node.InnerText
            $node.ParentNode.ReplaceChild($newNode, $node) | Out-Null
            $changed = $true
        }
    }
    
    if ($changed) {
        $xml.Save($f.FullName)
        $fixed1++
        Write-Host "  Fixed: $($f.Name)" -ForegroundColor Green
    }
}
Write-Host "Fixed $fixed1 files with <n> elements" -ForegroundColor Green
Write-Host ""

# 2) Fix interval INTERVAL_THISYEAR -> INTERVAL_CURRENT
Write-Host "2) Fixing INTERVAL_THISYEAR -> INTERVAL_CURRENT..." -ForegroundColor Yellow
$fixed2 = 0
foreach ($f in $reports) {
    $xml = Get-XmlNoNs $f.FullName
    $changed = $false

    # Fix <interval>INTERVAL_THISYEAR</interval>
    $nodes = $xml.SelectNodes("//interval[text()='INTERVAL_THISYEAR']")
    if ($nodes.Count -gt 0) {
        foreach ($n in $nodes) { 
            $n.InnerText = "INTERVAL_CURRENT"
            $changed = $true
        }
    }
    
    # Also check userDateInterval if it exists
    $nodes2 = $xml.SelectNodes("//userDateInterval[text()='INTERVAL_THISYEAR']")
    if ($nodes2.Count -gt 0) {
        foreach ($n in $nodes2) { 
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

# 4) Remove chartAxisRange from dashboards (it's invalid there)
Write-Host "4) Removing chartAxisRange from dashboards..." -ForegroundColor Yellow
$fixed4 = 0
foreach ($f in $dashboards) {
    $xml = Get-XmlNoNs $f.FullName
    $changed = $false
    
    $nodes = $xml.SelectNodes("//chartAxisRange")
    if ($nodes.Count -gt 0) {
        foreach ($n in $nodes) {
            $n.ParentNode.RemoveChild($n) | Out-Null
            $changed = $true
        }
    }
    
    if ($changed) { 
        $xml.Save($f.FullName)
        $fixed4++
        Write-Host "  Fixed: $($f.Name)" -ForegroundColor Green
    }
}
Write-Host "Fixed $fixed4 dashboards with chartAxisRange" -ForegroundColor Green
Write-Host ""

Write-Host "=== All Fixes Complete ===" -ForegroundColor Green
Write-Host "  <n> elements fixed: $fixed1"
Write-Host "  INTERVAL_THISYEAR fixed: $fixed2"
Write-Host "  Percent ChartUnits fixed: $fixed3"
Write-Host "  chartAxisRange removed: $fixed4"
Write-Host ""
Write-Host "Ready to redeploy." -ForegroundColor Cyan
