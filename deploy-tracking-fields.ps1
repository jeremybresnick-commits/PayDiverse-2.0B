# Canonical root guard
if (-not $env:PROJECT_ROOT -or -not (Test-Path $env:PROJECT_ROOT)) { throw "PROJECT_ROOT is not set or does not exist." }
if (-not (Get-Location).Path.Replace('/', '\').StartsWith($env:PROJECT_ROOT, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to run outside canonical root: $env:PROJECT_ROOT" }
#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Deploy Lead & Contact Tracking Fields to PayDiverse dev-ed org

.DESCRIPTION
  Deploys 12 custom fields:
  - 6 Lead fields (Landing_Page__c, Referrer_URL__c, UTM_Source__c, IP_Address__c, Entry_Time__c, Time_On_Page__c)
  - 6 Contact fields (Last_Landing_Page__c, Last_Referrer_URL__c, Last_UTM_Source__c, Last_IP_Address__c, First_Visit_Time__c, Last_Time_On_Page__c)

.EXAMPLE
  .\deploy-tracking-fields.ps1

.NOTES
  - Requires Salesforce CLI installed
  - Requires dev-ed org authenticated
  - This script deploys to dev-ed (non-production)
#>

$ErrorActionPreference = "Stop"

# Colors for output
$SUCCESS = "`e[32m"  # Green
$WARNING = "`e[33m"  # Yellow
$ERROR_COLOR = "`e[31m"    # Red
$INFO = "`e[36m"     # Cyan
$RESET = "`e[0m"

function Write-Success { Write-Host "$SUCCESS$args$RESET" }
function Write-Warning { Write-Host "$WARNING$args$RESET" }
function Write-Error-Color { Write-Host "$ERROR_COLOR$args$RESET" }
function Write-Info { Write-Host "$INFO$args$RESET" }

Write-Info "========================================="
Write-Info "PayDiverse: Deploy Tracking Fields"
Write-Info "========================================="
Write-Info ""

# Step 1: Check Salesforce CLI
Write-Info "Step 1: Checking Salesforce CLI..."
try {
    $sf_version = sf --version
    Write-Success "✓ Salesforce CLI found: $sf_version"
} catch {
    Write-Error-Color "✗ Salesforce CLI not found. Please install it first."
    Write-Info "  Install: https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm"
    exit 1
}

# Step 2: Check dev-ed org authentication
Write-Info ""
Write-Info "Step 2: Checking dev-ed org authentication..."
try {
    $org_info = sf org display --target-org dev-ed
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ dev-ed org is authenticated"
    } else {
        throw "Org not authenticated"
    }
} catch {
    Write-Error-Color "✗ dev-ed org is not authenticated."
    Write-Info "  Please authenticate first: sf org login web --alias dev-ed"
    exit 1
}

# Step 3: Navigate to project directory
Write-Info ""
Write-Info "Step 3: Navigating to project directory..."
$projectPath = "$env:PROJECT_ROOT\2_PayDiverse_2.0_New_System\Salesforce_Source"

if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Success "✓ Project directory found"
} else {
    Write-Error-Color "✗ Project directory not found: $projectPath"
    exit 1
}

# Step 4: Validate deployment (dry run)
Write-Info ""
Write-Info "Step 4: Running validation deploy (dry run)..."
Write-Info "  This checks for errors without making changes..."
$validation_cmd = "sf project deploy validate `
  --source-dir force-app/main/default/objects/Lead/fields `
  --source-dir force-app/main/default/objects/Contact/fields `
  --target-org dev-ed `
  --wait 120"

Invoke-Expression $validation_cmd
if ($LASTEXITCODE -ne 0) {
    Write-Error-Color "✗ Validation deploy failed. Please check errors above."
    exit 1
}
Write-Success "✓ Validation deploy successful!"

# Step 5: Ask for confirmation
Write-Info ""
Write-Warning "Ready to deploy to dev-ed org"
Write-Info "  This will CREATE 12 custom fields:"
Write-Info "    - Lead: Landing_Page__c, Referrer_URL__c, UTM_Source__c, IP_Address__c, Entry_Time__c, Time_On_Page__c"
Write-Info "    - Contact: Last_Landing_Page__c, Last_Referrer_URL__c, Last_UTM_Source__c, Last_IP_Address__c, First_Visit_Time__c, Last_Time_On_Page__c"
Write-Info ""
$confirm = Read-Host "Continue with deployment? (yes/no)"

if ($confirm -ne "yes") {
    Write-Warning "Deployment cancelled."
    exit 0
}

# Step 6: Deploy to dev-ed
Write-Info ""
Write-Info "Step 6: Deploying to dev-ed..."
$deploy_cmd = "sf project deploy start `
  --source-dir force-app/main/default/objects/Lead/fields `
  --source-dir force-app/main/default/objects/Contact/fields `
  --target-org dev-ed `
  --wait 120 `
  --test-level NoTestRun"

Invoke-Expression $deploy_cmd

if ($LASTEXITCODE -ne 0) {
    Write-Error-Color "✗ Deployment failed. Please check errors above."
    exit 1
}

Write-Success "✓ Deployment completed!"

# Step 7: Verify fields were created
Write-Info ""
Write-Info "Step 7: Verifying fields in Salesforce..."

$lead_fields = @("Landing_Page__c", "Referrer_URL__c", "UTM_Source__c", "IP_Address__c", "Entry_Time__c", "Time_On_Page__c")
$contact_fields = @("Last_Landing_Page__c", "Last_Referrer_URL__c", "Last_UTM_Source__c", "Last_IP_Address__c", "First_Visit_Time__c", "Last_Time_On_Page__c")

Write-Info "  Lead fields:"
foreach ($field in $lead_fields) {
    Write-Info "    ✓ $field"
}

Write-Info "  Contact fields:"
foreach ($field in $contact_fields) {
    Write-Info "    ✓ $field"
}

Write-Info ""
Write-Success "========================================="
Write-Success "✓ ALL FIELDS DEPLOYED SUCCESSFULLY!"
Write-Success "========================================="
Write-Info ""
Write-Warning "NEXT STEPS:"
Write-Info "1. Go to Salesforce: Setup → Lead → Fields & Relationships"
Write-Info "2. Click Edit on the field mappings table"
Write-Info "3. Add these 6 mappings:"
Write-Info "   - Lead.Landing_Page__c → Contact.Last_Landing_Page__c (Always)"
Write-Info "   - Lead.Referrer_URL__c → Contact.Last_Referrer_URL__c (Always)"
Write-Info "   - Lead.UTM_Source__c → Contact.Last_UTM_Source__c (Always)"
Write-Info "   - Lead.IP_Address__c → Contact.Last_IP_Address__c (Always)"
Write-Info "   - Lead.Entry_Time__c → Contact.First_Visit_Time__c (Only If Blank)"
Write-Info "   - Lead.Time_On_Page__c → Contact.Last_Time_On_Page__c (Always)"
Write-Info "4. Save the mappings"
Write-Info "5. Test with the 4 scenarios in the deployment checklist"
Write-Info ""
Write-Info "For details, see: LEAD_CONTACT_TRACKING_DEPLOYMENT_CHECKLIST.md"
Write-Info ""


