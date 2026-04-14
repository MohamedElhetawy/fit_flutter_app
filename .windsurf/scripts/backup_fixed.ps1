# FitX Database Backup - PowerShell Script
# Requires: PowerShell 5.1 or later

param(
    [Parameter(Mandatory=$false)]
    [string]$Method = "node",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeStorage = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Compress = $false
)

$ErrorActionPreference = "Stop"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) { Write-Output $args }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success($message) {
    Write-ColorOutput Green "✅ $message"
}

function Write-Info($message) {
    Write-ColorOutput Cyan "ℹ️  $message"
}

function Write-Warning($message) {
    Write-ColorOutput Yellow "⚠️  $message"
}

function Write-ErrorColored($message) {
    Write-ColorOutput Red "❌ $message"
}

# Header
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "           🔐 FitX Database Backup Tool                        " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check Node.js
$nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeInstalled) {
    Write-ErrorColored "Node.js is not installed!"
    Write-Info "Please install from: https://nodejs.org/"
    exit 1
}
Write-Success "Node.js found"

# Check service account key
$serviceAccountPath = Join-Path $PSScriptRoot "serviceAccountKey.json"
if (-not (Test-Path $serviceAccountPath)) {
    Write-ErrorColored "serviceAccountKey.json not found!"
    Write-Info "Download from Firebase Console > Settings > Service Accounts"
    exit 1
}
Write-Success "Service account key found"

# Set output path
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
if ([string]::IsNullOrEmpty($OutputPath)) {
    $OutputPath = Join-Path $PSScriptRoot "backup_$timestamp"
}

Write-Info "Backup will be saved to: $OutputPath"
Write-Host ""

# Check dependencies
if (-not (Test-Path (Join-Path $PSScriptRoot "node_modules"))) {
    Write-Info "Installing dependencies..."
    Set-Location $PSScriptRoot
    npm install firebase-admin
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorColored "Failed to install dependencies"
        exit 1
    }
}
Write-Success "Dependencies ready"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "                Starting Backup Process...                     " -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date

# Run Node.js backup
Set-Location $PSScriptRoot
node backup_database.js

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-ErrorColored "Backup failed!"
    exit 1
}

$endTime = Get-Date
$duration = $endTime - $startTime

# Generate report
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "                ✅ BACKUP COMPLETED!                          " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Write-Info "Backup Summary:"
Write-Host "  📅 Date: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))"
Write-Host "  ⏱️  Duration: $($duration.ToString('hh\:mm\:ss'))"
Write-Host "  📁 Location: $OutputPath"

# Get backup size
if (Test-Path $OutputPath) {
    $folderSize = (Get-ChildItem $OutputPath -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "  💾 Size: $([math]::Round($folderSize, 2)) MB"
}

Write-Host ""
Write-Info "Next Steps:"
Write-Host "  1. Verify backup integrity"
Write-Host "  2. Copy to external storage/cloud"
Write-Host "  3. Store in multiple locations"
Write-Host "  4. Test restore process"

Write-Host ""
Write-ColorOutput Yellow "🔐 SECURITY REMINDER:"
Write-Host "   • Keep this backup secure"
Write-Host "   • Do not commit to Git"
Write-Host "   • Store in multiple locations"
Write-Host ""

# Ask to open folder
$response = Read-Host "Open backup folder? (Y/n)"
if ($response -ne 'n' -and $response -ne 'N') {
    Invoke-Item $OutputPath
}
