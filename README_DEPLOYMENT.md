# 🚀 PayDiverse 2.0 - Salesforce Deployment Automation

**Version:** 1.0  
**Last Updated:** 2025-11-03  
**Status:** Production-Ready

---

## 📦 What's Included

This package provides complete CI/CD automation for PayDiverse 2.0 Salesforce deployments:

- ✅ **PowerShell Deployment Script** (`Deploy-PayDiverse.ps1`)
- ✅ **GitHub Actions Workflow** (`.github/workflows/salesforce-ci.yml`)
- ✅ **Migration Guide** (`GITHUB_MIGRATION_GUIDE.md`)
- ✅ **Git Configuration** (`.gitignore`)

---

## 🎯 Quick Start

### 1. Local Deployment (Manual)

```powershell
# Validation only (safe)
.\Deploy-PayDiverse.ps1 -CheckOnly

# Full deployment
.\Deploy-PayDiverse.ps1 -TargetOrg dev-ed

# Custom source directory
.\Deploy-PayDiverse.ps1 -SourceDir custom-dir -TestLevel NoTestRun
```

### 2. GitHub CI/CD (Automated)

```powershell
# Push to trigger deployment
git add .
git commit -m "feat: add validation rules"
git push origin main
```

Deployment automatically runs on push to `main` branch.

---

## 📋 Prerequisites


- ✅ **Salesforce CLI** v2.0+ installed (`sf` command)
- ✅ **PowerShell** 7.0+ (for Windows scripts)
- ✅ **Git** installed and configured
- ✅ **Salesforce Org** authenticated (dev-ed alias)
- ✅ **GitHub Account** (for CI/CD)

### Installation

```powershell
# Install Salesforce CLI
npm install -g @salesforce/cli

# Verify installation
sf version

# Authenticate org
sf org login web --alias dev-ed --set-default
```

---

## 🔧 PowerShell Script Usage

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `TargetOrg` | string | dev-ed | Salesforce org alias |
| `SourceDir` | string | force-app | Directory to deploy |
| `TestLevel` | string | RunLocalTests | Test execution level |
| `CheckOnly` | switch | false | Validation only (no deploy) |

### Examples

```powershell
# Validate before deploying
.\Deploy-PayDiverse.ps1 -CheckOnly

# Deploy to specific org
.\Deploy-PayDiverse.ps1 -TargetOrg prod

# Deploy without tests (dev only!)
.\Deploy-PayDiverse.ps1 -TestLevel NoTestRun
```

---


## 🤖 GitHub Actions Workflow

### Automatic Triggers

- ✅ **Push to main** → Deploys to dev-ed org
- ✅ **Pull Request** → Validates metadata
- ✅ **Manual dispatch** → On-demand deployment

### Required Secrets

Add these to GitHub Settings → Secrets → Actions:

1. **`SFDX_AUTH_URL`** - Salesforce authentication URL

Generate auth URL:
```powershell
sf org display --target-org dev-ed --verbose --json | ConvertFrom-Json | Select-Object -ExpandProperty result | Select-Object -ExpandProperty sfdxAuthUrl
```

### Workflow Status

Check deployment status:
- GitHub → Actions tab
- View logs for detailed information
- Green checkmark = successful deployment

---

## 📊 Logs and Monitoring

### Log Files

All deployments create timestamped logs:
```
logs/deploy_20251103_143022.log
```

### Log Contents

- Pre-flight checks
- Deployment progress
- Test results
- Component details
- Error messages (if any)

---

## 🚨 Troubleshooting

### Common Issues


**Issue:** "Org not authenticated"
```powershell
# Solution: Re-authenticate
sf org logout --target-org dev-ed
sf org login web --alias dev-ed --set-default
```

**Issue:** "Test coverage below 75%"
```powershell
# Solution: Check coverage report
sf apex run test --target-org dev-ed --code-coverage --result-format human
```

**Issue:** "Deployment timeout"
```powershell
# Solution: Increase wait time
.\Deploy-PayDiverse.ps1 -Wait 60
```

**Issue:** "GitHub Actions auth fails"
```powershell
# Solution: Regenerate SFDX_AUTH_URL secret
1. Run: sf org display --target-org dev-ed --verbose --json
2. Copy sfdxAuthUrl value
3. Update GitHub secret
```

---

## 📁 File Structure

```
Salesforce_Source/
├── .github/
│   └── workflows/
│       └── salesforce-ci.yml          # CI/CD pipeline
├── force-app/
│   └── main/default/                  # Salesforce metadata
├── logs/                              # Deployment logs
├── Deploy-PayDiverse.ps1              # Deployment script
├── GITHUB_MIGRATION_GUIDE.md          # Migration instructions
├── README_DEPLOYMENT.md               # This file
├── sfdx-project.json                  # SFDX config
└── .gitignore                         # Git exclusions
```

---

## ⚡ Performance Tips


1. **Use -CheckOnly for validation** before deploying
2. **Run tests locally** before pushing to GitHub
3. **Deploy smaller changesets** to reduce risk
4. **Monitor logs** for early error detection
5. **Use feature branches** for experimental work

---

## 🔒 Security Best Practices

- ✅ Never commit `.env` files or credentials
- ✅ Use GitHub secrets for sensitive data
- ✅ Protect `main` branch with required reviews
- ✅ Enable branch protection rules
- ✅ Rotate SFDX_AUTH_URL periodically
- ✅ Review deployment logs for anomalies

---

## 📞 Support

**Documentation:**
- Migration Guide: `GITHUB_MIGRATION_GUIDE.md`
- Project Status: `../../PROJECT_STATUS.md`
- Change Log: `../../CHANGE_LOG.md`

**Team Contacts:**
- Project Owner: JR
- Business Owner: Frank  
- Technical Leads: Rob, Ivy

---

## 📝 Change Log

### v1.0 (2025-11-03)
- ✅ Initial deployment automation setup
- ✅ PowerShell deployment script
- ✅ GitHub Actions CI/CD workflow
- ✅ Comprehensive migration guide

---

**Maintained by:** JR + Claude  
**Status:** Production-Ready  
**Last Updated:** 2025-11-03
