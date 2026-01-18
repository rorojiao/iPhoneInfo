//
//  SustainedGamingTestView.swift
//  iPhoneInfo
//
//  Sustained gaming stability test - ROG HUD Style
//

import SwiftUI

struct SustainedGamingTestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    @StateObject private var benchmarkCoordinator = BenchmarkCoordinator.shared
    @StateObject private var dashboard = GamerDashboardService.shared

    @State private var showCancelConfirm = false

    var body: some View {
        ZStack {
            HUDBg()

            // Accent gradient overlay - 确保不阻止触摸
            LinearGradient(
                colors: [HUDTheme.rogRed.opacity(0.15), Color.clear],
                startPoint: .topTrailing,
                endPoint: .center
            )
            .blendMode(.screen)
            .ignoresSafeArea()
            .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    ROGTestHeader(
                        phase: benchmarkCoordinator.sustainedPhase,
                        onCancel: { showCancelConfirm = true }
                    )

                    // Main gauge section
                    ROGStabilityGauge(
                        value: stabilityPercent,
                        subtitle: stabilitySubtitle,
                        isRunning: benchmarkCoordinator.isSustainedRunning
                    )

                    // Quick stats row
                    ROGQuickStatsRow(
                        performance: dashboard.snapshot.performancePercent,
                        stability: dashboard.snapshot.realtimeStabilityPercent,
                        temperature: dashboard.snapshot.temperatureCelsius
                    )

                    // Live status panel
                    ROGLiveStatusPanel(snapshot: dashboard.snapshot)

                    // Result summary (if completed)
                    if let result = benchmarkCoordinator.sustainedResult, !benchmarkCoordinator.isSustainedRunning {
                        ROGResultSummary(result: result)
                    }

                    Spacer(minLength: 20)

                    // Footer with progress and action button
                    ROGTestFooter(
                        progress: benchmarkCoordinator.sustainedProgress,
                        isRunning: benchmarkCoordinator.isSustainedRunning,
                        onAction: {
                            if benchmarkCoordinator.isSustainedRunning {
                                showCancelConfirm = true
                            } else {
                                appState.currentTab = .home
                                dismiss()
                            }
                        }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .overlay(HUDScanlineOverlay(opacity: 0.05).ignoresSafeArea().allowsHitTesting(false))
        .interactiveDismissDisabled(benchmarkCoordinator.isSustainedRunning)
        .onAppear {
            dashboard.startGamerMonitoring()
            if !benchmarkCoordinator.isSustainedRunning && benchmarkCoordinator.sustainedResult == nil {
                benchmarkCoordinator.startSustainedGamingBenchmark { _, _ in }
            }
        }
        .onDisappear {
            dashboard.stopGamerMonitoring()
        }
        .alert("确定要中断稳定性测试吗？", isPresented: $showCancelConfirm) {
            Button("继续测试", role: .cancel) {}
            Button("中断", role: .destructive) {
                benchmarkCoordinator.cancelBenchmark()
                appState.currentTab = .home
                dismiss()
            }
        } message: {
            Text("中断后将丢失本次测试结果。")
        }
    }

    private var stabilityPercent: Double {
        if let value = benchmarkCoordinator.sustainedResult?.stabilityPercent {
            return value
        }
        return benchmarkCoordinator.sustainedProgress * 100.0
    }

    private var stabilitySubtitle: String {
        if let result = benchmarkCoordinator.sustainedResult {
            return "\(result.cycles) 轮 · \(result.thermalStateStart) → \(result.thermalStateEnd)"
        }
        return "\(Int(benchmarkCoordinator.sustainedProgress * 100))%"
    }
}

// MARK: - ROG Test Header
private struct ROGTestHeader: View {
    let phase: String
    let onCancel: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("稳定性测试")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(HUDTheme.textPrimary)

                Text(phase.isEmpty ? "热稳定/降频/衰减评估" : phase)
                    .font(.subheadline)
                    .foregroundColor(HUDTheme.textSecondary)

                Text("可随时中断，但会丢失本次结果")
                    .font(.caption)
                    .foregroundColor(HUDTheme.textSecondary.opacity(0.7))
            }

            Spacer()

            Button(action: onCancel) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                    Text("取消")
                }
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(HUDTheme.rogRed.opacity(0.6), lineWidth: HUDTheme.borderWidth)
                )
                .foregroundColor(HUDTheme.rogRed)
                .cornerRadius(10)
                .shadow(color: HUDTheme.rogRed.opacity(0.3), radius: 8, x: 0, y: 0)
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: HUDTheme.cornerRadius)
                .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
        )
        .cornerRadius(HUDTheme.cornerRadius)
    }
}

// MARK: - ROG Stability Gauge (Matching design mockup)
private struct ROGStabilityGauge: View {
    let value: Double
    let subtitle: String
    let isRunning: Bool

    var body: some View {
        VStack(spacing: 12) {
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
                    .frame(width: 220, height: 220)
                    .blur(radius: 4)

                // Background circle
                Circle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 200, height: 200)

                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 185, height: 185)

                // Progress ring
                Circle()
                    .trim(from: 0, to: min(value / 100.0, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [HUDTheme.rogRed, HUDTheme.rogCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 185, height: 185)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: HUDTheme.rogRed.opacity(0.5), radius: 12, x: 0, y: 0)
                    .animation(.spring(response: 0.5), value: value)

                // Center content
                VStack(spacing: 2) {
                    // Heartbeat icon
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 20))
                        .foregroundColor(HUDTheme.rogRed)

                    Text("\(Int(value))%")
                        .font(.system(size: 52, weight: .bold, design: .monospaced))
                        .foregroundColor(HUDTheme.textPrimary)

                    Text("STABILITY")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HUDTheme.textSecondary)
                        .tracking(2)

                    if isRunning {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(HUDTheme.rogRed)
                                .frame(width: 6, height: 6)
                            Text("测试中")
                                .font(.system(size: 11))
                                .foregroundColor(HUDTheme.rogRed)
                        }
                        .padding(.top, 2)
                    }
                }

                // Corner decorations
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(HUDTheme.rogRed)
                        .frame(width: 6, height: 6)
                        .offset(y: -110)
                        .rotationEffect(.degrees(Double(i) * 90))
                }
            }

            // Max/Min display
            HStack(spacing: 20) {
                Text("Max: \(Int(min(value + 6, 100)))%")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(HUDTheme.textSecondary)
                Text("•")
                    .foregroundColor(HUDTheme.rogRed)
                Text("Min: \(Int(max(value - 10, 0)))%")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(HUDTheme.textSecondary)
            }
        }
        .padding(.vertical, 16)
    }
}

// MARK: - ROG Quick Stats Row
private struct ROGQuickStatsRow: View {
    let performance: Double?
    let stability: Double?
    let temperature: Double?

    var body: some View {
        HStack(spacing: 12) {
            ROGQuickStat(
                title: "性能发挥",
                value: performance.map { "\(Int($0))%" } ?? "--",
                color: HUDTheme.neonGreen
            )
            ROGQuickStat(
                title: "实时稳定",
                value: stability.map { "\(Int($0))%" } ?? "--",
                color: HUDTheme.rogRed
            )
            ROGQuickStat(
                title: "温度",
                value: temperature.map { "\(Int($0))°C" } ?? "--",
                color: HUDTheme.neonOrange
            )
        }
    }
}

// MARK: - ROG Quick Stat
private struct ROGQuickStat: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(HUDTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.5), lineWidth: HUDTheme.borderWidth)
        )
        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 0)
        .cornerRadius(10)
    }
}

// MARK: - ROG Live Status Panel
private struct ROGLiveStatusPanel: View {
    let snapshot: GamerDashboardService.Snapshot

    var body: some View {
        ROGCard(title: "实时状态", accent: HUDTheme.rogRed) {
            VStack(spacing: 8) {
                ROGStatusRow(label: "热状态", value: snapshot.thermalState, color: thermalColor)
                Divider().background(Color.white.opacity(0.1))
                ROGStatusRow(label: "CPU", value: "\(Int(snapshot.cpuUsage))%")
                Divider().background(Color.white.opacity(0.1))
                ROGStatusRow(label: "内存", value: "\(Int(snapshot.memoryUsage))%")
                Divider().background(Color.white.opacity(0.1))
                ROGStatusRow(label: "GPU(估算)", value: "\(Int(snapshot.gpuUsage))%")
                Divider().background(Color.white.opacity(0.1))
                ROGStatusRow(label: "网络延迟", value: formatMs(snapshot.latencyMs))
                Divider().background(Color.white.opacity(0.1))
                ROGStatusRow(label: "抖动", value: formatMs(snapshot.jitterMs))
                Divider().background(Color.white.opacity(0.1))
                ROGStatusRow(label: "丢包", value: formatPercent(snapshot.lossPercent))
            }
        }
    }

    private var thermalColor: Color {
        switch snapshot.thermalState {
        case "正常": return HUDTheme.neonGreen
        case "轻度": return HUDTheme.neonOrange
        default: return HUDTheme.rogRed
        }
    }

    private func formatMs(_ value: Double?) -> String {
        guard let value else { return "--" }
        return "\(Int(value)) ms"
    }

    private func formatPercent(_ value: Double?) -> String {
        guard let value else { return "--" }
        return "\(String(format: "%.1f", value))%"
    }
}

// MARK: - ROG Status Row
private struct ROGStatusRow: View {
    let label: String
    let value: String
    var color: Color = HUDTheme.textPrimary

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(HUDTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(color)
        }
    }
}

// MARK: - ROG Result Summary
private struct ROGResultSummary: View {
    let result: BenchmarkCoordinator.SustainedGamingResult

    var body: some View {
        ROGCard(title: "测试结果", accent: HUDTheme.neonGreen) {
            VStack(spacing: 8) {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(result.firstScore)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(HUDTheme.rogCyan)
                        Text("首轮分数")
                            .font(.caption)
                            .foregroundColor(HUDTheme.textSecondary)
                    }

                    Image(systemName: "arrow.right")
                        .foregroundColor(HUDTheme.textSecondary)

                    VStack(spacing: 4) {
                        Text("\(result.lastScore)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(stabilityColor)
                        Text("末轮分数")
                            .font(.caption)
                            .foregroundColor(HUDTheme.textSecondary)
                    }
                }
                .padding(.vertical, 8)

                Divider().background(Color.white.opacity(0.1))

                ROGStatusRow(label: "稳定性", value: "\(String(format: "%.1f", result.stabilityPercent))%", color: stabilityColor)
                Divider().background(Color.white.opacity(0.1))
                ROGStatusRow(label: "CPU 降速(估算)", value: "\(String(format: "%.1f", result.cpuSpeedDropPercent))%")
                Divider().background(Color.white.opacity(0.1))
                ROGStatusRow(label: "热状态变化", value: "\(result.thermalStateStart) → \(result.thermalStateEnd)")
                Divider().background(Color.white.opacity(0.1))
                ROGStatusRow(label: "测试轮次", value: "\(result.cycles) 轮")
            }
        }
    }

    private var stabilityColor: Color {
        if result.stabilityPercent >= 90 { return HUDTheme.neonGreen }
        if result.stabilityPercent >= 70 { return HUDTheme.neonOrange }
        return HUDTheme.rogRed
    }
}

// MARK: - ROG Test Footer
private struct ROGTestFooter: View {
    let progress: Double
    let isRunning: Bool
    let onAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [HUDTheme.rogRed, HUDTheme.neonOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                        .shadow(color: HUDTheme.rogRed.opacity(0.5), radius: 4, x: 0, y: 0)
                        .animation(.spring(response: 0.3), value: progress)
                }
            }
            .frame(height: 6)

            // Action button
            Button(action: onAction) {
                HStack(spacing: 10) {
                    Image(systemName: isRunning ? "stop.fill" : "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text(isRunning ? "中断测试" : "完成")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(HUDTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: HUDTheme.primaryButtonHeight)
                .background(
                    LinearGradient(
                        colors: isRunning
                            ? [HUDTheme.rogRedDeep, HUDTheme.rogRed]
                            : [HUDTheme.neonGreen.opacity(0.8), HUDTheme.rogCyan.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                        .stroke(isRunning ? HUDTheme.borderStrong : HUDTheme.neonGreen.opacity(0.6), lineWidth: HUDTheme.borderWidth)
                )
                .shadow(color: (isRunning ? HUDTheme.rogRed : HUDTheme.neonGreen).opacity(0.4), radius: 12, x: 0, y: 0)
                .cornerRadius(HUDTheme.smallCornerRadius)
            }
            .buttonStyle(.plain)
        }
    }
}
