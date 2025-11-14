# PayDiverse Sync System - SOURCE OF TRUTH: DROPBOX

## 🎯 System Architecture

```
                    ┌─────────────────────┐
                    │   DROPBOX SOURCE    │ ← YOU WORK HERE
                    │  PayDiverse-Source  │
                    └──────────┬──────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ▼              ▼              ▼
        ┌───────────┐  ┌────────────┐  ┌──────────┐
        │  OneDrive │  │   GitHub   │  │  Dev-Ed  │
        │  (Backup) │  │ (2 repos)  │  │   Org    │
        └───────────┘  └────────────┘  └──────────┘
                              │
                    ┌─────────┴─────────┐
                    ▼                   ▼
            PayDiverse-2.0B      paydiverse-beta
               (master)              (main)
```

## 📍 SOURCE OF TRUTH

**Primary Location**: `C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source`

**⚠️ IMPORTANT**: Always make your changes in the Dropbox folder!

## 🔄 How Sync Works

### Automatic Sync
When you save changes in Dropbox, they automatically propagate to:
1. ✅ **OneDrive** - Full backup copy
2. ✅ **GitHub PayDiverse-2.0B** - Main repo (master branch)
3. ✅ **GitHub paydiverse-beta** - Beta repo (main branch)
4. ✅ **Salesforce Dev-Ed Org** - Live deployment

### Sync Methods

#### Option 1: Auto-Watcher (Recommended)
Automatically detects changes and syncs:
```powershell
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
.\Auto-Sync-Watcher.ps1
```
Leave this running in the background. It will:
- Watch for file changes
- Wait 5 seconds after last change (debounce)
- Automatically run full sync

#### Option 2: Manual Sync
Run sync manually when you want:
```powershell
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
.\Master-Sync.ps1
```

#### Option 3: Selective Sync
Skip certain destinations:
```powershell
# Skip GitHub
.\Master-Sync.ps1 -SkipGitHub

# Skip OneDrive
.\Master-Sync.ps1 -SkipOneDrive

# Skip Dev-Ed deployment
.\Master-Sync.ps1 -SkipDevEd

# Combine flags
.\Master-Sync.ps1 -SkipGitHub -SkipDevEd
```

## 📝 Development Workflow

### Daily Workflow
```powershell
# 1. Open VS Code in Dropbox source
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
code .

# 2. (Optional) Start auto-watcher in another terminal
.\Auto-Sync-Watcher.ps1

# 3. Make your changes in VS Code
#    - Edit Apex classes
#    - Modify objects
#    - Update workflows
#    - etc.

# 4. Save files (Ctrl+S)
#    → Auto-watcher detects changes
#    → Waits 5 seconds for more changes
#    → Automatically syncs everything!

# 5. (If not using auto-watcher) Run manual sync
.\Master-Sync.ps1
```

### What Gets Synced Where

| Location | Purpose | Auto-Sync | Branch |
|----------|---------|-----------|--------|
| **Dropbox** | SOURCE - Work here | N/A | N/A |
| OneDrive | Backup copy | ✅ Yes | N/A |
| GitHub PayDiverse-2.0B | Version control | ✅ Yes | master |
| GitHub paydiverse-beta | Version control | ✅ Yes | main |
| Dev-Ed Org | Live Salesforce | ✅ Yes | N/A |
| Local `~/PayDiverse-2.0B` | Working copy | ✅ Yes | master |
| Local `~/paydiverse-beta` | Working copy | ✅ Yes | main |

## 🛠️ System Files

### Sync Scripts
- **Master-Sync.ps1** - Main sync orchestrator
- **Auto-Sync-Watcher.ps1** - File system watcher for auto-sync

### Locations
```
Dropbox Source:
C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source

OneDrive Backup:
C:\Users\jresn\OneDrive\2.0 PayDiverse\PayDiverse-2.0B-DevEd-Backup

Local Copies:
C:\Users\jresn\PayDiverse-2.0B
C:\Users\jresn\paydiverse-beta
```

## 🔐 Salesforce Integration

### Dev-Ed Org
- **Org**: dev-ed
- **Username**: jeremybresnick306@agentforce.com
- **Auto-Deploy**: Yes (when Master-Sync runs)
- **Deploy Command**: `sf project deploy start --target-org dev-ed --source-dir force-app`

### Manual Deploy (if needed)
```powershell
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
sf project deploy start --target-org dev-ed --source-dir force-app
```

### Retrieve from Dev-Ed
```powershell
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
sf project retrieve start --target-org dev-ed --manifest manifest/package.xml
```

## 📊 GitHub Integration

### Repository Links
- **PayDiverse-2.0B**: https://github.com/jeremybresnick-commits/PayDiverse-2.0B
- **paydiverse-beta**: https://github.com/jeremybresnick-commits/paydiverse-beta

### Manual Git Operations
```powershell
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"

# Check status
git status

# Commit manually
git add .
git commit -m "Your message"

# Push to both repos (done by Master-Sync)
cd C:\Users\jresn\PayDiverse-2.0B
git push origin master

cd C:\Users\jresn\paydiverse-beta
git push origin main
```

## ⚡ Quick Commands

### Start Auto-Sync
```powershell
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
.\Auto-Sync-Watcher.ps1
```

### Manual Sync Everything
```powershell
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
.\Master-Sync.ps1
```

### Open in VS Code
```powershell
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
code .
```

### Check Sync Status
```powershell
# Check GitHub repos
gh repo view jeremybresnick-commits/PayDiverse-2.0B
gh repo view jeremybresnick-commits/paydiverse-beta

# Check Salesforce org
sf org display --target-org dev-ed
```

## 🎨 VS Code Setup

Open Dropbox source in VS Code:
```powershell
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
code .
```

Recommended Extensions:
- Salesforce Extension Pack
- GitLens
- PowerShell

## 🔍 Troubleshooting

### Sync Not Working
```powershell
# Run manual sync with verbose output
cd "C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source"
.\Master-Sync.ps1 -Verbose
```

### GitHub Push Fails
```powershell
# Check GitHub authentication
gh auth status

# Re-authenticate if needed
gh auth login
```

### Salesforce Deploy Fails
```powershell
# Check org connection
sf org display --target-org dev-ed

# Re-authenticate if needed
sf org login web --alias dev-ed
```

### Dropbox Not Syncing
1. Check Dropbox app is running
2. Verify folder is syncing (green checkmark)
3. Check Dropbox storage space

## 📅 Scheduled Auto-Sync (Optional)

To run sync every hour automatically:
```powershell
# Create scheduled task (run as Administrator)
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-Source\Master-Sync.ps1`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration ([TimeSpan]::MaxValue)
Register-ScheduledTask -TaskName "PayDiverse Auto-Sync" -Action $action -Trigger $trigger -Description "Auto-sync PayDiverse from Dropbox"
```

---

**Last Updated**: 2025-11-14  
**Setup**: GitHub Copilot CLI  
**Source**: Dropbox

## 🎯 Remember

**✅ DO**: Work in Dropbox  
**❌ DON'T**: Edit in OneDrive, GitHub, or local folders  
**💡 TIP**: Use Auto-Sync-Watcher for hands-free syncing!
