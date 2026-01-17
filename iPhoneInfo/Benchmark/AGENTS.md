# AGENTS.md (iPhoneInfo/Benchmark)

## Overview

Benchmark implementations (CPU/Memory/Storage/Metal GPU). Focus: repeatability, safety, and not blocking UI.

## Where To Look

- GPU protocol + Manhattan scene: `iPhoneInfo/Benchmark/MetalBenchmark.swift` (`MetalBenchmark`, `ManhattanBenchmark`, `BenchmarkScore`)
- CPU benchmarks: `iPhoneInfo/Benchmark/CPUBenchmark.swift`
- Memory benchmarks: `iPhoneInfo/Benchmark/MemoryBenchmark.swift`
- Storage benchmarks: `iPhoneInfo/Benchmark/StorageBenchmark.swift`

## Conventions (This Directory)

- Keep benchmark setup separate from measurement; avoid timing initialization.
- Benchmarks should be callable from orchestrators (`BenchmarkService`, `BenchmarkCoordinator`) without view coupling.
- GPU benchmarks should implement `MetalBenchmark` and use `MTKView` lifecycle (`setup/update/draw/cleanup`).

## Metal Safety

- Always guard device creation and surface meaningful errors (`BenchmarkError`).
- Avoid shader compilation and pipeline creation on the main thread if it can be moved off.
- Clean up Metal resources deterministically (`cleanup`/`deinit`).

## Anti-Patterns

- Do not run benchmark loops on the main thread.
- Do not assume Metal exists on all targets; keep fallback behavior.
- Do not use force unwraps for `MTLDevice`, `MTLCommandQueue`, or library/pipeline creation.
