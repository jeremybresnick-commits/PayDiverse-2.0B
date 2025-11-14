# PayDiverse Repository Sync Script
# Keeps PayDiverse-2.0B and paydiverse-beta in sync locally

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("ToB", "ToBeta", "Both")]
    [string]$Direction = "Both"
)

$pd20bPath = "C:\Users\jresn\PayDiverse-2.0B"
$betaPath = "C:\Users\jresn\paydiverse-beta"

Write-Host "🔄 PayDiverse Repository Sync" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

function Sync-Repos {
    param(
        [string]$Source,
        [string]$Dest,
        [string]$Name
    )
    
    Write-Host "`n📁 Syncing: $Name" -ForegroundColor Yellow
    
    # Use robocopy to sync files (exclude .git directories)
    $result = robocopy $Source $Dest /MIR /XD .git /XF .gitignore /MT:8 /R:1 /W:1 /NFL /NDL /NJH /NJS
    
    if ($LASTEXITCODE -le 7) {
        Write-Host "✅ Sync completed successfully" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Sync completed with warnings (Exit code: $LASTEXITCODE)" -ForegroundColor Yellow
    }
}

try {
    switch ($Direction) {
        "ToB" {
            Sync-Repos -Source $betaPath -Dest $pd20bPath -Name "paydiverse-beta → PayDiverse-2.0B"
        }
        "ToBeta" {
            Sync-Repos -Source $pd20bPath -Dest $betaPath -Name "PayDiverse-2.0B → paydiverse-beta"
        }
        "Both" {
            Write-Host "`n🔀 Performing bidirectional sync..." -ForegroundColor Cyan
            Sync-Repos -Source $betaPath -Dest $pd20bPath -Name "paydiverse-beta → PayDiverse-2.0B"
            Sync-Repos -Source $pd20bPath -Dest $betaPath -Name "PayDiverse-2.0B → paydiverse-beta"
        }
    }
    
    Write-Host "`n✨ Sync complete!" -ForegroundColor Green
    Write-Host "`n💡 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Review changes in both repos"
    Write-Host "   2. Commit and push to trigger GitHub Actions sync"
    Write-Host "   3. Run: cd $pd20bPath; git add .; git commit -m 'Sync changes'; git push"
    Write-Host "   4. Run: cd $betaPath; git add .; git commit -m 'Sync changes'; git push"
    
} catch {
    Write-Host "❌ Error during sync: $_" -ForegroundColor Red
    exit 1
}
