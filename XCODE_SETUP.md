# Xcode Project Setup Instructions

The existing `iPhoneInfo.xcodeproj` file was corrupted. Please follow these steps to create a proper Xcode project:

## Option 1: Create New Xcode Project (Recommended)

1. Open Xcode
2. File > New > Project
3. Select "iOS" > "App"
4. Enter project name: "iPhoneInfo"
5. Set Team, Bundle Identifier, and Interface options
6. Create project in this directory

Then add all Swift files to the project:

```
iPhoneInfo/
├── App/
│   ├── iPhoneInfoApp.swift
│   └── ContentView.swift
├── Views/
│   ├── HomeView.swift
│   ├── BenchmarkView.swift
│   ├── MonitorView.swift
│   ├── CompareView.swift
│   ├── SettingsView.swift
│   └── DeviceDebugView.swift
├── Services/
│   ├── DeviceInfoService.swift
│   ├── ExtendedDeviceDetailsService.swift
│   ├── ThermalService.swift
│   ├── SensorService.swift
│   ├── SystemMonitor.swift
│   ├── PerformanceModeService.swift
│   └── BenchmarkCoordinator.swift
├── Models/
│   ├── DeviceModels.swift
│   ├── ExtendedDeviceInfo.swift
│   └── CoreDataModels.swift
└── Benchmark/
    ├── CPUBenchmark.swift
    ├── MetalBenchmark.swift
    ├── MemoryBenchmark.swift
    └── StorageBenchmark.swift
```

## Option 2: Use Command Line to Generate Project

Xcode project files (.pbxproj) are complex property list formats that should not be manually generated. Use Xcode or xcodegen tool:

### Using xcodegen (if installed):

```bash
# Install xcodegen
brew install xcodegen

# Create project.yml spec
cat > project.yml << 'EOF'
name: iPhoneInfo
targets:
  iPhoneInfo:
    type: application
    platform: iOS
    deploymentTarget: "15.0"
    sources:
      - iPhoneInfo
EOF

# Generate Xcode project
xcodegen
```

### Using Xcode directly:

1. Open Xcode
2. Drag the iPhoneInfo folder into Xcode
3. Choose "Create groups" and "Copy items if needed"
4. Configure build settings and capabilities

## Build and Run

After creating the Xcode project:

```bash
# Build
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug build

# Run in simulator
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -destination 'platform=iOS Simulator,name=iPhone 15' run
```

## Common Issues

### CoreData Model File Missing

Create `iPhoneInfo.xcdatamodeld` file in Xcode:
1. File > New > File
2. iOS > Data Model
3. Name: "iPhoneInfo"
4. Add entity: BenchmarkResultEntity with required attributes

### Bundle Identifier

Set a unique bundle identifier:
- com.yourcompany.iPhoneInfo

### Code Signing

For development, use your Apple ID for automatic code signing.

## Fixing the generate_xcode_project.sh Script

The current `generate_xcode_project.sh` script generates invalid `.pbxproj` files. Xcode project files require:

1. Proper JSON structure with all required sections
2. Correct UUIDs for all objects
3. Proper references between objects
4. Build phases and configurations

The script needs to be rewritten using a proper project generator library or by studying valid .pbxproj file structure.

## Recommendation

**Do not manually generate Xcode project files.** Use Xcode IDE or proper tools like:
- xcodegen (https://github.com/yonaskolb/XcodeGen)
- tuist (https://tuist.io/)
- Xcode IDE (File > New Project)

The current project structure is correct for an iOS app with:
- SwiftUI views
- Metal-based GPU benchmarks
- CoreData persistence
- System monitoring services

All code is implemented and ready to use once the Xcode project is properly set up.
