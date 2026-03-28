@echo off
chcp 65001 >nul
echo ========================================
echo Niu Ma Tool - Docker APK Build Script
echo ========================================

echo 1. Building Docker image...
docker build -t niu-ma-tool .

if %errorlevel% neq 0 (
    echo ERROR: Docker image build failed
    goto error
)

echo.
echo 2. Running container and extracting APK file...
docker run --rm -v %cd%:/output niu-ma-tool cp build/app/outputs/flutter-apk/app-release.apk /output/

if %errorlevel% neq 0 (
    echo ERROR: APK file extraction failed
    goto error
)

echo.
echo SUCCESS: APK build completed!
echo APK file location: %cd%\app-release.apk
goto end

:error
echo.
echo Troubleshooting suggestions:
echo - Make sure Docker is installed and running
echo - Check network connection
echo - Try running the script again

:end
echo.
echo ========================================
pause