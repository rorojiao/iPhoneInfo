# AGENTS.md (iPhoneInfo/Views)

## Overview

SwiftUI screens for device info, benchmarks, monitoring, comparison, and settings.

## Where To Look

- Home (system info): `iPhoneInfo/Views/HomeView.swift`
- Benchmarks UI: `iPhoneInfo/Views/BenchmarkView.swift`
- Real-time monitoring UI: `iPhoneInfo/Views/MonitorView.swift`
- History / comparison: `iPhoneInfo/Views/CompareView.swift`
- Settings: `iPhoneInfo/Views/SettingsView.swift`
- Debug tooling: `iPhoneInfo/Views/DeviceDebugView.swift`

## Conventions (This Directory)

- Views are thin: observe `ObservableObject` services and render `@Published` state.
- Service ownership pattern is common: `@StateObject private var service = Service.shared`.
- Screens commonly wrap content with `NavigationView` (existing behavior).
- Prefer composing large screens into smaller `View` structs (this repo already does this in places).

## Anti-Patterns

- Do not perform benchmarks or system polling directly in `body`; delegate to services.
- Avoid long synchronous work inside `.onAppear`; if needed, run off main and publish results back on main.
- Avoid large “god view” files growing further; extract subviews when adding new sections.

## TODO Hotspots

- `iPhoneInfo/Views/SettingsView.swift` contains TODOs for export/clear-history features; align any implementation with CoreData history (`iPhoneInfo/Models/CoreDataModels.swift`).
