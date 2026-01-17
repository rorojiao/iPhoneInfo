# AGENTS.md (iPhoneInfo/Services)

## Overview

Business logic + system integration: device info, monitoring, benchmarks, thermal/performance mode.

## Where To Look

- Basic device info (`UIDevice`, etc.): `iPhoneInfo/Services/DeviceInfoService.swift`
- Low-level hardware info (`sysctl`, IOKit fallback): `iPhoneInfo/Services/ExtendedDeviceDetailsService.swift`
- Monitoring (mach/network stats): `iPhoneInfo/Services/SystemMonitor.swift`
- Thermal state: `iPhoneInfo/Services/ThermalService.swift`
- Performance mode toggles: `iPhoneInfo/Services/PerformanceModeService.swift`
- Benchmark orchestration (simple): `iPhoneInfo/Services/BenchmarkService.swift`
- Benchmark orchestration (comprehensive + scoring): `iPhoneInfo/Services/BenchmarkCoordinator.swift`

## Conventions (This Directory)

- Services are commonly singletons (`static let shared = ...`) and `ObservableObject`.
- Publish UI-facing state via `@Published`.
- Threading patterns are mixed (DispatchQueue + async/await). Maintain consistency within a file/module you touch:
  - If you add async APIs, ensure UI updates happen on main (`await MainActor.run { ... }` or `DispatchQueue.main.async { ... }`).
  - Avoid adding new background work onto the main thread.

## Error Handling Expectations

- Prefer explicit error enums for benchmark/system failures (see benchmark-related errors in services/benchmarks).
- If an API is unavailable (sandbox/permissions/device capabilities), return defaults and keep the app stable.

## Anti-Patterns

- Do not crash on missing entitlements/capabilities (IOKit/Metal).
- Avoid force unwraps and unsafe pointer misuse in mach/sysctl code.
- Avoid “fire-and-forget” background work that outlives the view without a clear cancellation/stop path.
