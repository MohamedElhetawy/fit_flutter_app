@echo off
chcp 65001 >nul
title FitX Database Backup
color 0A

echo.
echo ==============================================================
echo            FitX Database Backup Tool
echo ==============================================================
echo.

REM Check for Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed!
    echo Please install from: https://nodejs.org/
    pause
    exit /b 1
)

echo [OK] Node.js found

REM Check for serviceAccountKey.json
if not exist "serviceAccountKey.json" (
    echo [ERROR] serviceAccountKey.json not found!
    echo Please download from Firebase Console:
    echo    Project Settings -^> Service Accounts -^> Generate Key
    pause
    exit /b 1
)

echo [OK] Service account key found

REM Install dependencies if needed
if not exist "node_modules" (
    echo.
    echo Installing dependencies...
    npm install firebase-admin
    if errorlevel 1 (
        echo [ERROR] Failed to install dependencies
        pause
        exit /b 1
    )
)

echo [OK] Dependencies ready

echo.
echo ==============================================================
echo                Starting Backup...
echo ==============================================================
echo.

node backup_database.js

if errorlevel 1 (
    echo.
    echo [ERROR] Backup failed!
    pause
    exit /b 1
)

echo.
echo ==============================================================
echo                BACKUP COMPLETED SUCCESSFULLY
echo ==============================================================
echo.

REM Get today's date
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
set backup_folder=backup_%mydate:~0,10%

echo Backup location: %CD%\%backup_folder%
echo.
echo IMPORTANT:
echo    - Keep this backup secure
echo    - Do not commit to Git
echo    - Store in multiple locations
echo.

pause
