# iPhoneInfo Memory (for Cursor)

> Cross-tool memory bank for this repo.

## Repo Overview
- App: **iPhoneInfo** (iOS device info + benchmarks + real-time monitor)
- Tech: Swift 5.9+, SwiftUI, Metal/MetalKit, CoreData
- UI strings: Chinese | Code comments: English

## Key Entry Points
- App entry: `iPhoneInfo/App/iPhoneInfoApp.swift`
- Tabs: `iPhoneInfo/App/ContentView.swift`
- Home (unified): `iPhoneInfo/Views/HomeView.swift`
- Sustained test: `iPhoneInfo/Views/SustainedGamingTestView.swift`
- Benchmark: `iPhoneInfo/Views/BenchmarkView.swift`
- Monitor: `iPhoneInfo/Views/MonitorView.swift`
- Compare: `iPhoneInfo/Views/CompareView.swift`
- Settings: `iPhoneInfo/Views/SettingsView.swift`

## ROG HUD Design System
- Theme: `iPhoneInfo/Views/HUD/HUDTheme.swift`
- Components: `iPhoneInfo/Views/HUD/ROGComponents.swift`
- Background: `iPhoneInfo/Views/HUD/HUDBg.swift` (已设置 allowsHitTesting(false))

## Recent Changes (2026-01-19)
- **移除所有估算值和不可用功能的界面显示**：
  - HomeView: 移除 GPU/温度/循环次数卡片，移除设备信息中的电池健康/循环次数/电池温度
  - MonitorView: 移除 GPU 监控卡片，用热状态替代温度
  - SustainedGamingTestView: 移除 GPU 估算和温度估算，改用热状态
  - BenchmarkView: 移除温度显示，改用热状态
  - 删除不再使用的 GamerHomeDashboardView.swift
- 修复稳定性测试页面交互问题：HUDBg 添加 allowsHitTesting(false)
- BenchmarkView 风格统一：系统颜色替换为 ROG 主题色
- iOS 26 适配：UIScreen.main 替换为 getCurrentScreen() 辅助函数

## 只显示真实数据
界面上只显示 iOS 公开 API 可真实获取的数据：
- ✅ CPU 使用率（mach kernel API）
- ✅ 内存使用率（mach kernel API）
- ✅ 电池电量和充电状态（UIDevice.batteryLevel）
- ✅ 热状态（ProcessInfo.thermalState）
- ✅ 网络延迟/抖动/丢包（ping 测试）
- ✅ 低电量模式状态（ProcessInfo.isLowPowerModeEnabled）

## 已移除的估算/不可用数据
- ❌ GPU 使用率：iOS 无公开 API
- ❌ 温度数值：iOS 无公开 API（改为显示热状态）
- ❌ 电池循环次数：需 IOKit，App Store 会拒绝
- ❌ 电池健康度：需 IOKit，App Store 会拒绝
- ❌ 电池温度：无公开 API

## 辅助函数
- `getCurrentScreen()` in DeviceInfoService.swift: iOS 26 兼容的 UIScreen 访问
