# PayDiverse Auto-Sync Watcher
# Monitors Dropbox source folder and auto-syncs on changes

$sourceRepo = "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
$syncScript = Join-Path $sourceRepo "Master-Sync.ps1"

Write-Host "👁️  PayDiverse Auto-Sync Watcher Started" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Monitoring: $sourceRepo" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Gray

# Create file system watcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $sourceRepo
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor 
                        [System.IO.NotifyFilters]::DirectoryName -bor
                        [System.IO.NotifyFilters]::LastWrite

# Debounce timer (wait 5 seconds after last change before syncing)
$timer = New-Object System.Timers.Timer
$timer.Interval = 5000  # 5 seconds
$timer.AutoReset = $false

$syncPending = $false

# Timer elapsed event - trigger sync
$timerAction = {
    Write-Host "`n🔄 Changes detected, starting sync..." -ForegroundColor Yellow
    & $syncScript
    $global:syncPending = $false
}

Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action $timerAction | Out-Null

# File change event
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    
    # Ignore .git folder changes
    if ($path -notlike "*\.git\*") {
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "[$timestamp] $changeType : $path" -ForegroundColor Gray
        
        # Reset timer (debounce)
        if (-not $global:syncPending) {
            $global:syncPending = $true
            Write-Host "⏱️  Waiting for more changes..." -ForegroundColor DarkGray
        }
        $timer.Stop()
        $timer.Start()
    }
}

# Register events
Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $action | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $action | Out-Null

Write-Host "✅ Watcher active - monitoring for changes..." -ForegroundColor Green
Write-Host "`n💡 Make changes in Dropbox and they'll auto-sync!" -ForegroundColor Cyan

# Keep script running
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
finally {
    # Cleanup
    $watcher.Dispose()
    $timer.Dispose()
    Get-EventSubscriber | Unregister-Event
    Write-Host "`n⏹️  Watcher stopped" -ForegroundColor Yellow
}
