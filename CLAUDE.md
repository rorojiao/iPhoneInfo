# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **iPhone Info & Benchmark Tool** - a comprehensive iOS application that combines system information monitoring with professional 3D performance benchmarking capabilities.

**Core Purpose**: Provide users with detailed hardware/system information and run Metal-based GPU performance tests on iOS devices.

**Key Differentiator**: Integration of system information viewing + Metal-based 3D benchmarking + real-time monitoring in a single app, fully localized for Chinese users.

## Product Requirements Document

The complete product specification is documented in `PRD_iPhone_Info_Benchmark.md`. This includes:
- Detailed functional requirements for all modules
- Technical implementation approach with code samples
- User interface designs and workflows
- Development roadmap and milestones

**Always reference the PRD when implementing new features or making architectural decisions.**

## Architecture

### Module Structure

```
iPhoneInfo/
├── App/                    # App entry point, configuration
├── SystemInfo/             # System information gathering
│   ├── DeviceInfo
│   ├── HardwareInfo
│   ├── SystemInfo
│   ├── SensorInfo
│   └── NetworkInfo
├── Benchmark/              # Performance testing
│   ├── CPU/                # CPU benchmarking
│   ├── GPU/                # Metal-based 3D tests
│   ├── Memory/             # Memory bandwidth/latency tests
│   └── Storage/            # Read/write performance tests
├── Monitor/                # Real-time system monitoring
│   ├── CPUMonitor
│   ├── MemoryMonitor
│   ├── GPUMonitor
│   ├── BatteryMonitor
│   └── TemperatureMonitor
├── Comparison/             # Historical data and comparison
│   ├── History
│   ├── DeviceComparison
│   └── CloudLeaderboard
└── Shared/                 # Shared utilities and models
    ├── Models
    ├── Utils
    └── UIComponents
```

### Key Technologies

- **Language**: Swift 5.9+
- **UI**: SwiftUI (primary) + UIKit (complex scenarios)
- **3D Rendering**: Metal (MetalKit, Metal Performance Shaders)
- **Data Persistence**: CoreData
- **Networking**: URLSession
- **Charts**: Swift Charts (iOS 16+), Core Graphics (custom)

## Development Commands

This project is an iOS app built with Xcode. Common commands:

### Building

```bash
# Build the project
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug build

# Build for testing
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug build-for-testing
```

### Running Tests

```bash
# Run all tests
xcodebuild test -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test
xcodebuild test -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:iPhoneInfoTests/SystemInfoTests
```

### Installing to Device

For development/testing on a physical iPhone:

```bash
# Install to connected device
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug \
  -destination 'id=DEVICE_UDID' install
```

**Note**: iOS requires code signing. For personal testing, use your free Apple Developer account. For distribution, you'll need a paid Developer Program account and proper provisioning profiles.

### Creating an Archive (for TestFlight/App Store)

```bash
xcodebuild archive -project iPhoneInfo.xcodeproj -scheme iPhoneInfo \
  -archivePath ./build/iPhoneInfo.xcarchive
```

## Important Implementation Notes

### System Information Access

iOS has strict sandboxing. Some hardware information requires:
- **Public APIs**: `UIDevice`, `sysctl`, `Core Foundation` - always available
- **IOKit**: Battery cycle count, temperature - requires entitlements or enterprise certificate
- **Private APIs**: Not recommended for App Store distribution

**Strategy**: Use public APIs when possible. For advanced features, gracefully degrade on devices without permissions.

### Metal Benchmark Design

All GPU benchmarks implement the `MetalBenchmark` protocol:

```swift
protocol MetalBenchmark {
    var name: String { get }
    var duration: TimeInterval { get }

    func setup(view: MTKView) throws
    func update(deltaTime: Float)
    func draw(view: MTKView)
    func cleanup()

    func getScore() -> BenchmarkScore
}
```

Benchmark scenes:
- **Manhattan**: Medium complexity, OpenGL ES 3.0 level
- **Aztec Ruins**: High complexity, advanced shading
- **Solar Bay**: Ray tracing (A17 Pro+ only)
- **Wild Life**: Stress test for sustained performance

### Performance Monitoring

Real-time monitoring uses mach kernel APIs for CPU/memory. These are low-level and require careful handling:

```swift
// CPU usage from mach thread info
host_statistics64(mach_host_self(), HOST_VM_INFO64, ...)

// Memory from vm_statistics
vm_statistics64_t stats
host_statistics64(mach_host_self(), HOST_VM_INFO64, ...)
```

### Data Storage

CoreData model (`BenchmarkResult`) stores:
- Test scores and metrics
- Device model and iOS version
- Temperature and battery level during test
- Detailed test results as JSON

## Deployment Considerations

### App Store Approval Risks

1. **Private API Usage**: Avoid IOKit/private APIs for App Store version
2. **Battery/Thermal Management**: Tests must respect iOS thermal management
3. **User Data**: Anonymize all cloud-uploaded data, include privacy policy

### Code Signing

- **Development**: Free Apple ID works for 7-day provisioning
- **Testing**: TestFlight requires paid Developer Program
- **Distribution**: App Store requires paid Developer Program

### Platform Support

- **Minimum**: iOS 15.0
- **Target**: iOS 17.0+
- **Devices**: iPhone 12 and newer recommended
- **Ray Tracing**: A17 Pro (iPhone 15 Pro) and newer only
