#!/bin/bash

# Linear Life Calendar 构建脚本
# 用于快速编译和运行 macOS 日历应用

set -e

PROJECT_NAME="LinearLifeCalendar"
SCHEME_NAME="LinearLifeCalendar"
CONFIGURATION="Debug"

echo "🚀 开始构建 Linear Life Calendar..."

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误: 未找到 xcodebuild 命令，请确保已安装 Xcode"
    exit 1
fi

# 清理之前的构建
echo "🧹 清理之前的构建..."
xcodebuild clean -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME_NAME}" -configuration "${CONFIGURATION}"

# 构建项目
echo "🔨 构建项目..."
xcodebuild build -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME_NAME}" -configuration "${CONFIGURATION}"

# 检查构建是否成功
if [ $? -eq 0 ]; then
    echo "✅ 构建成功！"
    echo ""
    echo "📱 要运行应用，请："
    echo "1. 在 Xcode 中打开 ${PROJECT_NAME}.xcodeproj"
    echo "2. 选择目标设备为 Mac"
    echo "3. 点击运行按钮或按 Cmd+R"
    echo ""
    echo "🔧 或者使用命令行运行："
    echo "open ${PROJECT_NAME}.xcodeproj"
else
    echo "❌ 构建失败，请检查错误信息"
    exit 1
fi