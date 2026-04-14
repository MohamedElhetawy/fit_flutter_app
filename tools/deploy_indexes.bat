@echo off
echo ==========================================
echo FitX Firebase Indexes Deployment
echo ==========================================
echo.

REM Check if firebase CLI is installed
firebase --version >nul 2>&1
if errorlevel 1 (
    echo Firebase CLI not found. Installing...
    echo.
    
    REM Install Firebase CLI using npm
    call npm install -g firebase-tools
    
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install Firebase CLI
        echo Please install manually: npm install -g firebase-tools
        pause
        exit /b 1
    )
    
    echo Firebase CLI installed successfully!
    echo.
)

echo Logging in to Firebase...
call firebase login
if errorlevel 1 (
    echo.
    echo ERROR: Login failed
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Deploying Firestore indexes...
echo ==========================================
cd /d "%~dp0.."

firebase deploy --only firestore:indexes

if errorlevel 1 (
    echo.
    echo ERROR: Deployment failed
    echo Check the error message above
    pause
    exit /b 1
)

echo.
echo ==========================================
echo SUCCESS! Indexes deployed!
echo ==========================================
pause
