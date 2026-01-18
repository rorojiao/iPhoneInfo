//
//  HomeView.swift
//  iPhoneInfo
//
//  Unified home view - ROG HUD Style (Based on Design Mockup)
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

    var body: some View {
        ZStack {
            // Background with circuit pattern
            HUDBg()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    ROGHomeHeader(deviceName: deviceInfoService.deviceInfo?.name ?? "iPhone")

                    // Main Stability Gauge
                    ROGMainGauge(
                        value: gamerDashboardService.snapshot.performancePercent ?? 100,
                        thermalState: thermalService.thermalState.rawValue
                    )

                    // System Stats Grid (2x3)
                    ROGStatsGrid(
                        snapshot: gamerDashboardService.snapshot,
                        batteryInfo: deviceInfoService.batteryInfo,
                        thermalService: thermalService
                    )

                    // Network Stats Row
                    ROGNetworkStatsRow(snapshot: gamerDashboardService.snapshot)

                    // Quick Actions
                    ROGQuickActions(
                        onStabilityTest: { showSustainedTest = true },
                        onBenchmark: { appState.currentTab = .benchmark },
                        onAdvice: { showAdviceSheet = true }
                    )

                    // Device Info Section
                    ROGDeviceInfoSection(
                        deviceInfo: deviceInfoService.deviceInfo,
                        hardwareInfo: deviceInfoService.hardwareInfo,
                        batteryInfo: deviceInfoService.batteryInfo,
                        extendedInfo: extendedInfo
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
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

// MARK: - ROG Home Header
private struct ROGHomeHeader: View {
    let deviceName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("系统状态")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(HUDTheme.textPrimary)
                Text(deviceName)
                    .font(.system(size: 14))
                    .foregroundColor(HUDTheme.textSecondary)
            }
            Spacer()
            // Status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(HUDTheme.neonGreen)
                    .frame(width: 8, height: 8)
                Text("运行正常")
                    .font(.system(size: 12))
                    .foregroundColor(HUDTheme.neonGreen)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(HUDTheme.neonGreen.opacity(0.15))
            .cornerRadius(20)
        }
    }
}

// MARK: - ROG Main Gauge (Large circular gauge like design mockup)
private struct ROGMainGauge: View {
    let value: Double
    let thermalState: String

    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            HUDTheme.rogRed.opacity(0.8),
                            HUDTheme.rogCyan.opacity(0.3),
                            HUDTheme.rogRed.opacity(0.8)
                        ]),
                        center: .center
                    ),
                    lineWidth: 4
                )
                .frame(width: 200, height: 200)
                .blur(radius: 4)

            // Background circle
            Circle()
                .fill(Color.black.opacity(0.6))
                .frame(width: 180, height: 180)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(min(value, 100) / 100))
                .stroke(
                    LinearGradient(
                        colors: [HUDTheme.rogRed, HUDTheme.rogCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 165, height: 165)
                .rotationEffect(.degrees(-90))

            // Inner content
            VStack(spacing: 4) {
                // Heartbeat icon
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 24))
                    .foregroundColor(HUDTheme.rogRed)

                // Percentage
                Text("\(Int(value))%")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(HUDTheme.textPrimary)

                Text("STABILITY")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(HUDTheme.textSecondary)
                    .tracking(2)

                Text("热状态: \(thermalState)")
                    .font(.system(size: 11))
                    .foregroundColor(HUDTheme.textSecondary)
            }

            // Corner decorations
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(HUDTheme.rogRed)
                    .frame(width: 6, height: 6)
                    .offset(y: -100)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
        }
        .frame(height: 220)
        .padding(.vertical, 8)
    }
}

// MARK: - ROG Stats Grid (2x3 grid like design mockup)
private struct ROGStatsGrid: View {
    let snapshot: GamerDashboardService.Snapshot
    let batteryInfo: BatteryInfo?
    let thermalService: ThermalService

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            // CPU Card
            ROGStatCard(
                icon: "cpu",
                title: "CPU",
                value: String(format: "%.0f%%", snapshot.cpuUsage),
                subtitle: "使用率",
                accentColor: HUDTheme.neonOrange,
                chartData: nil
            )

            // Memory Card
            ROGStatCard(
                icon: "memorychip",
                title: "MEMORY",
                value: String(format: "%.1f GB", (snapshot.memoryUsage / 100) * 8),
                subtitle: String(format: "%.0f%% 已用", snapshot.memoryUsage),
                accentColor: HUDTheme.rogCyan,
                chartData: nil
            )

            // GPU Card
            ROGStatCard(
                icon: "cube",
                title: "GPU",
                value: String(format: "%.0f%%", snapshot.gpuUsage),
                subtitle: "使用率",
                accentColor: HUDTheme.rogRed,
                chartData: nil
            )

            // Temperature Card
            ROGStatCard(
                icon: "thermometer",
                title: "TEMP",
                value: String(format: "%.0f°C", thermalService.currentTemperature),
                subtitle: thermalService.thermalState.rawValue,
                accentColor: thermalService.thermalState.color,
                chartData: nil
            )

            // Battery Card
            ROGStatCard(
                icon: batteryIcon,
                title: "BATTERY",
                value: "\(batteryInfo?.levelPercentage ?? 0)%",
                subtitle: batteryInfo?.stateDescription ?? "未知",
                accentColor: batteryColor,
                chartData: nil
            )

            // Cycle Count Card
            ROGStatCard(
                icon: "arrow.triangle.2.circlepath",
                title: "CYCLES",
                value: "\(batteryInfo?.cycleCount ?? 0)",
                subtitle: "充电循环",
                accentColor: HUDTheme.neonGreen,
                chartData: nil
            )
        }
    }

    private var batteryIcon: String {
        guard let battery = batteryInfo else { return "battery.0percent" }
        switch battery.state {
        case .charging: return "battery.100percent.bolt"
        case .full: return "battery.100percent"
        default:
            if battery.level > 0.75 { return "battery.100percent" }
            if battery.level > 0.5 { return "battery.75percent" }
            if battery.level > 0.25 { return "battery.50percent" }
            return "battery.25percent"
        }
    }

    private var batteryColor: Color {
        guard let battery = batteryInfo else { return HUDTheme.textSecondary }
        switch battery.state {
        case .charging: return HUDTheme.neonGreen
        case .full: return HUDTheme.neonGreen
        default:
            if battery.level > 0.5 { return HUDTheme.neonGreen }
            if battery.level > 0.2 { return HUDTheme.neonOrange }
            return HUDTheme.rogRed
        }
    }
}

// MARK: - ROG Stat Card (Individual stat card like design mockup)
private struct ROGStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let accentColor: Color
    let chartData: [Double]?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(accentColor)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            // Value
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(HUDTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Mini chart placeholder
            MiniChartView(color: accentColor)
                .frame(height: 20)

            // Subtitle
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(HUDTheme.textSecondary)
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.5))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
        )
        .cornerRadius(12)
        .shadow(color: accentColor.opacity(0.2), radius: 8, x: 0, y: 0)
    }
}

// MARK: - Mini Chart View
private struct MiniChartView: View {
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let points = generateRandomPoints(count: 20, height: height)

                path.move(to: CGPoint(x: 0, y: points[0]))
                for i in 1..<points.count {
                    let x = width * CGFloat(i) / CGFloat(points.count - 1)
                    path.addLine(to: CGPoint(x: x, y: points[i]))
                }
            }
            .stroke(color, lineWidth: 1.5)
        }
    }

    private func generateRandomPoints(count: Int, height: CGFloat) -> [CGFloat] {
        var points: [CGFloat] = []
        var current = height / 2
        for _ in 0..<count {
            let delta = CGFloat.random(in: -height/4...height/4)
            current = min(max(current + delta, 2), height - 2)
            points.append(current)
        }
        return points
    }
}

// MARK: - ROG Network Stats Row
private struct ROGNetworkStatsRow: View {
    let snapshot: GamerDashboardService.Snapshot

    var body: some View {
        HStack(spacing: 12) {
            // Latency
            ROGNetworkStatCard(
                icon: "wifi",
                title: "LATENCY",
                value: snapshot.latencyMs.map { "\(Int($0)) ms" } ?? "-- ms",
                subtitle: "网络延迟",
                accentColor: HUDTheme.rogCyan
            )

            // Jitter
            ROGNetworkStatCard(
                icon: "waveform.path",
                title: "JITTER",
                value: snapshot.jitterMs.map { "\(Int($0)) ms" } ?? "-- ms",
                subtitle: "抖动",
                accentColor: HUDTheme.rogCyan
            )

            // Packet Loss
            ROGNetworkStatCard(
                icon: "arrow.down.circle",
                title: "LOSS",
                value: snapshot.lossPercent.map { String(format: "%.1f%%", $0) } ?? "0.0%",
                subtitle: "丢包率",
                accentColor: (snapshot.lossPercent ?? 0) > 1 ? HUDTheme.rogRed : HUDTheme.neonGreen
            )
        }
    }
}

// MARK: - ROG Network Stat Card
private struct ROGNetworkStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(accentColor)
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(HUDTheme.textPrimary)

            MiniChartView(color: accentColor)
                .frame(height: 16)

            Text(subtitle)
                .font(.system(size: 9))
                .foregroundColor(HUDTheme.textSecondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.5))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
        )
        .cornerRadius(12)
    }
}

// MARK: - ROG Quick Actions
private struct ROGQuickActions: View {
    let onStabilityTest: () -> Void
    let onBenchmark: () -> Void
    let onAdvice: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Primary action button
            Button(action: onStabilityTest) {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 18, weight: .semibold))
                    Text("稳定性测试")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(HUDTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [HUDTheme.rogRedDeep, HUDTheme.rogRed],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(HUDTheme.rogRed.opacity(0.8), lineWidth: 2)
                )
                .shadow(color: HUDTheme.rogRed.opacity(0.4), radius: 10, x: 0, y: 0)
            }
            .buttonStyle(.plain)

            // Secondary action buttons
            HStack(spacing: 12) {
                Button(action: onBenchmark) {
                    HStack {
                        Image(systemName: "speedometer")
                            .font(.system(size: 14))
                        Text("跑分测试")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(HUDTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(HUDTheme.borderSoft, lineWidth: 1.5)
                    )
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                Button(action: onAdvice) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                        Text("智能建议")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(HUDTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(HUDTheme.borderSoft, lineWidth: 1.5)
                    )
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - ROG Device Info Section
private struct ROGDeviceInfoSection: View {
    let deviceInfo: DeviceInfo?
    let hardwareInfo: HardwareInfo?
    let batteryInfo: BatteryInfo?
    let extendedInfo: ExtendedDeviceInfo?

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            Button(action: { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }) {
                HStack {
                    ROGSectionLabel(title: "DEVICE INFO")
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(HUDTheme.textSecondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().background(HUDTheme.rogRed.opacity(0.3))

                VStack(spacing: 0) {
                    ROGInfoRow(icon: "iphone", label: "型号", value: extendedInfo?.marketingName ?? deviceInfo?.deviceType ?? "Unknown")
                    ROGInfoRow(icon: "cpu", label: "芯片", value: hardwareInfo?.cpuModel ?? "Unknown")
                    ROGInfoRow(icon: "memorychip", label: "内存", value: String(format: "%.0f GB", hardwareInfo?.totalMemoryGB ?? 0))
                    ROGInfoRow(icon: "internaldrive", label: "存储", value: String(format: "%.0f GB", hardwareInfo?.totalStorageGB ?? 0))
                    ROGInfoRow(icon: "battery.100percent", label: "电池健康", value: batteryInfo?.health.map { "\($0)%" } ?? "未知")
                    ROGInfoRow(icon: "arrow.triangle.2.circlepath", label: "循环次数", value: batteryInfo?.cycleCount.map { "\($0) 次" } ?? "未知")
                    ROGInfoRow(icon: "thermometer", label: "电池温度", value: batteryInfo?.temperature.map { String(format: "%.1f°C", $0) } ?? "未知")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
        }
        .background(Color.black.opacity(0.5))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(HUDTheme.rogRed.opacity(0.5), lineWidth: 1.5)
        )
        .cornerRadius(12)
    }
}

// MARK: - ROG Section Label (Like design mockup)
private struct ROGSectionLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(HUDTheme.rogRed)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(HUDTheme.rogRed, lineWidth: 1.5)
            )
    }
}

// MARK: - ROG Info Row
private struct ROGInfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(HUDTheme.rogCyan)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(HUDTheme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(HUDTheme.textPrimary)
        }
        .padding(.vertical, 8)
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
                    ROGSectionLabel(title: "SMART ADVICE")
                    Spacer()
                    Button("完成") { dismiss() }
                        .foregroundColor(HUDTheme.rogCyan)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)

                // Advice List
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(GamerDashboardService.shared.oneTapOptimizationAdvice().enumerated()), id: \.offset) { _, advice in
                            ROGAdviceRow(advice: advice)
                        }

                        // Current status
                        VStack(alignment: .leading, spacing: 8) {
                            ROGSectionLabel(title: "CURRENT STATUS")
                                .padding(.top, 8)

                            HStack(spacing: 16) {
                                StatusPill(label: "热状态", value: snapshot.thermalState, color: thermalColor)
                                StatusPill(label: "电量", value: "\(snapshot.batteryLevelPercent)%", color: batteryColor)
                            }
                        }
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(HUDTheme.borderSoft, lineWidth: 1)
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
}

// MARK: - ROG Advice Row
private struct ROGAdviceRow: View {
    let advice: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconForAdvice)
                .font(.system(size: 18))
                .foregroundColor(colorForAdvice)
                .frame(width: 24)

            Text(advice)
                .font(.subheadline)
                .foregroundColor(HUDTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.5))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(colorForAdvice.opacity(0.4), lineWidth: 1)
        )
        .cornerRadius(10)
    }

    private var iconForAdvice: String {
        if advice.contains("状态良好") { return "checkmark.circle.fill" }
        if advice.contains("电") { return "battery.25percent" }
        if advice.contains("热") || advice.contains("温") { return "thermometer.high" }
        if advice.contains("网络") || advice.contains("延迟") { return "wifi.exclamationmark" }
        return "info.circle"
    }

    private var colorForAdvice: Color {
        if advice.contains("状态良好") { return HUDTheme.neonGreen }
        if advice.contains("严重") || advice.contains("过热") { return HUDTheme.rogRed }
        return HUDTheme.neonOrange
    }
}

// MARK: - Status Pill
private struct StatusPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(HUDTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Legacy compatibility
struct DeviceHeaderCard: View {
    let deviceInfo: DeviceInfo?
    let batteryInfo: BatteryInfo?
    var body: some View { EmptyView() }
}

struct InfoRow: View {
    let label: String
    let value: String
    var body: some View { ROGInfoRow(icon: "info.circle", label: label, value: value) }
}

struct FeatureFlag: View {
    let label: String
    let isEnabled: Bool
    var body: some View { EmptyView() }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
