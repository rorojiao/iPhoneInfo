# AGENTS.md

Guidance for coding agents working in the `iPhoneInfo` repository.

## Overview

- iOS app: system information + CPU/GPU/Memory/Storage benchmarks + real-time monitoring
- Stack: Swift 5.9+, SwiftUI, Metal/MetalKit, CoreData, sysctl/mach APIs
- UI localization: user-facing strings in Chinese; debug logs may be English (`[DEBUG] ...`).

## Structure

```
./
├── iPhoneInfo/                 # App source
│   ├── App/                    # `@main` app + root routing
│   ├── Views/                  # SwiftUI screens
│   ├── Services/               # Singletons + system interactions
│   ├── Models/                 # DTOs + CoreData stack
│   └── Benchmark/              # Benchmark implementations
├── iPhoneInfo.xcodeproj/       # Xcode project
├── Package.swift               # SPM manifest (supporting tooling)
├── PRD_iPhone_Info_Benchmark.md
├── CLAUDE.md                   # Architecture notes
└── generate_xcode_project.sh
```

## Where To Look

- App entry / routing: `iPhoneInfo/App/iPhoneInfoApp.swift`, `iPhoneInfo/App/ContentView.swift`
- Device info collection: `iPhoneInfo/Services/DeviceInfoService.swift`, `iPhoneInfo/Services/ExtendedDeviceDetailsService.swift`
- Real-time monitoring: `iPhoneInfo/Services/SystemMonitor.swift`, `iPhoneInfo/Views/MonitorView.swift`
- Benchmarks (orchestration): `iPhoneInfo/Services/BenchmarkService.swift`, `iPhoneInfo/Services/BenchmarkCoordinator.swift`
- Benchmarks (implementations): `iPhoneInfo/Benchmark/*Benchmark.swift`, `iPhoneInfo/Benchmark/MetalBenchmark.swift`
- Persistence (history): `iPhoneInfo/Models/CoreDataModels.swift`

## Project Conventions (This Repo)

- Services are typically singletons (`static let shared = ...`) and `ObservableObject` with `@Published` state.
- Views typically own shared services via `@StateObject private var service = Service.shared`.
- Threading is mixed:
  - Some code uses `DispatchQueue.*`.
  - Some code uses `async/await` and `await MainActor.run { ... }`.
  - When adding new code, keep consistency within the touched module and ensure UI state updates happen on the main actor/thread.
- Navigation wrappers currently use `NavigationView` in multiple screens; do not refactor to `NavigationStack` unless the change is already in scope.

## Anti-Patterns (Avoid)

- Force unwraps (`!`) in system/Metal paths; prefer `guard let` + explicit errors.
- Doing heavy work on the main thread (benchmarks, sysctl/mach queries, shader compilation).
- Crashing when restricted APIs are unavailable; prefer graceful fallbacks/defaults.
- “Drive-by refactors” while fixing a bug; keep changes minimal and scoped.

## Metal / Benchmark Safety

- Always guard GPU availability (`guard let device = MTLCreateSystemDefaultDevice() else { ... }`).
- Manage Metal resources explicitly: create in `setup`, release in `cleanup`/`deinit`.
- Benchmarks must keep UI responsive; run workloads off the main thread, then publish results on main.

## Build, Test, Install

```bash
# Generate Xcode project (if needed)
./generate_xcode_project.sh

# Build (Debug)
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug build

# Build-for-testing
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug build-for-testing

# Archive
xcodebuild archive -project iPhoneInfo.xcodeproj -scheme iPhoneInfo \
  -archivePath ./build/iPhoneInfo.xcarchive

# Install to device (replace UDID)
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug \
  -destination 'id=DEVICE_UDID' install

# Standalone script
swift test_device_model.swift
```

## Notes

- This repo currently has no Xcode test targets.
- PRD-driven work: check `PRD_iPhone_Info_Benchmark.md` before adding new features/flows.
