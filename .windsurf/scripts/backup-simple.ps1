#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    FitX Database Backup Script
.DESCRIPTION
    Backs up all Firebase Firestore data to local JSON files
.NOTES
    Requires: Node.js, serviceAccountKey.json
    Created: 2024
#>

param()

$ErrorActionPreference = "Stop"

# ANSI colors for output
$Green = "`e[32m"
$Red = "`e[31m"
$Yellow = "`e[33m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

function Write-Success($msg) {
    Write-Host "$Green[OK]$Reset $msg"
}

function Write-Error($msg) {
    Write-Host "$Red[ERROR]$Reset $msg"
}

function Write-Warning($msg) {
    Write-Host "$Yellow[WARN]$Reset $msg"
}

function Write-Info($msg) {
    Write-Host "$Cyan[INFO]$Reset $msg"
}

# Header
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "           FitX Database Backup Tool" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check Node.js
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Error "Node.js is not installed!"
    Write-Host "Download from: https://nodejs.org/"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Success "Node.js found"

# Check service account key
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$serviceKey = Join-Path $scriptDir "serviceAccountKey.json"

if (-not (Test-Path $serviceKey)) {
    Write-Error "serviceAccountKey.json not found!"
    Write-Host "Download from Firebase Console:"
    Write-Host "  Project Settings > Service Accounts > Generate New Private Key"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Success "Service account key found"

# Install dependencies
$nodeModules = Join-Path $scriptDir "node_modules"
if (-not (Test-Path $nodeModules)) {
    Write-Info "Installing dependencies..."
    Set-Location $scriptDir
    npm install firebase-admin 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install dependencies"
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Success "Dependencies installed"
}

Write-Success "All prerequisites met"
Write-Host ""

# Run backup
Write-Host "==============================================================" -ForegroundColor Yellow
Write-Host "Starting backup process..." -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date
Set-Location $scriptDir
node backup_database.js

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Error "Backup failed! Check error messages above."
    Read-Host "Press Enter to exit"
    exit 1
}

$endTime = Get-Date
$duration = $endTime - $startTime

# Summary
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "Backup completed successfully!" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host ""

Write-Info "Summary:"
Write-Host "  Started: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))"
Write-Host "  Duration: $($duration.ToString('hh\:mm\:ss'))"

# Calculate backup size
$folders = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^backup_\d{4}-\d{2}-\d{2}$' }
if ($folders) {
    $latest = $folders | Sort-Object -Descending | Select-Object -First 1
    $backupPath = Join-Path $scriptDir $latest
    $size = (Get-ChildItem $backupPath -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "  Latest backup: $latest"
    Write-Host "  Size: $([math]::Round($size, 2)) MB"
}

Write-Host ""
Write-Warning "IMPORTANT:"
Write-Host "  - Keep this backup secure and encrypted"
Write-Host "  - Store in multiple locations"
Write-Host "  - Do not commit to version control"
Write-Host ""

Read-Host "Press Enter to exit"
