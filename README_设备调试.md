# 设备调试信息说明

## 更新内容 (2025-01-10)

### 1. 温度监控改进 ✅
- **30秒滑动窗口平均**：温度现在使用30秒的平均值，不再受瞬时数据影响
- **更稳定的读数**：温度显示更加稳定，不会频繁跳动
- **温度缓冲区**：使用最近30个数据点计算平均值

**技术实现**：
```swift
// 30秒滑动窗口
private var temperatureBuffer: [Double] = []
private let maxBufferSize = 30

// 计算平均温度
let averagedTemperature = temperatureBuffer.reduce(0, +) / Double(temperatureBuffer.count)
```

### 2. 性能模式透明化 ✅
- **说明iOS限制**：明确说明性能模式的实际能力和限制
- **低电量模式检测**：检测系统低电量模式并给出建议
- **透明的描述**：每种模式都有清楚的功能说明

**iOS 限制说明**：
- ❌ 无法直接控制 CPU/GPU 频率
- ❌ 无法修改降频阈值
- ❌ 无法改变进程优先级
- ✅ 可以监控和记录
- ✅ 可以提供建议和引导
- ✅ 可以检测系统状态

### 3. 设备调试工具 ✅
- **新增 DeviceDebugView**：显示真实的硬件信息
- **hw.machine 显示**：显示设备的真实型号标识符
- **新增"调试"标签页**：可以直接在底部导航栏访问

---

## 如何使用设备调试工具

### 访问步骤

1. 打开 App
2. 点击底部导航栏的 **"调试"** 标签（瓢虫图标 🐞）
3. 查看 "hw.machine (真实型号)" 部分显示的值
4. 将该值告诉我，例如：`iPhone16,1`

### hw.machine 值对应表

| hw.machine | 设备型号 |
|-----------|---------|
| iPhone17,1 | iPhone 16 |
| iPhone17,2 | iPhone 16 Plus |
| iPhone17,3 | iPhone 16 Pro |
| iPhone17,4 | iPhone 16 Pro Max |
| iPhone16,1 | iPhone 15 |
| iPhone16,2 | iPhone 15 Plus |
| iPhone15,4 | iPhone 14 Pro |
| iPhone15,5 | iPhone 14 Pro Max |
| iPhone14,7 | iPhone 13 |
| iPhone14,8 | iPhone 13 mini |
| iPhone14,5 | iPhone 13 Pro |
| iPhone14,6 | iPhone 13 Pro Max |
| ... | ... |

---

## 下一步

**请打开 App，点击"调试"标签页，然后告诉我您的设备显示的 hw.machine 值是什么？**

例如：
- 如果显示 "iPhone16,1"，您使用的是 iPhone 15
- 如果显示 "iPhone15,4"，您使用的是 iPhone 14 Pro
- 如果显示 "iPhone14,7"，您使用的是 iPhone 13

知道真实型号后，我会更新设备型号映射表，修复设备名称显示错误的问题。

---

## 已知问题

### 警告 (不影响使用)
- ⚠️ `UIScreen.main` 在 iOS 26.0 已弃用（仍可使用，待更新）
- ⚠️ switch 语句缺少 `.unknown` case（不影响功能）

### 待修复
- 需要根据您的实际设备型号更新映射表

---

## 技术限制说明

由于 iOS 沙盒安全机制，第三方应用无法：
- 获取其他应用的 CPU/GPU 使用率
- 控制系统级别的 CPU/GPU 频率
- 修改降频阈值
- 获取后台应用列表
- 直接控制进程优先级

因此，"性能模式"主要是：
- 监控设备状态（温度、CPU占用）
- 提供优化建议
- 引导用户手动操作
- 记录性能数据

这是 iOS 系统的安全限制，所有第三方应用都面临同样的限制。
