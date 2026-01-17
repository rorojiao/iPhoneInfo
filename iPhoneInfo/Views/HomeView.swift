//
//  HomeView.swift
//  iPhoneInfo
//
//  Unified home view - ROG HUD Style (Optimized)
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    @StateObject private var gamerDashboardService = GamerDashboardService.shared
    @StateObject private var benchmarkCoordinator = BenchmarkCoordinator.shared
    @StateObject private var deviceInfoService = DeviceInfoService.shared
    @StateObject private var thermalService = ThermalService.shared

    @State private var extendedInfo: ExtendedDeviceInfo?
    @State private var showSustainedTest = false
    @State private var showAdviceSheet = false

    enum InfoSection: String, CaseIterable {
        case device = "设备"
        case hardware = "硬件"
        case battery = "电池"
        case display = "显示"
        case system = "系统"
        case details = "详情"
    }

    var body: some View {
        ZStack {
            HUDBg()

            ScrollView {
                VStack(spacing: 12) {
                    // Top Header: Device + Status
                    ROGUnifiedHeader(
                        deviceInfo: deviceInfoService.deviceInfo,
                        batteryInfo: deviceInfoService.batteryInfo,
                        thermalService: thermalService,
                        snapshot: gamerDashboardService.snapshot
                    )

                    // Quick Status Cards (Performance + Risk)
                    ROGStatusCardsRow(snapshot: gamerDashboardService.snapshot)

                    // Smart Advice Button
                    ROGSmartAdviceButton(snapshot: gamerDashboardService.snapshot) {
                        showAdviceSheet = true
                    }

                    // Quick Action Buttons
                    ROGQuickActionRow(
                        onStabilityTest: { showSustainedTest = true },
                        onBenchmark: { appState.currentTab = .benchmark },
                        onMonitor: { appState.currentTab = .monitor }
                    )

                    // Live Quick Stats
                    ROGLiveStatsRow(snapshot: gamerDashboardService.snapshot)

                    // Collapsible Device Info Sections
                    ForEach(InfoSection.allCases, id: \.self) { section in
                        ROGCompactInfoSection(
                            section: section,
                            deviceInfo: deviceInfoService.deviceInfo,
                            hardwareInfo: deviceInfoService.hardwareInfo,
                            batteryInfo: deviceInfoService.batteryInfo,
                            displayInfo: deviceInfoService.displayInfo,
                            systemInfo: deviceInfoService.systemInfo,
                            extendedInfo: extendedInfo
                        )
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
        }
        .onAppear {
            loadExtendedInfo()
            thermalService.startMonitoring()
            gamerDashboardService.startGamerMonitoring()
        }
        .onDisappear {
            thermalService.stopMonitoring()
            gamerDashboardService.stopGamerMonitoring()
        }
        .fullScreenCover(isPresented: $showSustainedTest) {
            SustainedGamingTestView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showAdviceSheet) {
            ROGAdviceSheet(snapshot: gamerDashboardService.snapshot)
        }
    }

    private func loadExtendedInfo() {
        extendedInfo = ExtendedDeviceDetailsService.shared.getExtendedDeviceInfo()
    }
}

// MARK: - ROG Unified Header
private struct ROGUnifiedHeader: View {
    let deviceInfo: DeviceInfo?
    let batteryInfo: BatteryInfo?
    @ObservedObject var thermalService: ThermalService
    let snapshot: GamerDashboardService.Snapshot

    var body: some View {
        HStack(spacing: 12) {
            // Device info
            VStack(alignment: .leading, spacing: 2) {
                Text(deviceInfo?.name ?? "iPhone")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(HUDTheme.textPrimary)
                HStack(spacing: 4) {
                    Text(thermalService.thermalState.emoji)
                        .font(.caption)
                    Text(thermalService.thermalState.rawValue)
                        .font(.caption)
                        .foregroundColor(thermalService.thermalState.color)
                }
            }

            Spacer()

            // Temperature
            VStack(spacing: 0) {
                Text(String(format: "%.0f°", thermalService.currentTemperature))
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(thermalService.thermalState.color)
                Text("温度")
                    .font(.system(size: 9))
                    .foregroundColor(HUDTheme.textSecondary)
            }

            // Battery
            if let battery = batteryInfo {
                VStack(spacing: 0) {
                    HStack(spacing: 2) {
                        Image(systemName: batteryIcon(for: battery.state))
                            .font(.system(size: 10))
                            .foregroundColor(batteryColor(for: battery.state))
                        Text("\(battery.levelPercentage)%")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(HUDTheme.textPrimary)
                    }
                    Text("电量")
                        .font(.system(size: 9))
                        .foregroundColor(HUDTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                .stroke(thermalService.thermalState.color.opacity(0.5), lineWidth: HUDTheme.borderWidth)
        )
        .cornerRadius(HUDTheme.smallCornerRadius)
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
        case .charging, .full: return HUDTheme.neonGreen
        default: return HUDTheme.neonOrange
        }
    }
}

// MARK: - ROG Status Cards Row
private struct ROGStatusCardsRow: View {
    let snapshot: GamerDashboardService.Snapshot

    var body: some View {
        HStack(spacing: 10) {
            // Performance Card
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "speedometer")
                        .font(.caption)
                        .foregroundColor(HUDTheme.rogCyan)
                    Text("性能")
                        .font(.caption)
                        .foregroundColor(HUDTheme.textSecondary)
                }
                Text(performanceText)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(HUDTheme.textPrimary)
                Text("热状态: \(snapshot.thermalState)")
                    .font(.system(size: 10))
                    .foregroundColor(HUDTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.black.opacity(0.55))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(HUDTheme.rogCyan.opacity(0.6), lineWidth: HUDTheme.borderWidth)
            )
            .cornerRadius(10)

            // Risk Card
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(riskColor)
                    Text("风险")
                        .font(.caption)
                        .foregroundColor(HUDTheme.textSecondary)
                }
                Text(snapshot.risk.rawValue)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(riskColor)
                Text(riskDetailText)
                    .font(.system(size: 10))
                    .foregroundColor(HUDTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.black.opacity(0.55))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(riskColor.opacity(0.6), lineWidth: HUDTheme.borderWidth)
            )
            .cornerRadius(10)
        }
    }

    private var performanceText: String {
        guard let value = snapshot.performancePercent else { return "--%" }
        return "\(Int(value))%"
    }

    private var riskColor: Color {
        switch snapshot.risk {
        case .low: return HUDTheme.neonGreen
        case .medium: return HUDTheme.neonOrange
        case .high: return HUDTheme.rogRed
        }
    }

    private var riskDetailText: String {
        if snapshot.reasons.isEmpty || snapshot.reasons.first == "等待监控数据" || snapshot.reasons.first == "等待评估" {
            return "状态良好"
        }
        return snapshot.reasons.first ?? "-"
    }
}

// MARK: - ROG Smart Advice Button
private struct ROGSmartAdviceButton: View {
    let snapshot: GamerDashboardService.Snapshot
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("智能建议")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(HUDTheme.textPrimary)
                Spacer()
                Text(adviceSummary)
                    .font(.caption)
                    .foregroundColor(HUDTheme.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(HUDTheme.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.55), Color.black.opacity(0.45)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private var adviceSummary: String {
        let advice = GamerDashboardService.shared.oneTapOptimizationAdvice()
        if advice.first == "当前状态良好" {
            return "✓ 状态良好"
        }
        return "\(advice.count) 条建议"
    }
}

// MARK: - ROG Advice Sheet
private struct ROGAdviceSheet: View {
    let snapshot: GamerDashboardService.Snapshot
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("智能建议")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(HUDTheme.textPrimary)
                    Spacer()
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(HUDTheme.rogCyan)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)

                // Advice List
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(GamerDashboardService.shared.oneTapOptimizationAdvice().enumerated()), id: \.offset) { index, advice in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: adviceIcon(for: advice))
                                    .font(.system(size: 18))
                                    .foregroundColor(adviceColor(for: advice))
                                    .frame(width: 24)

                                Text(advice)
                                    .font(.subheadline)
                                    .foregroundColor(HUDTheme.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(adviceColor(for: advice).opacity(0.4), lineWidth: HUDTheme.borderWidth)
                            )
                            .cornerRadius(10)
                        }

                        // System status summary
                        VStack(alignment: .leading, spacing: 8) {
                            Text("当前状态")
                                .font(.caption)
                                .foregroundColor(HUDTheme.textSecondary)

                            HStack(spacing: 16) {
                                ROGAdviceStatusItem(label: "热状态", value: snapshot.thermalState, color: thermalColor)
                                ROGAdviceStatusItem(label: "电量", value: "\(snapshot.batteryLevelPercent)%", color: batteryColor)
                                if let latency = snapshot.latencyMs {
                                    ROGAdviceStatusItem(label: "延迟", value: "\(Int(latency))ms", color: latencyColor(latency))
                                }
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
                        )
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func adviceIcon(for advice: String) -> String {
        if advice.contains("状态良好") { return "checkmark.circle.fill" }
        if advice.contains("电") { return "battery.25percent" }
        if advice.contains("热") || advice.contains("温") { return "thermometer.high" }
        if advice.contains("网络") || advice.contains("延迟") { return "wifi.exclamationmark" }
        if advice.contains("丢包") { return "antenna.radiowaves.left.and.right" }
        return "info.circle"
    }

    private func adviceColor(for advice: String) -> Color {
        if advice.contains("状态良好") { return HUDTheme.neonGreen }
        if advice.contains("严重") || advice.contains("过热") { return HUDTheme.rogRed }
        return HUDTheme.neonOrange
    }

    private var thermalColor: Color {
        switch snapshot.thermalState {
        case "正常": return HUDTheme.neonGreen
        case "温热": return .yellow
        case "发热": return HUDTheme.neonOrange
        default: return HUDTheme.rogRed
        }
    }

    private var batteryColor: Color {
        if snapshot.batteryLevelPercent > 50 { return HUDTheme.neonGreen }
        if snapshot.batteryLevelPercent > 20 { return HUDTheme.neonOrange }
        return HUDTheme.rogRed
    }

    private func latencyColor(_ ms: Double) -> Color {
        if ms < 50 { return HUDTheme.neonGreen }
        if ms < 100 { return HUDTheme.neonOrange }
        return HUDTheme.rogRed
    }
}

private struct ROGAdviceStatusItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(HUDTheme.textSecondary)
        }
    }
}

// MARK: - ROG Quick Action Row
private struct ROGQuickActionRow: View {
    let onStabilityTest: () -> Void
    let onBenchmark: () -> Void
    let onMonitor: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ROGActionButton(title: "稳定性测试", icon: "waveform.path", action: onStabilityTest)
            ROGActionButton(title: "跑分", icon: "speedometer", action: onBenchmark)
            ROGActionButton(title: "监控", icon: "chart.xyaxis.line", action: onMonitor)
        }
    }
}

private struct ROGActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(HUDTheme.rogCyan)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(HUDTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.55))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ROG Live Stats Row
private struct ROGLiveStatsRow: View {
    let snapshot: GamerDashboardService.Snapshot

    var body: some View {
        HStack(spacing: 8) {
            ROGMiniStat(icon: "cpu", label: "CPU", value: String(format: "%.0f%%", snapshot.cpuUsage))
            ROGMiniStat(icon: "memorychip", label: "内存", value: String(format: "%.0f%%", snapshot.memoryUsage))
            ROGMiniStat(icon: "cube", label: "GPU", value: String(format: "%.0f%%", snapshot.gpuUsage))
            if let latency = snapshot.latencyMs {
                ROGMiniStat(icon: "network", label: "延迟", value: "\(Int(latency))ms")
            } else {
                ROGMiniStat(icon: "network", label: "延迟", value: "--")
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
        )
        .cornerRadius(10)
    }
}

private struct ROGMiniStat: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(HUDTheme.rogCyan)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(HUDTheme.textPrimary)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(HUDTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ROG Compact Info Section
private struct ROGCompactInfoSection: View {
    let section: HomeView.InfoSection
    let deviceInfo: DeviceInfo?
    let hardwareInfo: HardwareInfo?
    let batteryInfo: BatteryInfo?
    let displayInfo: DisplayInfo?
    let systemInfo: SystemInfo?
    let extendedInfo: ExtendedDeviceInfo?

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            Button(action: {
                withAnimation(.spring(response: 0.25)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: sectionIcon)
                        .foregroundColor(HUDTheme.rogCyan)
                        .frame(width: 20)
                        .font(.system(size: 14))
                    Text(section.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HUDTheme.textPrimary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11))
                        .foregroundColor(HUDTheme.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            // Section Content
            if isExpanded {
                Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 12)
                sectionContent
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
        }
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isExpanded ? HUDTheme.rogCyan.opacity(0.5) : HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
        )
        .cornerRadius(10)
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch section {
        case .device:
            ROGDeviceSectionContent(deviceInfo: deviceInfo, extendedInfo: extendedInfo)
        case .hardware:
            ROGHardwareSectionContent(hardwareInfo: hardwareInfo, extendedInfo: extendedInfo)
        case .battery:
            ROGBatterySectionContent(batteryInfo: batteryInfo, extendedInfo: extendedInfo)
        case .display:
            ROGDisplaySectionContent(displayInfo: displayInfo, extendedInfo: extendedInfo)
        case .system:
            ROGSystemSectionContent(systemInfo: systemInfo, extendedInfo: extendedInfo)
        case .details:
            ROGDetailsSectionContent(extendedInfo: extendedInfo)
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

// MARK: - Section Contents (Compact versions)
private struct ROGDeviceSectionContent: View {
    let deviceInfo: DeviceInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ROGInfoRow(label: "设备名称", value: extendedInfo?.deviceType ?? deviceInfo?.deviceType ?? "Unknown")
            ROGInfoRow(label: "型号", value: deviceInfo?.model ?? "Unknown")
            ROGInfoRow(label: "营销名称", value: extendedInfo?.marketingName ?? "")
            ROGInfoRow(label: "型号号码", value: extendedInfo?.modelNumber ?? "Unknown")
            ROGInfoRow(label: "序列号", value: extendedInfo?.serialNumber ?? "Unknown")
        }
    }
}

private struct ROGHardwareSectionContent: View {
    let hardwareInfo: HardwareInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ROGInfoRow(label: "芯片", value: hardwareInfo?.cpuModel ?? "Unknown")
            ROGInfoRow(label: "CPU", value: "\(hardwareInfo?.cpuCores ?? 0) 核")
            ROGInfoRow(label: "GPU", value: "\(hardwareInfo?.gpuCores ?? 0) 核")
            ROGInfoRow(label: "NPU", value: "\(hardwareInfo?.neuralEngineCores ?? 0) 核")
            ROGInfoRow(label: "内存", value: String(format: "%.1f GB", hardwareInfo?.totalMemoryGB ?? 0))
            ROGInfoRow(label: "存储", value: String(format: "%.0f GB", hardwareInfo?.totalStorageGB ?? 0))

            if let hardware = hardwareInfo {
                HStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)
                                .cornerRadius(2)

                            Rectangle()
                                .fill(HUDTheme.rogCyan)
                                .frame(width: geometry.size.width * CGFloat(hardware.storageUsagePercentage / 100), height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 4)

                    Text("\(String(format: "%.0f", hardware.storageUsagePercentage))%")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(HUDTheme.textSecondary)
                }
            }
        }
    }
}

private struct ROGBatterySectionContent: View {
    let batteryInfo: BatteryInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let battery = batteryInfo {
                HStack {
                    Text("电量")
                        .foregroundColor(HUDTheme.textSecondary)
                    Spacer()
                    Text("\(battery.levelPercentage)%")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(batteryColor(for: battery.level))
                }

                ROGInfoRow(label: "状态", value: battery.stateDescription)
                ROGInfoRow(label: "低电量模式", value: battery.isLowPowerModeEnabled ? "已开启" : "已关闭")

                if let health = battery.health {
                    ROGInfoRow(label: "电池健康", value: "\(health)%")
                }
                if let cycles = battery.cycleCount {
                    ROGInfoRow(label: "循环次数", value: "\(cycles) 次")
                }
            }
        }
    }

    private func batteryColor(for level: Float) -> Color {
        if level > 0.5 { return HUDTheme.neonGreen }
        if level > 0.2 { return HUDTheme.neonOrange }
        return HUDTheme.rogRed
    }
}

private struct ROGDisplaySectionContent: View {
    let displayInfo: DisplayInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ROGInfoRow(label: "屏幕", value: displayInfo.map { String(format: "%.1f\"", $0.screenSize) } ?? "Unknown")
            ROGInfoRow(label: "分辨率", value: displayInfo?.resolution ?? "Unknown")
            ROGInfoRow(label: "PPI", value: displayInfo.map { "\($0.ppi)" } ?? "Unknown")
            ROGInfoRow(label: "刷新率", value: displayInfo?.refreshRateDescription ?? "Unknown")
            ROGInfoRow(label: "亮度", value: extendedInfo.map { "\($0.brightness ?? 0) nits" } ?? "Unknown")

            HStack(spacing: 16) {
                ROGFeatureFlag(label: "HDR", isEnabled: displayInfo?.hasHDR ?? false)
                ROGFeatureFlag(label: "ProMotion", isEnabled: displayInfo?.isProMotion ?? false)
            }
        }
    }
}

private struct ROGSystemSectionContent: View {
    let systemInfo: SystemInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ROGInfoRow(label: "iOS", value: systemInfo?.iOSVersion ?? "Unknown")
            ROGInfoRow(label: "Build", value: systemInfo?.buildNumber ?? "Unknown")
            ROGInfoRow(label: "运行时间", value: systemInfo?.uptimeDescription ?? "Unknown")
            ROGInfoRow(label: "语言", value: systemInfo?.deviceLanguage ?? "Unknown")

            HStack(spacing: 16) {
                ROGFeatureFlag(label: "越狱", isEnabled: systemInfo?.isJailbroken ?? false)
                ROGFeatureFlag(label: "开发者模式", isEnabled: extendedInfo?.developerMode ?? false)
            }
        }
    }
}

private struct ROGDetailsSectionContent: View {
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let info = extendedInfo {
                if let year = info.productionYear {
                    ROGInfoRow(label: "生产年份", value: "\(year)")
                }
                ROGInfoRow(label: "保修", value: info.warrantyStatus.description)
                ROGFeatureFlag(label: "AppleCare+", isEnabled: info.appleCareStatus)

                Divider().background(Color.white.opacity(0.1))

                ROGInfoRow(label: "WiFi", value: info.wifiAddress ?? "Unknown")
                ROGInfoRow(label: "网络", value: info.networkType ?? "Unknown")

                HStack(spacing: 16) {
                    ROGFeatureFlag(label: "激活锁", isEnabled: info.activationLockStatus)
                    ROGFeatureFlag(label: "越狱", isEnabled: info.jailbroken)
                }
            } else {
                HStack {
                    ProgressView()
                        .tint(HUDTheme.rogCyan)
                    Text("加载中...")
                        .foregroundColor(HUDTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - Helper Components
private struct ROGInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(HUDTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(HUDTheme.textPrimary)
                .lineLimit(1)
        }
    }
}

private struct ROGFeatureFlag: View {
    let label: String
    let isEnabled: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle")
                .font(.system(size: 10))
                .foregroundColor(isEnabled ? HUDTheme.neonGreen : HUDTheme.textSecondary.opacity(0.5))
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(HUDTheme.textSecondary)
        }
    }
}

// MARK: - Legacy Components (kept for compatibility)
struct DeviceHeaderCard: View {
    let deviceInfo: DeviceInfo?
    let batteryInfo: BatteryInfo?

    var body: some View {
        EmptyView()
    }
}

struct InfoDot: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        EmptyView()
    }
}

struct InfoSectionCard: View {
    let section: HomeView.InfoSection
    let deviceInfo: DeviceInfo?
    let hardwareInfo: HardwareInfo?
    let batteryInfo: BatteryInfo?
    let displayInfo: DisplayInfo?
    let systemInfo: SystemInfo?
    let extendedInfo: ExtendedDeviceInfo?

    var body: some View {
        ROGCompactInfoSection(
            section: section,
            deviceInfo: deviceInfo,
            hardwareInfo: hardwareInfo,
            batteryInfo: batteryInfo,
            displayInfo: displayInfo,
            systemInfo: systemInfo,
            extendedInfo: extendedInfo
        )
    }
}

struct QuickStatusCard: View {
    let deviceInfo: DeviceInfo?
    let batteryInfo: BatteryInfo?
    @ObservedObject var thermalService: ThermalService

    var body: some View {
        EmptyView()
    }
}

struct TemperatureMonitorCard: View {
    @ObservedObject var thermalService: ThermalService

    var body: some View {
        EmptyView()
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        ROGInfoRow(label: label, value: value)
    }
}

struct FeatureFlag: View {
    let label: String
    let isEnabled: Bool

    var body: some View {
        ROGFeatureFlag(label: label, isEnabled: isEnabled)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
