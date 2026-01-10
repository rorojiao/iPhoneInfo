#!/bin/bash

# iPhone Info - Xcode 自动运行脚本
# 此脚本将指导您在 Xcode 中手动运行应用

echo "📱 iPhone Info - Xcode 运行指南"
echo "================================"
echo ""
echo "检测到您的设备运行 iOS 26.1（测试版本）"
echo "由于 Xcode 测试版本的兼容性问题，请按以下步骤操作："
echo ""
echo "方法 1：在 Xcode 中直接运行（推荐）"
echo "-----------------------------------"
echo "1. Xcode 应该已经打开"
echo "2. 确保您的 iPhone (JunIP16PM) 已连接"
echo "3. 在 Xcode 顶部工具栏，点击设备选择器"
echo "4. 选择 'JunIP16PM' 您的 iPhone"
echo "5. 点击左上角的运行按钮 ▶️（或按 Cmd+R）"
echo "6. 如果提示 'iOS 26.1 is not installed'，点击 'Fix Issue'"
echo "7. Xcode 会自动下载并安装必要的组件"
echo ""
echo "方法 2：使用模拟器测试"
echo "----------------------"
echo "1. 在 Xcode 顶部工具栏，点击设备选择器"
echo "2. 选择任意 iPhone 模拟器（如 iPhone 16 Pro）"
echo "3. 点击运行按钮 ▶️"
echo "4. 应用将在模拟器中启动"
echo ""
echo "当前项目位置:"
echo "  /Users/jiaojunze/Library/Mobile Documents/com~apple~CloudDocs/working_MAC/iphoneInfo/"
echo ""
echo "如需帮助，请查看 INSTALL.md 文档"
echo ""

# 尝试激活 Xcode
osascript -e 'tell application "Xcode" to activate' 2>/dev/null

echo "✅ 已激活 Xcode 窗口"
echo ""
echo "请在 Xcode 中按照上述步骤操作。"
