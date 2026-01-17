# AGENTS.md (iPhoneInfo/Models)

## Overview

Data models (device info DTOs) and CoreData persistence models used for benchmark history.

## Where To Look

- Core DTOs: `iPhoneInfo/Models/DeviceModels.swift`, `iPhoneInfo/Models/ExtendedDeviceInfo.swift`
- CoreData stack + history manager: `iPhoneInfo/Models/CoreDataModels.swift` (`BenchmarkHistoryManager`, `BenchmarkResultEntity`)

## Conventions (This Directory)

- Prefer `struct` for immutable value models.
- Keep formatting/derived strings as computed properties on models when they are presentation-friendly and reused.

## Persistence Notes

- Benchmark history is managed through a singleton manager; keep CoreData access centralized.
- When adding new fields, update both CoreData entity mapping and any import/export paths (if/when implemented).

## Anti-Patterns

- Do not bake view-specific formatting into storage entities if it prevents migration.
- Avoid storing transient UI state in CoreData.
