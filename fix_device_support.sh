#!/bin/bash

# 修复 iOS 26.2 设备支持
# 此脚本需要管理员权限

echo "🔧 修复 iOS 26.2 设备支持"
echo "========================"
echo ""
echo "此脚本将创建符号链接以支持 iOS 26.2 设备"
echo "需要管理员权限..."
echo ""

# 检查目录是否存在
DEVICE_SUPPORT_DIR="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport"

if [ ! -d "$DEVICE_SUPPORT_DIR/26.1" ]; then
    echo "❌ 错误: 找不到 iOS 26.1 设备支持"
    echo "请确保 Xcode 已正确安装"
    exit 1
fi

# 创建 iOS 26.2 符号链接
echo "📁 创建 iOS 26.2 设备支持目录..."
sudo mkdir -p "$DEVICE_SUPPORT_DIR/26.2"

echo "🔗 创建符号链接..."
sudo ln -sf "$DEVICE_SUPPORT_DIR/26.1" "$DEVICE_SUPPORT_DIR/26.2/Symbols"

echo "✅ 完成！"
echo ""
echo "现在请在 Xcode 中:"
echo "1. 选择您的 iPhone (JunIP16PM)"
echo "2. 点击运行按钮 ▶️"
echo ""
