# iPhone Info & Benchmark Tool

一款专业的 iPhone 系统信息查看和 3D 性能测试工具。

## 功能特性

- **系统信息**: 查看设备、硬件、电池、显示等详细信息
- **性能测试**: CPU、GPU、内存、存储性能基准测试
- **实时监控**: CPU、内存、GPU、电池实时状态监控
- **数据对比**: 历史记录、设备对比、云端排行

## 技术栈

- **语言**: Swift 5.9+
- **框架**: SwiftUI
- **最低支持**: iOS 15.0+
- **图形**: Metal (GPU 测试)

## 项目结构

```
iPhoneInfo/
├── App/                    # 应用入口
│   ├── iPhoneInfoApp.swift
│   └── ContentView.swift
├── Models/                 # 数据模型
│   └── DeviceModels.swift
├── Services/               # 服务层
│   └── DeviceInfoService.swift
└── Views/                  # 视图
    ├── HomeView.swift
    ├── BenchmarkView.swift
    ├── MonitorView.swift
    ├── CompareView.swift
    └── SettingsView.swift
```

## 安装测试版

### 通过 Xcode

1. 打开 `iPhoneInfo` 项目
2. 选择您的 iPhone 设备
3. 点击 Run 按钮

### 通过命令行

```bash
# 构建项目
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug build

# 安装到设备
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo \
  -destination 'id=DEVICE_UDID' install
```

## 开发计划

- [x] 基础框架搭建
- [x] 系统信息模块
- [ ] 性能测试模块 (Metal GPU 测试)
- [ ] 实时监控模块
- [ ] 数据对比模块
- [ ] 云端排行榜

## 许可证

MIT License

## 作者

Created with ❤️ using Claude Code
