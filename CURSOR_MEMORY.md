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
- 修复稳定性测试页面交互问题：
  - HUDBg 添加 allowsHitTesting(false)
  - 渐变覆盖层添加 allowsHitTesting(false)
  - 添加 ScrollView 支持滚动
- 电池数据真实化：移除虚假估算值，循环次数/健康度显示"系统设置查看"
- GPU/温度标记为"估算值"：iOS 无公开 API 获取真实数据
- BenchmarkView 风格统一：系统颜色替换为 ROG 主题色
- MonitorView GPU 卡片添加估算说明
- iOS 26 适配：UIScreen.main 替换为 getCurrentScreen() 辅助函数

## iOS API 限制
- 电池循环次数：无公开 API，需在系统设置 > 电池 > 电池健康查看
- 电池健康度：无公开 API，使用 IOKit 会被 App Store 拒绝
- 系统优化：只能提供建议，无法实际执行
- GPU 使用率：无公开 API，使用估算值
- 网络流量：沙盒限制，无法读取准确数据

## 辅助函数
- `getCurrentScreen()` in DeviceInfoService.swift: iOS 26 兼容的 UIScreen 访问

## GamerHomeDashboardView.swift 已废弃
