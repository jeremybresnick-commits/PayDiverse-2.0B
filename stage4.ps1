$ErrorActionPreference = 'Stop'

# ---- Constants ----
$PR  = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source'
$SRC = Join-Path $PR 'force-app\main\default'
$DAS = Join-Path $SRC 'dashboards'
$F_DEV = 'PayDiverse_Analytics'

Write-Host "=== Stage 4: Patch Dashboard Attributes ===" -ForegroundColor Cyan
Write-Host ""

$DASF = Join-Path $DAS $F_DEV
$dashFiles = Get-ChildItem $DASF -Filter *.dashboard-meta.xml -Recurse -ErrorAction SilentlyContinue

Write-Host "Found $($dashFiles.Count) dashboard files" -ForegroundColor Cyan
Write-Host ""

$patched = 0
foreach ($f in $dashFiles) {
    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $true
    $xml.Load($f.FullName)

    $ns  = 'http://soap.sforce.com/2006/04/metadata'
    $nsm = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $nsm.AddNamespace('m',$ns)
    $root = $xml.DocumentElement

    if ($root.LocalName -ne 'Dashboard') { 
        Write-Host "Skipping non-dashboard: $($f.Name)" -ForegroundColor Yellow
        continue 
    }

    $modified = $false

    if (-not $root.SelectSingleNode('m:backgroundStartColor',$nsm)) {
        $node = $xml.CreateElement('backgroundStartColor',$ns)
        $node.InnerText = '#FFFFFF'
        $root.AppendChild($node) | Out-Null
        $modified = $true
    }
    
    if (-not $root.SelectSingleNode('m:backgroundEndColor',$nsm)) {
        $node = $xml.CreateElement('backgroundEndColor',$ns)
        $node.InnerText = '#FFFFFF'
        $root.AppendChild($node) | Out-Null
        $modified = $true
    }
    
    if (-not $root.SelectSingleNode('m:backgroundFadeDirection',$nsm)) {
        $node = $xml.CreateElement('backgroundFadeDirection',$ns)
        $node.InnerText = 'LeftToRight'
        $root.AppendChild($node) | Out-Null
        $modified = $true
    }
    
    if (-not $root.SelectSingleNode('m:chartAxisRange',$nsm)) {
        $node = $xml.CreateElement('chartAxisRange',$ns)
        $node.InnerText = 'Auto'
        $root.AppendChild($node) | Out-Null
        $modified = $true
    }

    if ($modified) {
        $xml.Save($f.FullName)
        $patched++
        Write-Host "Patched: $($f.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Patched $patched dashboard files" -ForegroundColor Green
Write-Host ""
Write-Host "=== Stage 4 Complete ===" -ForegroundColor Green
