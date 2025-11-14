$ErrorActionPreference = 'Stop'

# ---- Constants ----
$PR  = 'C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source'
$SRC = Join-Path $PR 'force-app\main\default'
$RPT = Join-Path $SRC 'reports'
$DAS = Join-Path $SRC 'dashboards'
$F_DEV = 'PayDiverse_Analytics'

Write-Host "=== Stage 7/8: Fix Deployment Errors (v2) ===" -ForegroundColor Cyan
Write-Host ""

# ---- FIX 2: Replace INTERVAL_THISYEAR with THIS_YEAR ----
Write-Host "Fix 2: Replacing INTERVAL_THISYEAR with THIS_YEAR..." -ForegroundColor Yellow
$RPT_DIR = Join-Path $RPT $F_DEV
$reportFiles = Get-ChildItem $RPT_DIR -Filter *.report-meta.xml -Recurse

$fixed2 = 0
foreach ($file in $reportFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    if ($content -match 'INTERVAL_THISYEAR') {
        $content = $content -replace 'INTERVAL_THISYEAR', 'THIS_YEAR'
        
        # Retry with exponential backoff
        $retries = 5
        $success = $false
        for ($i = 0; $i -lt $retries; $i++) {
            try {
                [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.UTF8Encoding]::new($false))
                $success = $true
                break
            } catch {
                if ($i -eq ($retries - 1)) { 
                    Write-Host "  FAILED after $retries retries: $($file.Name)" -ForegroundColor Red
                    Write-Host "    Error: $_" -ForegroundColor Red
                    break
                }
                $wait = [Math]::Pow(2, $i) * 100
                Start-Sleep -Milliseconds $wait
            }
        }
        
        if ($success) {
            $fixed2++
            Write-Host "  Fixed interval: $($file.Name)" -ForegroundColor Green
        }
    }
}
Write-Host "Fixed $fixed2 reports with INTERVAL_THISYEAR" -ForegroundColor Green
Write-Host ""

# ---- FIX 3: Fix dashboard chartAxisRange placement ----
Write-Host "Fix 3: Removing chartAxisRange from dashboards..." -ForegroundColor Yellow
$DAS_DIR = Join-Path $DAS $F_DEV
$dashFiles = Get-ChildItem $DAS_DIR -Filter *.dashboard-meta.xml -Recurse

$fixed3 = 0
foreach ($file in $dashFiles) {
    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $true
    
    # Retry loading
    $retries = 5
    $loaded = $false
    for ($i = 0; $i -lt $retries; $i++) {
        try {
            $xml.Load($file.FullName)
            $loaded = $true
            break
        } catch {
            if ($i -eq ($retries - 1)) { 
                Write-Host "  FAILED to load: $($file.Name)" -ForegroundColor Red
                break
            }
            $wait = [Math]::Pow(2, $i) * 100
            Start-Sleep -Milliseconds $wait
        }
    }
    
    if (-not $loaded) { continue }
    
    $ns = 'http://soap.sforce.com/2006/04/metadata'
    $nsm = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $nsm.AddNamespace('m', $ns)
    
    # Remove chartAxisRange nodes
    $nodesToRemove = $xml.SelectNodes('//m:chartAxisRange', $nsm)
    if ($nodesToRemove.Count -gt 0) {
        foreach ($node in $nodesToRemove) {
            $node.ParentNode.RemoveChild($node) | Out-Null
        }
        
        # Retry saving
        $retries = 5
        $success = $false
        for ($i = 0; $i -lt $retries; $i++) {
            try {
                $xml.Save($file.FullName)
                $success = $true
                break
            } catch {
                if ($i -eq ($retries - 1)) { 
                    Write-Host "  FAILED to save: $($file.Name)" -ForegroundColor Red
                    break
                }
                $wait = [Math]::Pow(2, $i) * 100
                Start-Sleep -Milliseconds $wait
            }
        }
        
        if ($success) {
            $fixed3++
            Write-Host "  Removed chartAxisRange: $($file.Name)" -ForegroundColor Green
        }
    }
}
Write-Host "Fixed $fixed3 dashboards with chartAxisRange" -ForegroundColor Green
Write-Host ""

# ---- FIX 4: Fix ChartUnits Percent value ----
Write-Host "Fix 4: Fixing ChartUnits Percent value..." -ForegroundColor Yellow
$fixed4 = 0
foreach ($file in $dashFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    if ($content -match '<chartUnits>Percent</chartUnits>') {
        $content = $content -replace '<chartUnits>Percent</chartUnits>', '<chartUnits>Auto</chartUnits>'
        
        # Retry with exponential backoff
        $retries = 5
        $success = $false
        for ($i = 0; $i -lt $retries; $i++) {
            try {
                [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.UTF8Encoding]::new($false))
                $success = $true
                break
            } catch {
                if ($i -eq ($retries - 1)) { 
                    Write-Host "  FAILED after $retries retries: $($file.Name)" -ForegroundColor Red
                    break
                }
                $wait = [Math]::Pow(2, $i) * 100
                Start-Sleep -Milliseconds $wait
            }
        }
        
        if ($success) {
            $fixed4++
            Write-Host "  Fixed ChartUnits: $($file.Name)" -ForegroundColor Green
        }
    }
}
Write-Host "Fixed $fixed4 dashboards with Percent ChartUnits" -ForegroundColor Green
Write-Host ""

Write-Host "=== Fixes Complete ===" -ForegroundColor Green
Write-Host "  Reports with INTERVAL_THISYEAR: $fixed2"
Write-Host "  Dashboards with chartAxisRange: $fixed3"
Write-Host "  Dashboards with Percent: $fixed4"
