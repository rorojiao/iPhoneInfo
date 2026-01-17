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

## Recent Changes (2026-01-17)
- HomeView unified: Merged player/device modes into single compact view
- Fixed one-tap optimize: Now shows real advice via sheet
- Optimized space: removed logo panel, compact cards
- All major views rebuilt with ROG HUD styling

## iOS Limitations
- Cannot actually optimize system; can only provide advice
- GamerHomeDashboardView.swift no longer used
