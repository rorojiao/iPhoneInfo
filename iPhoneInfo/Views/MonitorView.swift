//
//  MonitorView.swift
//  iPhoneInfo
//
//  Real-time system monitoring view - ROG HUD Style
//

import SwiftUI

struct MonitorView: View {
    @StateObject private var monitor = SystemMonitor.shared
    @StateObject private var benchmarkCoordinator = BenchmarkCoordinator.shared
    @StateObject private var gameExperienceService = GameExperienceService.shared
    @State private var selectedTab: MonitorTab = .all

    enum MonitorTab: String, CaseIterable {
        case all = "全部"
        case game = "游戏"
        case cpu = "CPU"
        case memory = "内存"
        case battery = "电池"
        case network = "网络"
    }

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 14) {
                ROGMonitorHeader()

                ROGTabPicker(selection: $selectedTab)

                ScrollView {
                    VStack(spacing: 16) {
                        if let metrics = monitor.currentMetrics {
                            switch selectedTab {
                            case .all:
                                ROGAllMonitorsView(metrics: metrics, gameAssessment: gameExperienceService.assessment)
                            case .game:
                                ROGGameMonitorCard(assessment: gameExperienceService.assessment)
                            case .cpu:
                                ROGCPUMonitorCard(cpuUsage: metrics.cpuUsage)
                            case .memory:
                                ROGMemoryMonitorCard(memoryUsage: metrics.memoryUsage)
                            case .battery:
                                ROGBatteryMonitorCard(batteryLevel: Double(metrics.batteryLevel) * 100, thermalState: metrics.processThermalState)
                            case .network:
                                ROGNetworkMonitorCard(wifiIP: metrics.wifiIP, cellularIP: metrics.cellularIP)
                            }
                        } else {
                            ROGCard(title: nil, accent: HUDTheme.rogCyan) {
                                HStack {
                                    ProgressView()
                                        .tint(HUDTheme.rogCyan)
                                    Text("正在加载监控数据...")
                                        .foregroundColor(HUDTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            }
                        }

                        // Update interval info
                        Text("刷新间隔: 1 秒")
                            .font(.caption)
                            .foregroundColor(HUDTheme.textSecondary)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 10)
        }
        .onAppear {
            monitor.startMonitoring()
            gameExperienceService.update(metrics: monitor.currentMetrics, lastBenchmark: benchmarkCoordinator.currentResult)
        }
        .onDisappear {
            monitor.stopMonitoring()
        }
        .onReceive(monitor.$currentMetrics) { metrics in
            gameExperienceService.update(metrics: metrics, lastBenchmark: benchmarkCoordinator.currentResult)
        }
        .onReceive(benchmarkCoordinator.$currentResult) { result in
            gameExperienceService.update(metrics: monitor.currentMetrics, lastBenchmark: result)
        }
    }
}

// MARK: - ROG Monitor Header
private struct ROGMonitorHeader: View {
    var body: some View {
        HStack {
            Text("实时监控")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(HUDTheme.textPrimary)

            Spacer()

            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(HUDTheme.rogCyan)
                .padding(10)
                .background(Color.black.opacity(0.45))
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - ROG Tab Picker
private struct ROGTabPicker: View {
    @Binding var selection: MonitorView.MonitorTab

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MonitorView.MonitorTab.allCases, id: \.self) { tab in
                    Button(action: { selection = tab }) {
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selection == tab ? HUDTheme.textPrimary : HUDTheme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selection == tab ? HUDTheme.rogRed : Color.black.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selection == tab ? HUDTheme.borderStrong : HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
                            )
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - ROG All Monitors View
private struct ROGAllMonitorsView: View {
    let metrics: SystemMetrics
    let gameAssessment: GameExperienceAssessment

    var body: some View {
        VStack(spacing: 16) {
            ROGGameMonitorCard(assessment: gameAssessment)
            ROGCPUMonitorCard(cpuUsage: metrics.cpuUsage)
            ROGMemoryMonitorCard(memoryUsage: metrics.memoryUsage)
            ROGBatteryMonitorCard(batteryLevel: Double(metrics.batteryLevel) * 100, thermalState: metrics.processThermalState)
            ROGNetworkMonitorCard(wifiIP: metrics.wifiIP, cellularIP: metrics.cellularIP)
        }
    }
}

// MARK: - ROG Game Monitor Card
private struct ROGGameMonitorCard: View {
    let assessment: GameExperienceAssessment

    var body: some View {
        ROGCard(title: "游戏卡顿评估", accent: riskColor) {
            VStack(alignment: .leading, spacing: 10) {
                ROGMonitorRow(label: "风险", value: assessment.risk.rawValue, valueColor: riskColor)
                ROGMonitorRow(label: "热状态", value: assessment.thermalState)
                ROGMonitorRow(label: "低电量模式", value: assessment.lowPowerModeEnabled ? "开启" : "关闭")

                if let drop = assessment.cpuDropPercent {
                    ROGMonitorRow(label: "CPU 降速估计", value: "\(String(format: "%.1f", drop))%")
                }

                if !assessment.reasons.isEmpty {
                    Text(assessment.reasons.joined(separator: " · "))
                        .font(.caption)
                        .foregroundColor(HUDTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !assessment.advice.isEmpty {
                    Text(assessment.advice)
                        .font(.caption)
                        .foregroundColor(HUDTheme.rogCyan)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider().background(Color.white.opacity(0.1))

                Text("说明：iOS 无法直接监控其他游戏的帧率/频率，本评估基于当前设备热状态与负载推断")
                    .font(.caption2)
                    .foregroundColor(HUDTheme.textSecondary.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var riskColor: Color {
        switch assessment.risk {
        case .low: return HUDTheme.neonGreen
        case .medium: return HUDTheme.neonOrange
        case .high: return HUDTheme.rogRed
        }
    }
}

// MARK: - ROG CPU Monitor Card
private struct ROGCPUMonitorCard: View {
    let cpuUsage: Double

    var body: some View {
        ROGCard(title: "CPU 使用率", accent: HUDTheme.rogCyan) {
            HStack {
                Spacer()
                ROGCircularGauge(value: cpuUsage, maxValue: 100, color: HUDTheme.rogCyan, label: "CPU")
                Spacer()
            }
        }
    }
}

// MARK: - ROG Memory Monitor Card
private struct ROGMemoryMonitorCard: View {
    let memoryUsage: Double

    var body: some View {
        ROGCard(title: "内存使用率", accent: Color.purple) {
            HStack {
                Spacer()
                ROGCircularGauge(value: memoryUsage, maxValue: 100, color: Color.purple, label: "内存")
                Spacer()
            }
        }
    }
}

// MARK: - ROG Battery Monitor Card
private struct ROGBatteryMonitorCard: View {
    let batteryLevel: Double
    let thermalState: ProcessInfo.ThermalState

    var body: some View {
        ROGCard(title: "电池状态", accent: HUDTheme.neonOrange) {
            HStack(spacing: 40) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "battery.100percent")
                        .font(.system(size: 32))
                        .foregroundColor(batteryColor)
                    Text("\(Int(batteryLevel))%")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(HUDTheme.textPrimary)
                    Text("电量")
                        .font(.caption)
                        .foregroundColor(HUDTheme.textSecondary)
                }

                VStack(spacing: 8) {
                    Image(systemName: "flame")
                        .font(.system(size: 32))
                        .foregroundColor(thermalColor)
                    Text(thermalStateName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(HUDTheme.textPrimary)
                    Text("热状态")
                        .font(.caption)
                        .foregroundColor(HUDTheme.textSecondary)
                }

                Spacer()
            }
            .padding(.vertical, 10)
        }
    }

    private var batteryColor: Color {
        if batteryLevel > 50 { return HUDTheme.neonGreen }
        if batteryLevel > 20 { return HUDTheme.neonOrange }
        return HUDTheme.rogRed
    }

    private var thermalColor: Color {
        switch thermalState {
        case .nominal: return HUDTheme.neonGreen
        case .fair: return .yellow
        case .serious: return HUDTheme.neonOrange
        case .critical: return HUDTheme.rogRed
        @unknown default: return HUDTheme.textSecondary
        }
    }

    private var thermalStateName: String {
        switch thermalState {
        case .nominal: return "正常"
        case .fair: return "温热"
        case .serious: return "发热"
        case .critical: return "过热"
        @unknown default: return "未知"
        }
    }
}

// MARK: - ROG Network Monitor Card
private struct ROGNetworkMonitorCard: View {
    let wifiIP: String?
    let cellularIP: String?

    var body: some View {
        ROGCard(title: "网络", accent: HUDTheme.rogCyan) {
            VStack(alignment: .leading, spacing: 12) {
                ROGMonitorRow(label: "WiFi IP", value: wifiIP ?? "未连接")
                ROGMonitorRow(label: "蜂窝 IP", value: cellularIP ?? "未连接")

                Divider().background(Color.white.opacity(0.1))

                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(HUDTheme.neonOrange)
                        .font(.caption)
                    Text("网络流量监控在 iOS 上不可用")
                        .font(.caption)
                        .foregroundColor(HUDTheme.neonOrange)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("• iOS App Store 隐私限制不允许应用读取系统网络流量统计")
                        .font(.caption2)
                        .foregroundColor(HUDTheme.textSecondary.opacity(0.7))
                    Text("• 私有 API 存在取整/溢出问题，数据不可靠")
                        .font(.caption2)
                        .foregroundColor(HUDTheme.textSecondary.opacity(0.7))
                }
            }
        }
    }
}

// MARK: - ROG Circular Gauge
private struct ROGCircularGauge: View {
    let value: Double
    let maxValue: Double
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: min(value / maxValue, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 0)
                    .animation(.spring(response: 0.5), value: value)

                VStack(spacing: 2) {
                    Text("\(Int(value))%")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(HUDTheme.textPrimary)
                    Text(label)
                        .font(.caption)
                        .foregroundColor(HUDTheme.textSecondary)
                }
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - ROG Monitor Row
private struct ROGMonitorRow: View {
    let label: String
    let value: String
    var valueColor: Color = HUDTheme.textPrimary

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(HUDTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Helper
private func thermalToCelsius(_ state: ThermalState) -> Double {
    switch state {
    case .normal:
        return 35.0
    case .light:
        return 38.0
    case .moderate:
        return 42.0
    case .heavy:
        return 48.0
    case .critical:
        return 55.0
    }
}

// MARK: - Legacy Components (kept for compatibility)
struct GameMonitorCard: View {
    let assessment: GameExperienceAssessment

    var body: some View {
        ROGGameMonitorCard(assessment: assessment)
    }
}

struct AllMonitorsView: View {
    let metrics: SystemMetrics
    let gameAssessment: GameExperienceAssessment

    var body: some View {
        ROGAllMonitorsView(metrics: metrics, gameAssessment: gameAssessment)
    }
}

struct CPUMonitorCard: View {
    let cpuUsage: Double

    var body: some View {
        ROGCPUMonitorCard(cpuUsage: cpuUsage)
    }
}

struct MemoryMonitorCard: View {
    let memoryUsage: Double

    var body: some View {
        ROGMemoryMonitorCard(memoryUsage: memoryUsage)
    }
}

struct BatteryMonitorCard: View {
    let batteryLevel: Double
    let thermalState: ProcessInfo.ThermalState

    var body: some View {
        ROGBatteryMonitorCard(batteryLevel: batteryLevel, thermalState: thermalState)
    }
}

struct MonitorCard<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: Content

    init(icon: String, title: String, color: Color, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.color = color
        self.content = content()
    }

    var body: some View {
        ROGCard(title: title, accent: color) {
            content
        }
    }
}

struct MiniChart: View {
    let data: [Double]

    var body: some View {
        GeometryReader { geometry in
            let max = data.max() ?? 1
            let min = data.min() ?? 0
            let range = max - min

            ZStack {
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let step = width / CGFloat(data.count - 1)

                    var x: CGFloat = 0
                    path.move(to: CGPoint(x: 0, y: height))

                    for value in data {
                        let normalizedValue = range > 0 ? (value - min) / range : 0.5
                        let y = height - (CGFloat(normalizedValue) * height)
                        path.addLine(to: CGPoint(x: x, y: y))
                        x += step
                    }
                }
                .stroke(HUDTheme.rogCyan, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
            }
        }
    }
}

struct NetworkMonitorCard: View {
    let wifiIP: String?
    let cellularIP: String?

    var body: some View {
        ROGNetworkMonitorCard(wifiIP: wifiIP, cellularIP: cellularIP)
    }
}

#Preview {
    MonitorView()
}
