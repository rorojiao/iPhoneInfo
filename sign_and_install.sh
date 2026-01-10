#!/bin/bash

# iPhone Info - 代码签名和安装脚本

echo "📱 iPhone Info - 代码签名和安装"
echo "================================"
echo ""

# 检查是否有 Apple ID 登录
echo "检查 Xcode 账户..."
if security find-identity -v -p codesigning 2>&1 | grep -q "iPhone"; then
    echo "✅ 找到代码签名身份"
else
    echo "❌ 未找到代码签名身份"
    echo ""
    echo "请按以下步骤操作："
    echo "1. 在 Xcode 中: Xcode → Settings → Accounts"
    echo "2. 点击 '+' 添加您的 Apple ID"
    echo "3. 登录后，返回终端运行此脚本"
    echo ""
    open "xcode://settings/Account"
    exit 1
fi

echo ""
echo "正在配置项目签名..."
cd "/Users/jiaojunze/Library/Mobile Documents/com~apple~CloudDocs/working_MAC/iphoneInfo"

# 修改项目配置以启用自动签名
echo "启用自动签名..."
sed -i '' 's/CODE_SIGN_IDENTITY = ""/CODE_SIGN_IDENTITY = "Apple Development"/g' iPhoneInfo.xcodeproj/project.pbxproj
sed -i '' 's/CODE_SIGN_STYLE = Manual/CODE_SIGN_STYLE = Automatic/g' iPhoneInfo.xcodeproj/project.pbxproj

echo ""
echo "正在构建和安装..."
xcodebuild -project iPhoneInfo.xcodeproj \
    -scheme iPhoneInfo \
    -configuration Debug \
    -destination 'id=00008140-001C09E83CFB001C' \
    -allowProvisioningUpdates \
    install

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 成功！应用已安装到您的 iPhone"
    echo ""
    echo "首次运行时，您需要在 iPhone 上："
    echo "1. 打开 设置 → 通用 → VPN与设备管理"
    echo "2. 找到您的开发者证书"
    echo "3. 点击 '信任'"
    echo ""
else
    echo ""
    echo "❌ 安装失败"
    echo ""
    echo "请在 Xcode 中手动操作："
    echo "1. 打开项目"
    echo "2. 选择项目文件 (蓝色图标)"
    echo "3. 在 'Signing & Capabilities' 标签页"
    echo "4. 勾选 'Automatically manage signing'"
    echo "5. 选择您的 Team"
    echo "6. 点击运行按钮 ▶️"
    echo ""
fi
