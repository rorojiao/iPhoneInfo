# iPhone Info & Benchmark Tool - 安装说明

## 项目结构已创建完成！

### 📁 已创建的文件

```
iPhoneInfo/
├── iPhoneInfo.xcodeproj/        # Xcode 项目配置
├── iPhoneInfo/
│   ├── App/
│   │   ├── iPhoneInfoApp.swift  # 应用入口
│   │   └── ContentView.swift    # 主视图
│   ├── Models/
│   │   └── DeviceModels.swift   # 数据模型
│   ├── Services/
│   │   └── DeviceInfoService.swift  # 设备信息服务
│   ├── Views/
│   │   ├── HomeView.swift       # 首页（系统信息）
│   │   ├── BenchmarkView.swift  # 性能测试页
│   │   ├── MonitorView.swift    # 实时监控页
│   │   ├── CompareView.swift    # 数据对比页
│   │   └── SettingsView.swift   # 设置页
│   └── Info.plist               # 应用配置
├── Package.swift                # Swift Package 配置
├── PRD_iPhone_Info_Benchmark.md # 产品需求文档
├── CLAUDE.md                    # Claude Code 指南
├── README.md                    # 项目说明
└── generate_xcode_project.sh    # Xcode 项目生成器
```

## 安装到 iPhone 的步骤

### 方法 1: 使用 Xcode（推荐）

1. **打开 Xcode**
   ```bash
   cd "/Users/jiaojunze/Library/Mobile Documents/com~apple~CloudDocs/working_MAC/iphoneInfo"
   open iPhoneInfo.xcodeproj
   ```

2. **连接您的 iPhone**
   - 使用 USB 线连接 iPhone 到 Mac
   - 在 iPhone 上信任此电脑

3. **选择您的设备**
   - 在 Xcode 顶部工具栏，选择您的 iPhone 设备
   - 确保显示 "已签名"

4. **运行项目**
   - 点击 ▶️ 按钮或按 `Cmd+R`
   - 首次运行可能需要在 iPhone 上信任开发者证书

5. **信任应用（仅首次）**
   - 在 iPhone 上：设置 → 通用 → VPN与设备管理
   - 找到您的开发者证书，点击信任

### 方法 2: 使用命令行

```bash
# 1. 进入项目目录
cd "/Users/jiaojunze/Library/Mobile Documents/com~apple~CloudDocs/working_MAC/iphoneInfo"

# 2. 构建项目
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo -configuration Debug build

# 3. 获取设备 UDID
xcrun xctrace list devices

# 4. 安装到设备（替换 YOUR_DEVICE_UDID）
xcodebuild -project iPhoneInfo.xcodeproj -scheme iPhoneInfo \
  -destination 'id=YOUR_DEVICE_UDID' install
```

### 方法 3: 使用 TestFlight（需要 Apple 开发者账号）

1. 在 Xcode 中：Product → Archive
2. 构建完成后，选择 "Distribute App"
3. 选择 TestFlight
4. 上传到 App Store Connect
5. 在 TestFlight 中添加内部测试人员

## 免费开发者账号的限制

使用免费 Apple ID 签名的应用：
- ✅ 可以安装到自己的设备
- ✅ 有效期 7 天，之后需要重新安装
- ❌ 不能发布到 App Store
- ❌ 不能使用 TestFlight

## 常见问题

### Q: 出现 "Could not launch" 错误
A: 在 iPhone 上：设置 → 通用 → VPN与设备管理 → 信任开发者

### Q: 应用闪退
A: 检查 iOS 版本是否 >= 15.0

### Q: 如何查看更多设备信息
A: 某些信息（如电池循环次数）需要企业证书才能访问

## 下一步开发计划

当前已完成的基础版本包含：

- ✅ 完整的 SwiftUI 界面
- ✅ 设备、硬件、电池、显示、系统信息
- ✅ 性能测试界面框架
- ✅ 实时监控界面框架
- ✅ 历史记录和对比界面

待实现功能：
- [ ] Metal GPU 性能测试（需要额外开发）
- [ ] CPU 基准测试算法
- [ ] 内存和存储性能测试
- [ ] 实时系统监控数据获取
- [ ] CoreData 历史记录存储
- [ ] 云端排行榜 API

## 技术支持

如有问题，请查看：
- 产品需求文档：`PRD_iPhone_Info_Benchmark.md`
- 开发指南：`CLAUDE.md`
