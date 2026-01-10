//
//  HomeView.swift
//  iPhoneInfo
//
//  Home view displaying device and system information
//

import SwiftUI

struct HomeView: View {
    @StateObject private var deviceInfoService = DeviceInfoService.shared
    @StateObject private var thermalService = ThermalService.shared
    @State private var selectedSection: InfoSection? = nil
    @State private var extendedInfo: ExtendedDeviceInfo?

    enum InfoSection: String, CaseIterable {
        case device = "设备"
        case hardware = "硬件"
        case battery = "电池"
        case display = "显示"
        case system = "系统"
        case details = "详情"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // 快速状态卡片
                    QuickStatusCard(
                        deviceInfo: deviceInfoService.deviceInfo,
                        batteryInfo: deviceInfoService.batteryInfo,
                        thermalService: thermalService
                    )
                    .padding(.horizontal)

                    // 温度监控卡片
                    TemperatureMonitorCard(thermalService: thermalService)
                        .padding(.horizontal)

                    // Device Header Card
                    DeviceHeaderCard(
                        deviceInfo: deviceInfoService.deviceInfo,
                        batteryInfo: deviceInfoService.batteryInfo
                    )
                    .padding(.horizontal)

                    // Information Sections
                    ForEach(InfoSection.allCases, id: \.self) { section in
                        InfoSectionCard(
                            section: section,
                            deviceInfo: deviceInfoService.deviceInfo,
                            hardwareInfo: deviceInfoService.hardwareInfo,
                            batteryInfo: deviceInfoService.batteryInfo,
                            displayInfo: deviceInfoService.displayInfo,
                            systemInfo: deviceInfoService.systemInfo,
                            extendedInfo: extendedInfo
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("设备信息")
            .onAppear {
                loadExtendedInfo()
                thermalService.startMonitoring()
            }
            .onDisappear {
                thermalService.stopMonitoring()
            }
            .refreshable {
                deviceInfoService.loadAllInformation()
                loadExtendedInfo()
            }
        }
    }

    private func loadExtendedInfo() {
        extendedInfo = ExtendedDeviceDetailsService.shared.getExtendedDeviceInfo()
    }
}

// MARK: - Device Header Card
struct DeviceHeaderCard: View {
    let deviceInfo: DeviceInfo?
    let batteryInfo: BatteryInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deviceInfo?.name ?? "iPhone")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(deviceInfo?.systemVersion ?? "iOS")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let battery = batteryInfo {
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: batteryIcon(for: battery.state))
                                .foregroundColor(batteryColor(for: battery.state))
                            Text("\(battery.levelPercentage)%")
                                .font(.headline)
                        }
                        Text(battery.stateDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let device = deviceInfo, let hardware = getHardwareInfo() {
                HStack(spacing: 16) {
                    InfoDot(icon: "cpu", label: hardware.cpuModel, color: .blue)
                    InfoDot(icon: "memorychip", label: "\(Int(hardware.totalMemoryGB))GB", color: .purple)
                    InfoDot(icon: "internaldrive", label: "\(Int(hardware.totalStorageGB))GB", color: .green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private func batteryIcon(for state: UIDevice.BatteryState) -> String {
        switch state {
        case .charging: return "battery.100percent"
        case .full: return "battery.100percent"
        case .unplugged: return "battery.25percent"
        default: return "battery.0percent"
        }
    }

    private func batteryColor(for state: UIDevice.BatteryState) -> Color {
        switch state {
        case .charging, .full: return .green
        default: return .orange
        }
    }

    private func getHardwareInfo() -> HardwareInfo? {
        return DeviceInfoService.shared.hardwareInfo
    }
}

// MARK: - Info Dot
struct InfoDot: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Info Section Card
struct InfoSectionCard: View {
    let section: HomeView.InfoSection
    let deviceInfo: DeviceInfo?
    let hardwareInfo: HardwareInfo?
    let batteryInfo: BatteryInfo?
    let displayInfo: DisplayInfo?
    let systemInfo: SystemInfo?
    let extendedInfo: ExtendedDeviceInfo?

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Image(systemName: sectionIcon)
                    .foregroundColor(.blue)
                Text(section.rawValue)
                    .font(.headline)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }

            // Section Content
            if isExpanded {
                Divider()
                sectionContent
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch section {
        case .device:
            DeviceSectionContent(deviceInfo: deviceInfo, extendedInfo: extendedInfo)
        case .hardware:
            HardwareSectionContent(hardwareInfo: hardwareInfo, extendedInfo: extendedInfo)
        case .battery:
            BatterySectionContent(batteryInfo: batteryInfo, extendedInfo: extendedInfo)
        case .display:
            DisplaySectionContent(displayInfo: displayInfo, extendedInfo: extendedInfo)
        case .system:
            SystemSectionContent(systemInfo: systemInfo, extendedInfo: extendedInfo)
        case .details:
            DetailsSectionContent(extendedInfo: extendedInfo)
        }
    }

    private var sectionIcon: String {
        switch section {
        case .device: return "iphone"
        case .hardware: return "cpu"
        case .battery: return "battery.100percent"
        case .display: return "display"
        case .system: return "gearshape"
        case .details: return "info.circle"
        }
    }
}

// MARK: - Section Contents
struct DeviceSectionContent: View {
    let deviceInfo: DeviceInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRow(label: "设备名称", value: extendedInfo?.deviceType ?? deviceInfo?.deviceType ?? "Unknown")
            InfoRow(label: "设备型号", value: deviceInfo?.model ?? "Unknown")
            InfoRow(label: "营销名称", value: extendedInfo?.marketingName ?? "")
            InfoRow(label: "型号号码", value: extendedInfo?.modelNumber ?? "Unknown")
            InfoRow(label: "序列号", value: extendedInfo?.serialNumber ?? "Unknown")
            InfoRow(label: "屏幕尺寸", value: "\(deviceInfo?.screenWidth ?? 0) x \(deviceInfo?.screenHeight ?? 0)")
            InfoRow(label: "缩放比例", value: "@\(deviceInfo?.scale ?? 2)x")
        }
    }
}

struct HardwareSectionContent: View {
    let hardwareInfo: HardwareInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRow(label: "芯片型号", value: extendedInfo?.deviceType == "iPhone 16 Plus" ? "A18" : hardwareInfo?.cpuModel ?? "Unknown")
            InfoRow(label: "CPU 核心数", value: "\(hardwareInfo?.cpuCores ?? 0) 核")
            InfoRow(label: "GPU 核心数", value: "\(hardwareInfo?.gpuCores ?? 0) 核")
            InfoRow(label: "神经网络引擎", value: "\(hardwareInfo?.neuralEngineCores ?? 0) 核")
            Divider()
            InfoRow(label: "内存容量", value: String(format: "%.1f GB", hardwareInfo?.totalMemoryGB ?? 0))
            InfoRow(label: "存储容量", value: String(format: "%.0f GB", hardwareInfo?.totalStorageGB ?? 0))
            InfoRow(label: "可用存储", value: String(format: "%.1f GB", hardwareInfo?.availableStorageGB ?? 0))

            if let hardware = hardwareInfo {
                ProgressView(value: hardware.usedStorageGB, total: hardware.totalStorageGB)
                    .tint(.blue)
                Text("\(String(format: "%.1f", hardware.storageUsagePercentage))% 已使用")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()
            FeatureFlag(label: "LiDAR 激光雷达", isEnabled: hardwareInfo?.hasLiDAR ?? false)
            FeatureFlag(label: "ProMotion 自适应刷新率", isEnabled: hardwareInfo?.hasProMotion ?? false)
            FeatureFlag(label: "全天候显示", isEnabled: hardwareInfo?.hasAlwaysOnDisplay ?? false)
        }
    }
}

struct BatterySectionContent: View {
    let batteryInfo: BatteryInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let battery = batteryInfo {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("当前电量")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(battery.levelPercentage)%")
                            .font(.title)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 8)
                            .frame(width: 80, height: 80)

                        Circle()
                            .trim(from: 0, to: CGFloat(battery.level) / 1.0)
                            .stroke(batteryColor(for: battery.level), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: battery.level)
                    }
                }
                .padding()

                InfoRow(label: "状态", value: battery.stateDescription)
                InfoRow(label: "低电量模式", value: battery.isLowPowerModeEnabled ? "已开启" : "已关闭")

                // Extended battery info
                if let designCapacity = extendedInfo?.batteryDesignCapacity {
                    InfoRow(label: "设计容量", value: "\(designCapacity) mAh")
                }

                if let health = battery.health {
                    InfoRow(label: "电池健康", value: "\(health)%")
                }

                if let cycles = battery.cycleCount {
                    InfoRow(label: "循环次数", value: "\(cycles) 次")
                }

                if let temp = battery.temperature {
                    InfoRow(label: "温度", value: String(format: "%.1f°C", temp))
                }
            }
        }
    }

    private func batteryColor(for level: Float) -> Color {
        if level > 0.5 { return .green }
        if level > 0.2 { return .orange }
        return .red
    }
}

struct DisplaySectionContent: View {
    let displayInfo: DisplayInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRow(label: "屏幕尺寸", value: displayInfo.map { String(format: "%.1f 英寸", $0.screenSize) } ?? "Unknown")
            InfoRow(label: "分辨率", value: displayInfo?.resolution ?? "Unknown")
            InfoRow(label: "像素密度", value: displayInfo.map { "\($0.ppi) PPI" } ?? "Unknown")
            InfoRow(label: "刷新率", value: displayInfo?.refreshRateDescription ?? "Unknown")
            InfoRow(label: "最大亮度", value: extendedInfo.map { "\($0.brightness ?? 0) nits" } ?? "Unknown")
            InfoRow(label: "对比度", value: extendedInfo?.contrastRatio ?? "Unknown")
            InfoRow(label: "色彩深度", value: displayInfo.map { "\($0.colorDepth) 位" } ?? "Unknown")
            InfoRow(label: "HDR 支持", value: displayInfo?.hasHDR == true ? "支持" : "不支持")
            InfoRow(label: "Dolby Vision", value: extendedInfo?.DolbyVision == true ? "支持" : "不支持")
            InfoRow(label: "True Tone", value: extendedInfo?.TrueTone == true ? "支持" : "不支持")
            InfoRow(label: "P3 广色域", value: extendedInfo?.P3WideColor == true ? "支持" : "不支持")
            Divider()
            FeatureFlag(label: "ProMotion", isEnabled: displayInfo?.isProMotion ?? false)
            FeatureFlag(label: "始终显示", isEnabled: extendedInfo?.hasAlwaysOnDisplay ?? false)
        }
    }
}

struct SystemSectionContent: View {
    let systemInfo: SystemInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRow(label: "iOS 版本", value: systemInfo?.iOSVersion ?? "Unknown")
            InfoRow(label: "Build 版本", value: systemInfo?.buildNumber ?? "Unknown")
            InfoRow(label: "内核版本", value: systemInfo?.kernelVersion.components(separatedBy: " ").first ?? "Unknown")
            InfoRow(label: "运行时间", value: systemInfo?.uptimeDescription ?? "Unknown")
            InfoRow(label: "系统语言", value: systemInfo?.deviceLanguage ?? "Unknown")
            InfoRow(label: "时区", value: systemInfo?.timezone ?? "Unknown")
            InfoRow(label: "越狱状态", value: systemInfo?.isJailbroken == true ? "已越狱" : "未越狱")
            InfoRow(label: "开发者模式", value: extendedInfo?.developerMode == true ? "已开启" : "未开启")
            Divider()
            InfoRow(label: "序列号", value: extendedInfo?.serialNumber ?? "Unknown")
            InfoRow(label: "IMEI", value: extendedInfo?.imei ?? "Unknown")
            InfoRow(label: "地区代码", value: extendedInfo?.regionCode ?? "Unknown")
        }
    }
}

// MARK: - Details Section Content
struct DetailsSectionContent: View {
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let info = extendedInfo {
                // Production Info
                Text("生产信息")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Divider()

                if let year = info.productionYear {
                    InfoRow(label: "生产年份", value: "\(year) 年")
                }
                if let week = info.productionWeek {
                    InfoRow(label: "生产周", value: "第 \(week) 周")
                }
                if let factory = info.factoryCode {
                    InfoRow(label: "工厂代码", value: factory)
                }

                Divider()

                // Warranty Info
                Text("保修信息")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Divider()

                InfoRow(label: "保修状态", value: info.warrantyStatus.description)
                InfoRow(label: "AppleCare+", value: info.appleCareStatus ? "已购买" : "未购买")

                Divider()

                // Network Info
                Text("网络信息")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Divider()

                InfoRow(label: "WiFi 地址", value: info.wifiAddress ?? "Unknown")
                InfoRow(label: "蓝牙地址", value: info.bluetoothAddress ?? "Unknown")
                InfoRow(label: "网络类型", value: info.networkType ?? "Unknown")

                Divider()

                // Security Info
                Text("安全信息")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Divider()

                FeatureFlag(label: "激活锁", isEnabled: info.activationLockStatus)
                FeatureFlag(label: "越狱", isEnabled: info.jailbroken)
            } else {
                Text("正在加载详情...")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Quick Status Card
struct QuickStatusCard: View {
    let deviceInfo: DeviceInfo?
    let batteryInfo: BatteryInfo?
    @ObservedObject var thermalService: ThermalService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 设备名称和状态
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("iPhone 16 Pro Max")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(thermalService.thermalState.emoji + " " + thermalService.thermalState.rawValue)
                        .font(.caption)
                        .foregroundColor(thermalService.thermalState.color)
                }
                Spacer()
                if let battery = batteryInfo {
                    HStack(spacing: 4) {
                        Image(systemName: batteryIcon(for: battery.state))
                            .foregroundColor(batteryColor(for: battery.state))
                        Text("\(battery.levelPercentage)%")
                            .font(.headline)
                    }
                }
            }

            Divider()

            // 快速状态指标
            HStack(spacing: 20) {
                // 温度
                QuickStatusIndicator(
                    icon: "thermometer",
                    value: String(format: "%.0f°", thermalService.currentTemperature),
                    label: "温度",
                    color: thermalService.thermalState.color
                )

                // 发热指数
                QuickStatusIndicator(
                    icon: "flame.fill",
                    value: String(format: "%.0f", thermalService.heatIndex),
                    label: "发热指数",
                    color:heatIndexColor
                )

                // CPU占用
                QuickStatusIndicator(
                    icon: "cpu",
                    value: String(format: "%.0f%%", thermalService.cpuUsage),
                    label: "CPU",
                    color: .blue
                )
            }

            // 状态提示
            if thermalService.thermalState != .nominal {
                HStack {
                    Image(systemName: thermalService.thermalState.emoji)
                    Text(thermalService.thermalState.rawValue)
                        .font(.subheadline)
                    Spacer()
                    Text(thermalService.getTemperatureTrend().arrow)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private func batteryIcon(for state: UIDevice.BatteryState) -> String {
        switch state {
        case .charging: return "battery.100percent.bolt"
        case .full: return "battery.100percent"
        case .unplugged: return "battery.25percent"
        default: return "battery.0percent"
        }
    }

    private func batteryColor(for state: UIDevice.BatteryState) -> Color {
        switch state {
        case .charging, .full: return .green
        default: return .orange
        }
    }

    private var heatIndexColor: Color {
        switch thermalService.heatIndex {
        case 0..<25: return .green
        case 25..<50: return .yellow
        case 50..<75: return .orange
        default: return .red
        }
    }
}

// MARK: - Quick Status Indicator
struct QuickStatusIndicator: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Temperature Monitor Card
struct TemperatureMonitorCard: View {
    @ObservedObject var thermalService: ThermalService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "thermometer")
                    .foregroundColor(.blue)
                Text("温度监控")
                    .font(.headline)
                Spacer()
                Text(thermalService.thermalState.emoji + " " + thermalService.thermalState.rawValue)
                    .font(.caption)
                    .foregroundColor(thermalService.thermalState.color)
            }

            Divider()

            // 温度显示
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(String(format: "%.1f", thermalService.currentTemperature))°C")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(thermalService.thermalState.color)
                    Text("发热指数: \(thermalService.heatIndexDescription)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 温度趋势
                let trend = thermalService.getTemperatureTrend()
                VStack(spacing: 4) {
                    Text(trend.arrow)
                        .font(.title)
                    Text(trend.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 温度预测
            if let prediction = thermalService.predictTemperature(minutes: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                        Text("预测10分钟后: \(String(format: "%.1f", prediction.temperature))°C")
                            .font(.caption)
                        Text("(置信度: \(prediction.confidence))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.secondary)
                }
            }

            // 建议
            if !thermalService.getRecommendations().isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("建议:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(thermalService.getRecommendations().prefix(3), id: \.self) { rec in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(rec)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

struct FeatureFlag: View {
    let label: String
    let isEnabled: Bool

    var body: some View {
        HStack {
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundColor(isEnabled ? .green : .gray)
            Text(label)
                .font(.subheadline)
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
