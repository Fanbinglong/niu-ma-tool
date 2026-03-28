@echo off
echo ========================================
echo 牛马工具 - APK构建脚本
echo ========================================

echo 1. 清理项目...
flutter clean

echo.
echo 2. 安装依赖...
flutter pub get

echo.
echo 3. 构建APK...
echo 注意: 如果网络连接有问题，请确保:
echo - 网络连接稳定
echo - 关闭VPN或代理
echo - 重试构建命令

flutter build apk --release

echo.
if %errorlevel% equ 0 (
    echo ✅ APK构建成功!
    echo 📱 APK文件位置: build/app/outputs/flutter-apk/app-release.apk
) else (
    echo ❌ APK构建失败
    echo 💡 建议使用在线构建服务
)

echo.
echo ========================================
pause