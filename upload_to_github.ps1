# Niu Ma Tool - GitHub Upload Script (PowerShell Version)

Write-Host "========================================" -ForegroundColor Green
Write-Host "Niu Ma Tool - GitHub Upload Script" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# 1. Check Git installation
Write-Host "1. Checking Git installation..." -ForegroundColor Yellow
$gitCheck = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCheck) {
    Write-Host "ERROR: Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Git from: https://git-scm.com/downloads" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Git is installed" -ForegroundColor Green
Write-Host ""

# 2. Initialize Git repository
Write-Host "2. Initializing Git repository..." -ForegroundColor Yellow
if (Test-Path ".git") {
    Write-Host "✓ Git repository already exists" -ForegroundColor Green
} else {
    git init
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to initialize Git repository" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Git repository initialized" -ForegroundColor Green
}
Write-Host ""

# 3. Add files to Git
Write-Host "3. Adding files to Git..." -ForegroundColor Yellow
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to add files to Git" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Files added to staging area" -ForegroundColor Green
Write-Host ""

# 4. Create initial commit
Write-Host "4. Creating initial commit..." -ForegroundColor Yellow
git commit -m "Initial commit: Niu Ma Tool - Flutter delivery management app"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create initial commit" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Initial commit created" -ForegroundColor Green
Write-Host ""

# 5. Get GitHub repository URL
Write-Host "5. Setting up GitHub remote repository..." -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT: Before continuing, please:" -ForegroundColor Cyan
Write-Host "1. Create a new repository on GitHub (https://github.com/new)" -ForegroundColor Cyan
Write-Host "2. Repository name: niu-ma-tool (or your preferred name)" -ForegroundColor Cyan
Write-Host "3. Make it Public or Private as desired" -ForegroundColor Cyan
Write-Host "4. DO NOT initialize with README, .gitignore, or license" -ForegroundColor Cyan
Write-Host ""

$githubUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/yourusername/niu-ma-tool.git)"

if ([string]::IsNullOrWhiteSpace($githubUrl)) {
    Write-Host "ERROR: No GitHub URL provided" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 6. Add remote origin
Write-Host "6. Adding remote origin..." -ForegroundColor Yellow
git remote add origin $githubUrl
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to add remote origin" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Remote origin added" -ForegroundColor Green
Write-Host ""

# 7. Push to GitHub
Write-Host "7. Pushing to GitHub..." -ForegroundColor Yellow
git branch -M main
git push -u origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to push to GitHub" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Code pushed to GitHub" -ForegroundColor Green
Write-Host ""

# Success message
Write-Host "========================================" -ForegroundColor Green
Write-Host "SUCCESS: Project uploaded to GitHub!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Check your GitHub repository: $githubUrl" -ForegroundColor Cyan
Write-Host "2. GitHub Actions will automatically build the APK" -ForegroundColor Cyan
Write-Host "3. Download APK from Releases page" -ForegroundColor Cyan
Write-Host ""
Write-Host "Script completed successfully!" -ForegroundColor Green