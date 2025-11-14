# 🚀 PayDiverse 2.0 - GitHub Migration Guide

**Status:** Google Drive → GitHub Migration  
**Target Repo:** `paydiverse-sf-v2`  
**Project Root:** `2_PayDiverse_2.0_New_System/Salesforce_Source/`

---

## 📋 Pre-Migration Checklist

- [x] SFDX project structure verified
- [x] `.gitignore` created
- [x] GitHub Actions workflow configured
- [ ] GitHub repository created
- [ ] SSH/HTTPS authentication configured
- [ ] Initial commit pushed

---

## 🛠️ Step 1: Initialize Git Repository

```powershell
# Navigate to Salesforce Source directory
cd "C:\Users\jresn\Google Drive Streaming\My Drive\PayDiverse_Organized\2_PayDiverse_2.0_New_System\Salesforce_Source"

# Initialize Git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: PayDiverse 2.0 BETA Foundation"
```

---

## 🔗 Step 2: Connect to GitHub Repository

### Option A: HTTPS (Recommended for Windows)

```powershell
# Set remote origin
git remote add origin https://github.com/snlckcommits/paydiverse-sf-v2.git

# Push to main branch
git branch -M main
git push -u origin main
```

### Option B: SSH (If configured)

```powershell
git remote add origin git@github.com:snlckcommits/paydiverse-sf-v2.git
git branch -M main
git push -u origin main
```

---

## 🔐 Step 3: Configure GitHub Secrets for CI/CD

Required secrets for GitHub Actions workflow:

### 3.1 Generate SFDX Auth URL

```powershell
# Authorize dev-ed org (if not already)
sf org login web --alias dev-ed --set-default

# Generate auth URL
sf org display --target-org dev-ed --verbose --json | ConvertFrom-Json | Select-Object -ExpandProperty result | Select-Object -ExpandProperty sfdxAuthUrl
```


### 3.2 Add Secret to GitHub

1. Go to: `https://github.com/snlckcommits/paydiverse-sf-v2/settings/secrets/actions`
2. Click **"New repository secret"**
3. Name: `SFDX_AUTH_URL`
4. Value: Paste the auth URL from above
5. Click **"Add secret"**

---

## 🔄 Step 4: Workflow Management

### Trigger Deployment

**Automatic (on push to main):**
```powershell
git add .
git commit -m "feat: deploy validation rules"
git push origin main
```

**Manual (via GitHub UI):**
1. Go to: Actions tab
2. Select "Salesforce CI/CD Pipeline"
3. Click "Run workflow"
4. Select branch and click "Run workflow"

---

## 📦 Step 5: Branch Strategy

### Recommended Structure

```
main (protected)
├── develop (daily work)
├── feature/validation-rules
├── feature/email-templates
└── hotfix/sertifi-field-fix
```

### Branch Protection Rules


1. Go to: Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require pull request reviews
   - ✅ Require status checks to pass (select: validate)
   - ✅ Include administrators

---

## ✅ Step 6: Validation Checklist

After migration, verify:

```powershell
# 1. Check Git status
git status
git remote -v

# 2. Verify SFDX project
sf project deploy validate --source-dir force-app --target-org dev-ed

# 3. Test local deployment
sf project deploy start --source-dir force-app --target-org dev-ed --dry-run

# 4. Check GitHub Actions
# Visit: https://github.com/snlckcommits/paydiverse-sf-v2/actions
```

---

## 🚨 Emergency Rollback

If deployment fails:

```powershell
# Revert last commit
git revert HEAD
git push origin main

# Or force rollback to specific commit
git reset --hard <commit-hash>
git push origin main --force
```

---

## 📝 Daily Workflow


### Morning Routine

```powershell
# 1. Pull latest changes
git pull origin main

# 2. Create feature branch
git checkout -b feature/your-feature-name

# 3. Make changes in force-app/

# 4. Test locally
sf project deploy validate --source-dir force-app --target-org dev-ed
```

### End of Day

```powershell
# 1. Stage changes
git add .

# 2. Commit with descriptive message
git commit -m "feat: add validation rules for Application__c"

# 3. Push to feature branch
git push origin feature/your-feature-name

# 4. Create Pull Request on GitHub
# Review → Merge to main (triggers CI/CD)
```

---

## 🔧 Troubleshooting

### Issue: Auth URL generation fails

```powershell
# Re-authenticate
sf org logout --target-org dev-ed
sf org login web --alias dev-ed --set-default
```

### Issue: GitHub Actions workflow fails

1. Check workflow logs in Actions tab
2. Verify `SFDX_AUTH_URL` secret is set correctly
3. Ensure test classes have sufficient coverage (>75%)


### Issue: Merge conflicts

```powershell
# 1. Fetch latest main
git fetch origin main

# 2. Merge main into your feature branch
git merge origin/main

# 3. Resolve conflicts in files
# 4. Stage resolved files
git add .

# 5. Complete merge
git commit -m "chore: resolve merge conflicts"
```

---

## 📚 Useful Links

- **GitHub Repo:** https://github.com/snlckcommits/paydiverse-sf-v2
- **Actions:** https://github.com/snlckcommits/paydiverse-sf-v2/actions
- **Salesforce CLI Docs:** https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/
- **Project Status:** [Link to PROJECT_STATUS.md in repo]

---

## 🎯 Next Steps After Migration

1. ✅ Complete initial push to GitHub
2. ✅ Configure branch protection on `main`
3. ✅ Set up `SFDX_AUTH_URL` secret
4. ✅ Test CI/CD pipeline with dummy commit
5. ⬜ Train team on Git workflow
6. ⬜ Document custom deployment scripts
7. ⬜ Archive Google Drive (keep as backup)

---

**Last Updated:** 2025-11-03  
**Author:** JR + Claude  
**Version:** 1.0
