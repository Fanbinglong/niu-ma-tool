@echo off
chcp 65001 >nul

echo ========================================
echo Niu Ma Tool - GitHub Upload Script
echo ========================================

echo.
echo 1. Checking Git installation...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed or not in PATH
    echo Please install Git from: https://git-scm.com/downloads
    goto error
)
echo ✓ Git is installed

echo.
echo 2. Initializing Git repository...
if exist .git (
    echo ✓ Git repository already exists
) else (
    git init
    if %errorlevel% neq 0 goto error
    echo ✓ Git repository initialized
)

echo.
echo 3. Adding files to Git...
git add .
if %errorlevel% neq 0 goto error
echo ✓ Files added to staging area

echo.
echo 4. Creating initial commit...
git commit -m "Initial commit: Niu Ma Tool - Flutter delivery management app"
if %errorlevel% neq 0 goto error
echo ✓ Initial commit created

echo.
echo 5. Setting up GitHub remote repository...
echo.
echo IMPORTANT: Before continuing, please:
echo 1. Create a new repository on GitHub (https://github.com/new)
echo 2. Repository name: niu-ma-tool (or your preferred name)
echo 3. Make it Public or Private as desired
echo 4. DO NOT initialize with README, .gitignore, or license
echo.
set /p GITHUB_URL="Enter your GitHub repository URL (e.g., https://github.com/Fanbinglong/niu-ma-tool.git): "

if "%GITHUB_URL%"=="" (
    echo ERROR: No GitHub URL provided
    goto error
)

echo.
echo 6. Adding remote origin...
git remote add origin "%GITHUB_URL%"
if %errorlevel% neq 0 goto error
echo ✓ Remote origin added

echo.
echo 7. Pushing to GitHub...
git branch -M main
git push -u origin main
if %errorlevel% neq 0 goto error
echo ✓ Code pushed to GitHub

echo.
echo ========================================
echo SUCCESS: Project uploaded to GitHub!
echo ========================================
echo.
echo Next steps:
echo 1. Check your GitHub repository: %GITHUB_URL%
echo 2. GitHub Actions will automatically build the APK
echo 3. Download APK from Releases page
echo.
goto end

:error
echo.
echo ========================================
echo ERROR: GitHub upload failed
echo ========================================
echo.
echo Troubleshooting suggestions:
echo 1. Make sure Git is installed and configured
echo 2. Check your GitHub repository URL
necho 3. Verify you have write access to the repository
echo 4. Check your internet connection
echo 5. Try running the script again
echo.

:end
echo.
echo Script completed.
pause