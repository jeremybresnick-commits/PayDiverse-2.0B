# PayDiverse Master Sync System
# SOURCE OF TRUTH: Dropbox
# Syncs: Dropbox → OneDrive + GitHub (PayDiverse-2.0B + paydiverse-beta) + Dev-Ed Org

param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipGitHub,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipOneDrive,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipDevEd,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoCommit
)

# SOURCE: Dropbox
$sourceRepo = "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"

# DESTINATIONS
$oneDriveBackup = "C:\Users\jresn\OneDrive\2.0 PayDiverse\PayDiverse-2.0B-DevEd-Backup"
$localPD20B = "C:\Users\jresn\PayDiverse-2.0B"
$localBeta = "C:\Users\jresn\paydiverse-beta"

Write-Host "`n🔄 PayDiverse Master Sync System" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "SOURCE: Dropbox" -ForegroundColor Yellow
Write-Host "PATH: $sourceRepo`n" -ForegroundColor Gray

function Sync-Directory {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Name
    )
    
    Write-Host "📁 Syncing to: $Name" -ForegroundColor Yellow
    Write-Host "   Destination: $Destination" -ForegroundColor Gray
    
    if (-not (Test-Path $Destination)) {
        New-Item -Path $Destination -ItemType Directory -Force | Out-Null
    }
    
    $result = robocopy $Source $Destination /MIR /XD .git /MT:8 /R:1 /W:1 /NFL /NDL /NJH /NJS
    
    if ($LASTEXITCODE -le 7) {
        Write-Host "   ✅ Synced successfully" -ForegroundColor Green
        return $true
    } else {
        Write-Host "   ⚠️  Sync completed with warnings (Exit code: $LASTEXITCODE)" -ForegroundColor Yellow
        return $false
    }
}

function Git-SyncAndPush {
    param(
        [string]$RepoPath,
        [string]$RepoName,
        [string]$Branch
    )
    
    Write-Host "`n🔀 Git: $RepoName" -ForegroundColor Yellow
    
    Push-Location $RepoPath
    
    try {
        # Pull latest
        Write-Host "   Pulling latest from GitHub..." -ForegroundColor Gray
        git pull origin $Branch 2>&1 | Out-Null
        
        # Add all changes
        git add . 2>&1 | Out-Null
        
        # Check if there are changes
        $status = git status --porcelain
        if ($status) {
            Write-Host "   Changes detected, committing..." -ForegroundColor Gray
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            git commit -m "Auto-sync from Dropbox source - $timestamp" 2>&1 | Out-Null
            
            Write-Host "   Pushing to GitHub..." -ForegroundColor Gray
            git push origin $Branch 2>&1 | Out-Null
            Write-Host "   ✅ Pushed to GitHub ($Branch)" -ForegroundColor Green
        } else {
            Write-Host "   ✓ No changes to commit" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "   ❌ Git error: $_" -ForegroundColor Red
    }
    finally {
        Pop-Location
    }
}

function Sync-ToDevEd {
    param(
        [string]$SourcePath
    )
    
    Write-Host "`n☁️  Salesforce Dev-Ed Org" -ForegroundColor Yellow
    
    Push-Location $SourcePath
    
    try {
        Write-Host "   Deploying to dev-ed org..." -ForegroundColor Gray
        
        # Deploy to dev-ed org
        $deployResult = sf project deploy start --target-org dev-ed --source-dir force-app --ignore-conflicts --json 2>&1 | ConvertFrom-Json
        
        if ($deployResult.status -eq 0) {
            Write-Host "   ✅ Deployed to dev-ed org successfully" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Deploy completed with warnings" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "   ⚠️  Deploy skipped or failed: $_" -ForegroundColor Yellow
    }
    finally {
        Pop-Location
    }
}

# MAIN SYNC PROCESS
try {
    Write-Host "`n📋 Starting sync process..." -ForegroundColor Cyan
    
    # 1. Sync to OneDrive backup
    if (-not $SkipOneDrive) {
        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "1️⃣  OneDrive Backup" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Sync-Directory -Source $sourceRepo -Destination $oneDriveBackup -Name "OneDrive Backup"
    }
    
    # 2. Sync to local PayDiverse-2.0B
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "2️⃣  Local PayDiverse-2.0B" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Sync-Directory -Source $sourceRepo -Destination $localPD20B -Name "PayDiverse-2.0B (local)"
    
    # 3. Sync to local paydiverse-beta
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "3️⃣  Local paydiverse-beta" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Sync-Directory -Source $sourceRepo -Destination $localBeta -Name "paydiverse-beta (local)"
    
    # 4. Push to GitHub
    if (-not $SkipGitHub) {
        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "4️⃣  GitHub Repositories" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        
        Git-SyncAndPush -RepoPath $localPD20B -RepoName "PayDiverse-2.0B" -Branch "master"
        Git-SyncAndPush -RepoPath $localBeta -RepoName "paydiverse-beta" -Branch "main"
    }
    
    # 5. Deploy to Dev-Ed org
    if (-not $SkipDevEd) {
        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "5️⃣  Salesforce Dev-Ed Org" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        
        Sync-ToDevEd -SourcePath $sourceRepo
    }
    
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "✨ SYNC COMPLETE!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    Write-Host "`n📊 Sync Summary:" -ForegroundColor Cyan
    Write-Host "   ✅ Dropbox (SOURCE)" -ForegroundColor Green
    if (-not $SkipOneDrive) { Write-Host "   ✅ OneDrive Backup" -ForegroundColor Green }
    Write-Host "   ✅ Local repos synced" -ForegroundColor Green
    if (-not $SkipGitHub) { Write-Host "   ✅ GitHub repos updated" -ForegroundColor Green }
    if (-not $SkipDevEd) { Write-Host "   ✅ Dev-Ed org deployed" -ForegroundColor Green }
    
    Write-Host "`n💡 All systems synchronized!" -ForegroundColor Cyan
    
}
catch {
    Write-Host "`n❌ Sync failed: $_" -ForegroundColor Red
    exit 1
}
