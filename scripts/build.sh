#!/bin/bash

# Flutter 多环境构建脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "Flutter 多环境构建脚本"
    echo ""
    echo "用法: ./build.sh [环境] [命令]"
    echo ""
    echo "环境:"
    echo "  dev, development    开发环境"
    echo "  test, testing      测试环境"
    echo "  prod, production    生产环境"
    echo ""
    echo "命令:"
    echo "  run                 运行应用（默认）"
    echo "  build apk           构建 APK"
    echo "  build appbundle     构建 App Bundle"
    echo "  build ios           构建 iOS"
    echo "  build web           构建 Web"
    echo ""
    echo "示例:"
    echo "  ./build.sh dev run              # 运行开发环境"
    echo "  ./build.sh test build apk       # 构建测试环境 APK"
    echo "  ./build.sh prod build appbundle # 构建生产环境 App Bundle"
    exit 0
}

# 检查参数
if [ $# -lt 1 ]; then
    print_error "参数错误"
    show_help
fi

# 解析环境参数
ENVIRONMENT=$1
COMMAND=${2:-run}

# 设置环境变量
case $ENVIRONMENT in
    dev|development)
        ENV_VALUE="development"
        ENV_NAME="开发环境"
        ;;
    test|testing)
        ENV_VALUE="testing"
        ENV_NAME="测试环境"
        ;;
    prod|production)
        ENV_VALUE="production"
        ENV_NAME="生产环境"
        ;;
    *)
        print_error "未知的环境: $ENVIRONMENT"
        show_help
        ;;
esac

# 打印构建信息
print_info "=========================================="
print_info "环境: $ENV_NAME"
print_info "命令: $COMMAND"
print_info "=========================================="

# 构建 Dart 定义
DART_DEFINES="--dart-define=ENVIRONMENT=$ENV_VALUE"

# 可选：添加其他环境特定的配置
# API_BASE_URL="https://$ENV_VALUE-api.example.com"
# DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=$API_BASE_URL"

# 执行命令
case $COMMAND in
    run)
        print_info "正在运行 $ENV_NAME ..."
        flutter run $DART_DEFINES
        ;;
    build)
        if [ $# -lt 3 ]; then
            print_error "请指定构建目标 (apk/appbundle/ios/web)"
            exit 1
        fi
        BUILD_TARGET=$3

        case $BUILD_TARGET in
            apk)
                print_info "正在构建 $ENV_NAME APK ..."
                flutter build apk $DART_DEFINES --release
                ;;
            appbundle)
                print_info "正在构建 $ENV_NAME App Bundle ..."
                flutter build appbundle $DART_DEFINES --release
                ;;
            ios)
                print_info "正在构建 $ENV_NAME iOS ..."
                flutter build ios $DART_DEFINES --release
                ;;
            web)
                print_info "正在构建 $ENV_NAME Web ..."
                flutter build web $DART_DEFINES --release
                ;;
            *)
                print_error "未知的构建目标: $BUILD_TARGET"
                exit 1
                ;;
        esac
        ;;
    *)
        print_error "未知的命令: $COMMAND"
        show_help
        ;;
esac

# 检查执行结果
if [ $? -eq 0 ]; then
    print_success "$ENV_NAME 构建成功!"
else
    print_error "$ENV_NAME 构建失败!"
    exit 1
fi