@echo off
REM Flutter 多环境构建脚本 (Windows)

setlocal enabledelayedexpansion

REM 设置颜色
set "INFO=[INFO]"
set "SUCCESS=[SUCCESS]"
set "WARNING=[WARNING]"
set "ERROR=[ERROR]"

REM 显示帮助信息
if "%1"=="" (
    echo Flutter 多环境构建脚本
    echo.
    echo 用法: build.bat [环境] [命令]
    echo.
    echo 环境:
    echo   dev, development    开发环境
    echo   test, testing      测试环境
    echo   prod, production    生产环境
    echo.
    echo 命令:
    echo   run                 运行应用（默认）
    echo   build apk           构建 APK
    echo   build appbundle     构建 App Bundle
    echo   build ios           构建 iOS
    echo   build web           构建 Web
    echo.
    echo 示例:
    echo   build.bat dev run              # 运行开发环境
    echo   build.bat test build apk       # 构建测试环境 APK
    echo   build.bat prod build appbundle # 构建生产环境 App Bundle
    exit /b 0
)

REM 解析环境参数
set ENV_INPUT=%1
set COMMAND=%2
if "%COMMAND%"=="" set COMMAND=run

REM 设置环境变量
if /i "%ENV_INPUT%"=="dev" set ENV_VALUE=development& set "ENV_NAME=开发环境"
if /i "%ENV_INPUT%"=="development" set ENV_VALUE=development& set "ENV_NAME=开发环境"

if /i "%ENV_INPUT%"=="test" set ENV_VALUE=testing& set "ENV_NAME=测试环境"
if /i "%ENV_INPUT%"=="testing" set ENV_VALUE=testing& set "ENV_NAME=测试环境"

if /i "%ENV_INPUT%"=="prod" set ENV_VALUE=production& set "ENV_NAME=生产环境"
if /i "%ENV_INPUT%"=="production" set ENV_VALUE=production& set "ENV_NAME=生产环境"

if "%ENV_VALUE%"=="" (
    echo %ERROR% 未知的环境: %ENV_INPUT%
    exit /b 1
)

REM 打印构建信息
echo %INFO% ==========================================
echo %INFO% 环境: %ENV_NAME%
echo %INFO% 命令: %COMMAND%
echo %INFO% ==========================================

REM 构建 Dart 定义
set DART_DEFINES=--dart-define=ENVIRONMENT=%ENV_VALUE%

REM 可选：添加其他环境特定的配置
REM set API_BASE_URL=https://%ENV_VALUE%-api.example.com
REM set DART_DEFINES=%DART_DEFINES% --dart-define=API_BASE_URL=%API_BASE_URL%

REM 执行命令
if /i "%COMMAND%"=="run" (
    echo %INFO% 正在运行 %ENV_NAME% ...
    flutter run %DART_DEFINES%
) else if /i "%COMMAND%"=="build" (
    if "%3"=="" (
        echo %ERROR% 请指定构建目标 (apk/appbundle/ios/web)
        exit /b 1
    )

    set BUILD_TARGET=%3

    if /i "%BUILD_TARGET%"=="apk" (
        echo %INFO% 正在构建 %ENV_NAME% APK ...
        flutter build apk %DART_DEFINES% --release
    ) else if /i "%BUILD_TARGET%"=="appbundle" (
        echo %INFO% 正在构建 %ENV_NAME% App Bundle ...
        flutter build appbundle %DART_DEFINES% --release
    ) else if /i "%BUILD_TARGET%"=="ios" (
        echo %INFO% 正在构建 %ENV_NAME% iOS ...
        flutter build ios %DART_DEFINES% --release
    ) else if /i "%BUILD_TARGET%"=="web" (
        echo %INFO% 正在构建 %ENV_NAME% Web ...
        flutter build web %DART_DEFINES% --release
    ) else (
        echo %ERROR% 未知的构建目标: %BUILD_TARGET%
        exit /b 1
    )
) else (
    echo %ERROR% 未知的命令: %COMMAND%
    exit /b 1
)

REM 检查执行结果
if %errorlevel% equ 0 (
    echo %SUCCESS% %ENV_NAME% 构建/运行成功!
) else (
    echo %ERROR% %ENV_NAME% 构建/运行失败!
    exit /b 1
)

endlocal