@echo off
chcp 65001 >nul

echo ========================================
echo 牛马工具 - Flutter 预览启动器
echo ========================================
echo.

echo 请选择预览模式：
echo.
echo 1. 运行完整应用（热重载）
echo 2. 运行预览菜单（类似 Compose 预览）
echo 3. 打开 Flutter DevTools
echo 4. 检查代码规范
echo.

set /p choice="请输入选项 (1-4): "

if "%choice%"=="1" (
    echo.
    echo 启动完整应用...
    flutter run
    goto :end
)

if "%choice%"=="2" (
    echo.
    echo 启动预览菜单...
    flutter run -t lib/preview.dart
    goto :end
)

if "%choice%"=="3" (
    echo.
    echo 打开 DevTools...
    echo 请先运行应用，然后访问终端显示的 DevTools URL
    goto :end
)

if "%choice%"=="4" (
    echo.
    echo 检查代码规范...
    flutter analyze
    goto :end
)

echo 无效选项！
goto :end

:end
echo.
echo 按任意键退出...
pause >nul
