@echo off
REM Firebase Firestore Indexes Setup Script (Windows)
REM Usage: setup-indexes.bat
REM This script deploys all required Firestore indexes

echo.
echo ========================================
echo 4  Firebase Firestore Indexes Setup
echo ========================================
echo.

REM Check if Firebase CLI is installed
where firebase >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo X Firebase CLI not found!
    echo.
    echo Install it with: npm install -g firebase-tools
    pause
    exit /b 1
)

echo + Firebase CLI found
echo.

REM Check if logged in
echo Checking Firebase authentication...
firebase projects:list >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo! Not authenticated. Running: firebase login
    firebase login
)

echo + Authenticated to Firebase
echo.

REM Get current project
for /f "tokens=*" %%A in ('firebase use 2^>nul ^| findstr /R ".*"') do set PROJECT_ID=%%A
if "%PROJECT_ID%"=="" (
    for /f "tokens=2 delims=:" %%A in ('findstr /R "default" .firebaserc 2^>nul') do set PROJECT_ID=%%A
    if "%PROJECT_ID%"=="" set PROJECT_ID=ai-meal-planner-b1713
)

echo Package ID: %PROJECT_ID%
echo.

REM Check if firestore.indexes.json exists
if not exist "firestore.indexes.json" (
    echo X firestore.indexes.json not found in current directory!
    echo Make sure you're in the project root directory
    pause
    exit /b 1
)

echo Document: firestore.indexes.json found
echo.

REM Deploy indexes
echo Deploying Firestore indexes...
echo This may take 2-5 minutes. Please wait...
echo.

firebase deploy --only firestore:indexes

if %ERRORLEVEL% EQU 0 (
    echo.
    echo + Indexes deployed successfully!
    echo.
    echo Next steps:
    echo 1. Go to https://console.firebase.google.com
    echo 2. Select project: %PROJECT_ID%
    echo 3. Navigate to Firestore - Indexes
    echo 4. Verify all indexes show status: Enabled
    echo.
    echo Estimated time: 2-5 minutes
    echo.
    echo o Your app should now run much faster!
    pause
) else (
    echo.
    echo X Deployment failed!
    echo Try one of these solutions:
    echo 1. Check project ID is correct: firebase use
    echo 2. Update Firebase CLI: npm install -g firebase-tools@latest
    echo 3. Deploy manually via Firebase Console
    pause
    exit /b 1
)
