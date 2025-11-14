# PayDiverse Repository Mirroring

This document explains the bidirectional sync setup between PayDiverse-2.0B and paydiverse-beta.

## 🔗 Repository Links

- **PayDiverse-2.0B**: https://github.com/jeremybresnick-commits/PayDiverse-2.0B
  - Branch: `master`
  - Purpose: Main Salesforce metadata repository
  
- **paydiverse-beta**: https://github.com/jeremybresnick-commits/paydiverse-beta
  - Branch: `main`
  - Purpose: Agent skills, CI/CD, deployment automation

## 🔄 How Mirroring Works

### Automatic Sync (GitHub Actions)

Both repositories have GitHub Actions workflows that automatically sync changes:

1. **When you push to PayDiverse-2.0B (master)**:
   - Workflow: `.github/workflows/sync-to-beta.yml`
   - Action: Automatically pushes changes to paydiverse-beta (main)

2. **When you push to paydiverse-beta (main)**:
   - Workflow: `.github/workflows/sync-to-pd20b.yml`
   - Action: Automatically pushes changes to PayDiverse-2.0B (master)

### Manual Local Sync

Use the sync script for local development:

```powershell
# Sync both ways (recommended)
C:\Users\jresn\Sync-PayDiverse.ps1

# Sync only to PayDiverse-2.0B
C:\Users\jresn\Sync-PayDiverse.ps1 -Direction ToB

# Sync only to paydiverse-beta
C:\Users\jresn\Sync-PayDiverse.ps1 -Direction ToBeta
```

## 📝 Development Workflow

### Working in PayDiverse-2.0B

```powershell
cd C:\Users\jresn\PayDiverse-2.0B

# Make your changes to Salesforce metadata
# ... edit files ...

# Commit and push (triggers auto-sync to paydiverse-beta)
git add .
git commit -m "Updated Application object fields"
git push origin master
```

### Working in paydiverse-beta

```powershell
cd C:\Users\jresn\paydiverse-beta

# Make your changes to automation/scripts
# ... edit files ...

# Commit and push (triggers auto-sync to PayDiverse-2.0B)
git add .
git commit -m "Updated CI workflow"
git push origin main
```

## 🎯 Best Practices

1. **Always pull before making changes**:
   ```powershell
   git pull origin master  # in PayDiverse-2.0B
   git pull origin main    # in paydiverse-beta
   ```

2. **Run local sync if working offline**:
   ```powershell
   C:\Users\jresn\Sync-PayDiverse.ps1
   ```

3. **Check both repos after sync**:
   - Changes in one repo should appear in the other within ~2 minutes (GitHub Actions)

4. **Resolve conflicts manually**:
   - If conflicts occur, edit files in either repo
   - Run sync script to propagate fixes
   - Commit and push from both repos

## 📂 Local Paths

- PayDiverse-2.0B: `C:\Users\jresn\PayDiverse-2.0B`
- paydiverse-beta: `C:\Users\jresn\paydiverse-beta`
- Sync Script: `C:\Users\jresn\Sync-PayDiverse.ps1`

## 🔧 Backup Locations

Your code is also backed up in:
1. **OneDrive**: `C:\Users\jresn\OneDrive\2.0 PayDiverse\PayDiverse-2.0B-DevEd-Backup`
2. **Dropbox**: `C:\Users\jresn\PayDiverse Dropbox\Jeremy Resnick\PayDiverse-2.0B-DevEd-Backup`

## ⚙️ Troubleshooting

### Sync not working on GitHub

1. Check GitHub Actions:
   - Go to repo → Actions tab
   - Look for failed workflows

2. Verify workflows exist:
   - PayDiverse-2.0B: `.github/workflows/sync-to-beta.yml`
   - paydiverse-beta: `.github/workflows/sync-to-pd20b.yml`

### Local sync issues

1. Run sync script manually:
   ```powershell
   C:\Users\jresn\Sync-PayDiverse.ps1
   ```

2. Check for permission issues:
   ```powershell
   Get-Acl C:\Users\jresn\PayDiverse-2.0B
   Get-Acl C:\Users\jresn\paydiverse-beta
   ```

## 📊 Current Status

- ✅ Bidirectional sync configured
- ✅ GitHub Actions workflows deployed
- ✅ Local sync script created
- ✅ Both repos fully synchronized
- ✅ Backups in OneDrive and Dropbox

---

**Last Updated**: 2025-11-14
**Setup by**: GitHub Copilot CLI
