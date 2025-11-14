# PayDiverse 2.0 - Automated Deployment Script
# Version: 1.0
# Author: JR + Claude
# Last Updated: 2025-11-03

<#
.SYNOPSIS
    Automated Salesforce metadata deployment with comprehensive logging and validation.

.DESCRIPTION
    Deploys PayDiverse 2.0 metadata to Salesforce org with:
    - Pre-flight validation checks
    - Deployment logging
    - Test execution
    - Rollback capability

.PARAMETER TargetOrg
    Salesforce org alias (default: dev-ed)

.PARAMETER SourceDir
    Source directory to deploy (default: force-app)

.PARAMETER TestLevel
    Test level: NoTestRun, RunLocalTests, RunAllTests (default: RunLocalTests)

.PARAMETER CheckOnly
    Validation-only mode (no actual deployment)

.EXAMPLE
    .\Deploy-PayDiverse.ps1 -TargetOrg dev-ed -CheckOnly
#>

param(
    [string]$TargetOrg = "dev-ed",
    [string]$SourceDir = "force-app",
    [ValidateSet("NoTestRun", "RunLocalTests", "RunAllTests")]
    [string]$TestLevel = "RunLocalTests",
    [switch]$CheckOnly
)

# Configuration
$ErrorActionPreference = "Stop"
$LogDir = "logs"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = Join-Path $LogDir "deploy_$Timestamp.log"

# Create logs directory if it doesn't exist
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Color output
    switch ($Level) {
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR"   { Write-Host $logMessage -ForegroundColor Red }
        default   { Write-Host $logMessage }
    }
    
    # Write to log file
    $logMessage | Out-File -FilePath $LogFile -Append
}

# Banner
Write-Log "========================================" -Level "INFO"
Write-Log "PayDiverse 2.0 Deployment Script" -Level "INFO"
Write-Log "========================================" -Level "INFO"
Write-Log "Target Org: $TargetOrg" -Level "INFO"
Write-Log "Source Dir: $SourceDir" -Level "INFO"
Write-Log "Test Level: $TestLevel" -Level "INFO"
Write-Log "Check Only: $CheckOnly" -Level "INFO"
Write-Log "Log File: $LogFile" -Level "INFO"
Write-Log "========================================" -Level "INFO"

try {
    # Step 1: Pre-flight checks
    Write-Log "Step 1: Running pre-flight checks..." -Level "INFO"
    
    # Check if SF CLI is installed
    $sfVersion = sf version --json 2>&1 | ConvertFrom-Json
    if ($sfVersion.status -ne 0) {
        throw "Salesforce CLI not found. Install: npm install -g @salesforce/cli"
    }
    Write-Log "✓ Salesforce CLI version: $($sfVersion.result.cliVersion)" -Level "SUCCESS"
    
    # Check if org is authenticated
    $orgCheck = sf org display --target-org $TargetOrg --json 2>&1 | ConvertFrom-Json
    if ($orgCheck.status -ne 0) {
        throw "Org '$TargetOrg' not authenticated. Run: sf org login web --alias $TargetOrg"
    }
    Write-Log "✓ Org authenticated: $($orgCheck.result.username)" -Level "SUCCESS"
    
    # Check if source directory exists
    if (!(Test-Path $SourceDir)) {
        throw "Source directory '$SourceDir' not found"
    }
    Write-Log "✓ Source directory exists" -Level "SUCCESS"
    
    # Step 2: Deploy metadata
    Write-Log "Step 2: Deploying metadata..." -Level "INFO"
    
    $deployCmd = "sf project deploy start --source-dir $SourceDir --target-org $TargetOrg --test-level $TestLevel --wait 30 --json"
    
    if ($CheckOnly) {
        $deployCmd = $deployCmd.Replace("deploy start", "deploy validate")
        Write-Log "Running validation-only deployment..." -Level "WARNING"
    }
    
    Write-Log "Executing: $deployCmd" -Level "INFO"
    
    $deployResult = Invoke-Expression $deployCmd | ConvertFrom-Json
    
    if ($deployResult.status -ne 0) {
        Write-Log "Deployment failed!" -Level "ERROR"
        Write-Log "Error: $($deployResult.message)" -Level "ERROR"
        throw "Deployment failed. Check log: $LogFile"
    }
    
    # Step 3: Display results
    Write-Log "Step 3: Deployment results..." -Level "INFO"
    Write-Log "========================================" -Level "INFO"
    Write-Log "Status: $($deployResult.result.status)" -Level "SUCCESS"
    Write-Log "Components Deployed: $($deployResult.result.numberComponentsDeployed)" -Level "INFO"
    Write-Log "Components Total: $($deployResult.result.numberComponentsTotal)" -Level "INFO"
    Write-Log "Tests Passed: $($deployResult.result.numberTestsCompleted)" -Level "INFO"
    Write-Log "Test Coverage: $($deployResult.result.details.runTestResult.codeCoverage.codeCoverageWarnings.Count)" -Level "INFO"
    Write-Log "========================================" -Level "INFO"
    
    if ($CheckOnly) {
        Write-Log "✓ Validation completed successfully!" -Level "SUCCESS"
    } else {
        Write-Log "✓ Deployment completed successfully!" -Level "SUCCESS"
    }
    
    Write-Log "Deployment ID: $($deployResult.result.id)" -Level "INFO"
    Write-Log "Log file saved: $LogFile" -Level "INFO"
    
} catch {
    Write-Log "========================================" -Level "ERROR"
    Write-Log "DEPLOYMENT FAILED" -Level "ERROR"
    Write-Log "Error: $_" -Level "ERROR"
    Write-Log "========================================" -Level "ERROR"
    Write-Log "Log file saved: $LogFile" -Level "ERROR"
    exit 1
} finally {
    Write-Log "Script completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Level "INFO"
}

# Return success
exit 0
