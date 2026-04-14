# FitX Database Backup - PowerShell Script
# هذا السكريبت سهل لعمل backup لقاعدة البيانات على Windows

param(
    [Parameter(Mandatory=$false)]
    [string]$Method = "firebase",  # firebase, firestore-export, or dart
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeStorage = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Compress = $false
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
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

function Write-Error($message) {
    Write-ColorOutput Red "❌ $message"
}

# Header
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "           🔐 FitX Database Backup Tool                        " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check if gcloud CLI is installed
$gcloudInstalled = Get-Command gcloud -ErrorAction SilentlyContinue
if (-not $gcloudInstalled) {
    Write-Warning "gcloud CLI not found. Some features may not work."
    Write-Info "Download from: https://cloud.google.com/sdk/docs/install"
}

# Check Firebase CLI
$firebaseInstalled = Get-Command firebase -ErrorAction SilentlyContinue
if (-not $firebaseInstalled) {
    Write-Warning "Firebase CLI not found. Installing..."
    npm install -g firebase-tools
}

# Check Node.js
$nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeInstalled) {
    Write-Error "Node.js is required but not installed."
    Write-Info "Download from: https://nodejs.org/"
    exit 1
}

Write-Success "Prerequisites check passed"
Write-Host ""

# Set output path
$timestamp = Get-Date -Format "yyyy-MM-dd"
if ([string]::IsNullOrEmpty($OutputPath)) {
    $OutputPath = Join-Path $PSScriptRoot "backup_$timestamp"
}

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Info "Backup will be saved to: $OutputPath"
Write-Host ""

# Login check
Write-Info "Checking Firebase authentication..."
$firebaseLogin = firebase login:list 2>&1
if ($firebaseLogin -match "No authorized accounts") {
    Write-Warning "Not logged in to Firebase. Please login:"
    firebase login
}

# Get current project
$currentProject = firebase use 2>&1 | Select-String "Currently using" | ForEach-Object { $_ -match "Currently using (.+)" | Out-Null; $matches[1] }
if (-not $currentProject) {
    Write-Warning "No Firebase project selected."
    $projects = firebase projects:list 2>&1 | Select-String "fitx"
    Write-Host "Available projects:"
    Write-Host $projects
    $projectId = Read-Host "Enter project ID"
    firebase use $projectId
} else {
    Write-Info "Using Firebase project: $currentProject"
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "                Starting Backup Process...                     " -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date

# Perform backup based on method
switch ($Method) {
    "firebase" {
        Write-Info "Using Firebase Firestore export..."
        
        # Export Firestore
        $exportPath = "gs://${currentProject}-backups/firestore/$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Info "Exporting to: $exportPath"
        
        gcloud firestore export $exportPath --project=$currentProject
        
        # Download export locally
        $localExportPath = Join-Path $OutputPath "firestore_export"
        Write-Info "Downloading export to: $localExportPath"
        gsutil -m cp -r $exportPath $localExportPath
        
        Write-Success "Firestore export completed"
        
        # Export Auth users
        Write-Info "Exporting Firebase Auth users..."
        firebase auth:export (Join-Path $OutputPath "auth_users.json")
        Write-Success "Auth users exported"
    }
    
    "firestore-export" {
        Write-Info "Using firestore-export tool..."
        
        # Check if firestore-export is installed
        $firestoreExport = Get-Command firestore-export -ErrorAction SilentlyContinue
        if (-not $firestoreExport) {
            Write-Info "Installing firestore-export..."
            npm install -g firestore-export
        }
        
        # Run export
        $collections = "users,linkRequests,tasks,workouts,exercises,muscleGroups,foodItems,mealLogs"
        firestore-export --accountCredentials serviceAccountKey.json --backupFile (Join-Path $OutputPath "firestore_backup.json") --nodeList $collections
        
        Write-Success "Firestore export completed"
    }
    
    "dart" {
        Write-Info "Using Dart backup script..."
        
        # Check Dart
        $dartInstalled = Get-Command dart -ErrorAction SilentlyContinue
        if (-not $dartInstalled) {
            Write-Error "Dart SDK not found. Please install Flutter which includes Dart."
            exit 1
        }
        
        # Run Dart script
        Set-Location $PSScriptRoot
        dart backup_database.dart
        
        Write-Success "Dart backup completed"
    }
    
    "node" {
        Write-Info "Using Node.js backup script..."
        
        # Check for service account key
        $serviceAccountPath = Join-Path $PSScriptRoot "serviceAccountKey.json"
        if (-not (Test-Path $serviceAccountPath)) {
            Write-Error "serviceAccountKey.json not found!"
            Write-Info "Download it from Firebase Console > Project Settings > Service Accounts"
            exit 1
        }
        
        # Install dependencies if needed
        if (-not (Test-Path (Join-Path $PSScriptRoot "node_modules"))) {
            Write-Info "Installing dependencies..."
            npm install firebase-admin
        }
        
        # Run Node script
        Set-Location $PSScriptRoot
        node backup_database.js
        
        Write-Success "Node.js backup completed"
    }
    
    default {
        Write-Error "Unknown method: $Method"
        Write-Info "Available methods: firebase, firestore-export, dart, node"
        exit 1
    }
}

# Backup Storage if requested
if ($IncludeStorage) {
    Write-Host ""
    Write-Info "Backing up Firebase Storage..."
    
    $storagePath = Join-Path $OutputPath "storage"
    New-Item -ItemType Directory -Path $storagePath -Force | Out-Null
    
    # Download all storage buckets
    $buckets = gsutil ls 2>&1 | Select-String "gs://${currentProject}"
    foreach ($bucket in $buckets) {
        $bucketName = $bucket -replace "gs://", "" -replace "/", ""
        Write-Info "Downloading bucket: $bucketName"
        
        $bucketLocalPath = Join-Path $storagePath $bucketName
        gsutil -m cp -r $bucket $bucketLocalPath
    }
    
    Write-Success "Storage backup completed"
}

# Compress if requested
if ($Compress) {
    Write-Host ""
    Write-Info "Compressing backup..."
    
    $zipPath = "$OutputPath.zip"
    Compress-Archive -Path $OutputPath -DestinationPath $zipPath -Force
    
    # Get file size
    $zipSize = (Get-Item $zipPath).Length / 1MB
    Write-Success "Backup compressed: $zipPath ($([math]::Round($zipSize, 2)) MB)"
}

# Generate report
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "                ✅ BACKUP COMPLETED!                          " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

$endTime = Get-Date
$duration = $endTime - $startTime

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
Write-Host "  1. Verify backup integrity by checking files"
Write-Host "  2. Copy backup to external storage/cloud"
Write-Host "  3. Store in multiple secure locations"
Write-Host "  4. Test restore process on development environment"

Write-Host ""
Write-ColorOutput Yellow "🔐 SECURITY REMINDER:"
Write-Host "   • This backup contains sensitive user data"
Write-Host "   • Keep it encrypted and secure"
Write-Host "   • Do not share or commit to version control"
Write-Host "   • Comply with data protection regulations"
Write-Host ""

# Offer to open folder
$openFolder = Read-Host "Open backup folder? (Y/n)"
if ($openFolder -ne 'n') {
    Invoke-Item $OutputPath
}
