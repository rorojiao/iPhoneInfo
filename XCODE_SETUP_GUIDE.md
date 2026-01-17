# Xcode 项目设置指南

## 问题描述

Xcode 项目的 `.pbxproj` 文件使用特殊的 "Old-Style ASCII Property List" 格式，无法通过 Python 脚本自动生成。

## 解决方案

### 步骤 1: 手动创建 Xcode 项目

1. **打开 Xcode**
   ```bash
   open -a Xcode
   ```

2. **创建新项目**
   - `File` → `New` → `Project`
   - 选择 `iOS` → `App`
   - 填写信息：
     - Product Name: `iPhoneInfo`
     - Team: 选择您的开发团队（如果有的话）
     - Organization Identifier: `com.example`
     - Bundle Identifier: `com.example.iPhoneInfo`
     - Interface: `SwiftUI`
     - Language: `Swift`
     - Use Core Data: ✅ (勾选)
   - 点击 `Next`
   - 保存位置: 选择当前目录
     - `/Users/jiaojunze/Library/Mobile Documents/com~apple~CloudDocs/working_MAC/`
   - 点击 `Create`

3. **关闭 Xcode** (先关闭项目)

### 步骤 2: 添加源代码文件到项目

打开 Xcode 项目：
```bash
open iPhoneInfo.xcodeproj
```

在 Xcode 中：

1. **删除默认文件**
   - 在项目导航器中，找到 `iPhoneInfo` 文件夹
   - 删除 `ContentView.swift` (Move to Trash)

2. **添加现有文件**
   - 在 Finder 中打开 `iPhoneInfo/` 目录
   - 将以下文件/文件夹拖到 Xcode 的 `iPhoneInfo` 文件夹中：
     ```
     iPhoneInfo/
     ├── App/                    # 拖入整个 App 文件夹
     │   ├── iPhoneInfoApp.swift
     │   └── ContentView.swift
     ├── Views/                  # 拖入整个 Views 文件夹
     │   ├── HomeView.swift
     │   ├── BenchmarkView.swift
     │   ├── MonitorView.swift
     │   ├── CompareView.swift
     │   └── SettingsView.swift
     ├── Models/                 # 拖入整个 Models 文件夹
     │   ├── DeviceModels.swift
     │   └── CoreDataModels.swift
     ├── Services/               # 拖入整个 Services 文件夹
     │   ├── DeviceInfoService.swift
     │   ├── ExtendedDeviceDetailsService.swift
     │   ├── SystemMonitor.swift
     │   ├── BenchmarkCoordinator.swift
     │   ├── SensorService.swift
     │   ├── ThermalService.swift
     │   ├── StorageBenchmarkService.swift
     │   └── NetworkService.swift
     ├── Benchmark/              # 拖入整个 Benchmark 文件夹
     │   ├── CPUBenchmark.swift
     │   ├── MetalBenchmark.swift
     │   ├── MemoryBenchmark.swift
     │   ├── StorageBenchmark.swift
     │   ├── GPUStressTest.swift
     │   └── CoreMarkBenchmark.swift
     ├── SystemInfo/             # 拖入整个 SystemInfo 文件夹 (如果有文件)
     ├── iPhoneInfo.xcdatamodeld # 拖入 CoreData 模型
     ├── Info.plist              # 拖入 Info.plist
     └── Assets.xcassets         # 拖入资源文件 (如果有)
     ```

3. **确认添加选项**
   - 在拖入时，会弹出对话框
   - 选择 "Copy items if needed"
   - 确保 "Create groups" 被选中
   - 确保 "Add to targets: iPhoneInfo" 被勾选
   - 点击 `Finish`

### 步骤 3: 配置项目设置

1. **选择项目**
   - 在项目导航器顶部，点击蓝色 `iPhoneInfo` 项目图标

2. **配置 Deployment Target**
   - 选择 `iPhoneInfo` target
   - 在 `General` 标签页
   - `Minimum Deployments`: iOS 15.0

3. **配置 Bundle Identifier**
   - `Bundle Identifier`: `com.example.iPhoneInfo`
   - 如果您有自己的域名，可以修改为: `com.yourcompany.iPhoneInfo`

4. **配置 Signing**
   - `Signing & Capabilities` 标签页
   - `Automatically manage signing`: ✅ (勾选)
   - `Team`: 选择您的 Apple Developer 账户
     - 如果没有，可以免费注册 Apple ID
     - 或者选择 "Add an Account..."

5. **添加 Frameworks (如果需要)**
   - 在 `Frameworks, Libraries, and Embedded Content`
   - 点击 `+` 添加以下框架（如果还没有自动添加）:
     - `MetalKit.framework`
     - `Metal.framework`
     - `CoreMotion.framework`
     - `SystemConfiguration.framework`

### 步骤 4: 构建项目

1. **选择设备**
   - 点击 Xcode 顶部的设备选择器
   - 选择 `iPhone 15 Pro` 或 `iPhone 14 Pro` (或其他模拟器)

2. **构建项目**
   - 按 `Cmd + B` 或点击菜单 `Product` → `Build`

3. **修复错误**
   - 如果有编译错误，查看右侧的 Issue Navigator
   - 常见错误：
     - 缺少 import 语句
     - CoreData 模型引用错误
     - Metal 框架未添加

### 步骤 5: 运行应用

1. **选择目标设备**
   - 可以选择 iOS 模拟器
   - 或者连接真实的 iPhone 设备（需要信任证书）

2. **运行**
   - 按 `Cmd + R` 或点击 `Run` 按钮 (▶️)

3. **查看输出**
   - 在 Xcode 底部的 Console 中查看日志
   - 应用应该会显示主界面，包含 5 个标签页

## 常见问题

### Q1: 提示 "Command line invocation: ... archiveVersion should be an instance inheriting from NSString"
**A**: 这是因为 `.pbxproj` 文件格式不正确。请手动创建 Xcode 项目。

### Q2: 提示 "Missing required module 'Metal'"
**A**: 添加 Metal 框架：
1. 选择项目
2. 选择 target
3. "Signing & Capabilities" → "+ Capability" → "Game Center" (这会添加 Metal)
或者直接在 "Build Phases" → "Link Binary With Libraries" 中添加

### Q3: CoreData 模型无法识别
**A**: 确保 `iPhoneInfo.xcdatamodeld` 被添加到项目的 `Build Phases` → `Compile Sources`

### Q4: "Use of unresolved identifier 'SystemMonitor'"
**A**: 确保所有 Swift 文件都已添加到项目中，并且 `SystemMonitor.swift` 等文件在 "Compile Sources" 列表中。

## 下一步

项目成功构建和运行后：

1. **测试所有功能**
   - 首页：查看设备信息
   - 测试：运行 CPU/GPU/内存/存储基准测试
   - 监控：查看实时系统监控
   - 对比：查看历史记录和对比
   - 设置：导出数据（CSV/JSON/PDF）

2. **调试和优化**
   - 使用 Xcode 的 Instruments 工具分析性能
   - 检查内存泄漏
   - 优化 Metal 渲染性能

3. **准备发布**
   - 添加 AppIcon
   - 配置 LaunchScreen
   - 准备截图和描述
   - 上传到 App Store Connect

## 验证清单

- [ ] Xcode 项目已创建
- [ ] 所有 Swift 文件已添加到项目
- [ ] CoreData 模型已添加
- [ ] Info.plist 已配置
- [ ] Deployment Target 设置为 iOS 15.0
- [ ] Code Signing 已配置
- [ ] 项目可以成功构建 (Cmd + B)
- [ ] 应用可以在模拟器中运行 (Cmd + R)
- [ ] 所有 5 个标签页都能正常显示
- [ ] 基准测试可以运行
- [ ] 实时监控数据显示正常
- [ ] 数据导出功能正常

## 技术支持

如果遇到问题：
1. 查看 Xcode 的 Console 输出
2. 检查编译错误和警告
3. 使用断点调试
4. 查看 `PROJECT_RULES.md` 和 `AGENTS.md` 了解项目规范
