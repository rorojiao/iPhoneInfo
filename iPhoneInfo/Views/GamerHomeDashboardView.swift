import SwiftUI


struct GamerHomeDashboardView: View {
    @EnvironmentObject var appState: AppState

    @StateObject private var dashboard = GamerDashboardService.shared
    @StateObject private var benchmarkCoordinator = BenchmarkCoordinator.shared

    @State private var showSustainedTest = false

    var body: some View {
        VStack(spacing: 14) {
            ROGTopBar()

            topStatusRow

            logoPanel

            primarySection

            quickTiles

            noticePanel
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .overlay(HUDScanlineOverlay(opacity: 0.05))
        .onAppear {
            dashboard.startGamerMonitoring()
        }
        .onDisappear {
            dashboard.stopGamerMonitoring()
        }
        .fullScreenCover(isPresented: $showSustainedTest) {
            SustainedGamingTestView()
                .environmentObject(appState)
        }
    }

    private var topStatusRow: some View {
        HStack(spacing: 12) {
            ROGMetricCard(
                title: "性能/热状态",
                primary: performanceText,
                secondary: "热状态：\(dashboard.snapshot.thermalState)",
                accent: HUDTheme.rogCyan
            )

            ROGMetricCard(
                title: "风险",
                primary: dashboard.snapshot.risk.rawValue,
                secondary: riskDetailText,
                accent: HUDTheme.rogRed
            )
        }
    }

    private var logoPanel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: HUDTheme.cornerRadius)
                .fill(Color.black.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: HUDTheme.cornerRadius)
                        .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
                )
                .shadow(color: HUDTheme.glowSoft, radius: 18, x: 0, y: 0)

            HUDCircuitOverlay(tint: HUDTheme.rogCyan, accent: HUDTheme.rogRed)
                .opacity(0.7)
                .blendMode(.screen)

            ROGEmblem()
                .frame(height: 150)
                .padding(.vertical, 26)
        }
        .overlay(HUDScanlineOverlay(opacity: 0.05))
    }

    private var primarySection: some View {
        VStack(spacing: 12) {
            ROGPrimaryButton(title: "一键操作") {
                // Placeholder: in mockup it is a section header style button
            }

            HStack(spacing: 12) {
                ROGSecondaryButton(title: "稳定性测试") {
                    showSustainedTest = true
                }

                ROGSecondaryButton(title: "跑分") {
                    appState.currentTab = .benchmark
                }

                ROGSecondaryButton(title: "设置") {
                    openAppSettings()
                }
            }
        }
    }

    private var quickTiles: some View {
        HStack(spacing: 12) {
            ROGIconTile(title: "性能\n发挥", systemImage: "speedometer", value: performanceText)
            ROGIconTile(title: "温度", systemImage: "thermometer", value: temperatureText)
            ROGIconTile(title: "电量", systemImage: "battery.100percent", value: "\(dashboard.snapshot.batteryLevelPercent)%")
            ROGIconTile(title: "延迟", systemImage: "antenna.radiowaves.left.and.right", value: latencyText)
        }
    }

    private var noticePanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("注意事项：")
                .font(.subheadline)
                .foregroundColor(HUDTheme.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                Text("1. iOS 不提供其他游戏的 FPS/频率直读，本页评估基于公开 API 与本机采样。")
                Text("2. 网络延迟为到目标站点的 TCP 建连耗时，和具体游戏服务器延迟可能不同。")
                Text("3. 可玩时间为电量下降速率估算，仅作参考。")
            }
            .font(.caption)
            .foregroundColor(HUDTheme.textSecondary)
        }
        .padding(14)
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
        )
        .shadow(color: HUDTheme.glowSoft, radius: 16, x: 0, y: 0)
        .overlay(HUDScanlineOverlay(opacity: 0.04))
    }

    private var performanceText: String {
        guard let value = dashboard.snapshot.performancePercent else { return "--" }
        return "\(Int(value))%"
    }

    private var temperatureText: String {
        guard let value = dashboard.snapshot.temperatureCelsius else { return "--" }
        return "\(Int(value))°C"
    }

    private var latencyText: String {
        guard let value = dashboard.snapshot.latencyMs else { return "--" }
        return "\(Int(value))ms"
    }

    private var riskDetailText: String {
        if dashboard.snapshot.reasons.isEmpty { return "-" }
        return dashboard.snapshot.reasons.prefix(1).joined()
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

private struct ROGTopBar: View {
    var body: some View {
        HStack {
            Text("首页玩家模式")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(HUDTheme.textPrimary)

            Spacer()

            Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(HUDTheme.textPrimary.opacity(0.9))
                .padding(10)
                .background(Color.black.opacity(0.45))
                .cornerRadius(12)
        }
    }
}

private struct ROGMetricCard: View {
    let title: String
    let primary: String
    let secondary: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(HUDTheme.textSecondary)

            Text(primary)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(HUDTheme.textPrimary)

            Text(secondary)
                .font(.caption)
                .foregroundColor(HUDTheme.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                .stroke(accent.opacity(0.8), lineWidth: HUDTheme.borderWidth)
        )
        .shadow(color: accent.opacity(0.22), radius: 14, x: 0, y: 0)
        .overlay(HUDScanlineOverlay(opacity: 0.04))
        .cornerRadius(HUDTheme.smallCornerRadius)
    }
}

private struct ROGEmblem: View {
    var body: some View {
        ZStack {
            Image(systemName: "eye")
                .font(.system(size: 90, weight: .black))
                .foregroundColor(HUDTheme.rogRed)
                .shadow(color: HUDTheme.glowStrong, radius: 26, x: 0, y: 0)
                .shadow(color: HUDTheme.cyanGlow, radius: 14, x: 0, y: 0)

            RoundedRectangle(cornerRadius: 18)
                .stroke(HUDTheme.rogRed.opacity(0.25), lineWidth: 1)
                .frame(width: 220, height: 140)
                .blendMode(.screen)
        }
    }
}

private struct ROGPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(HUDTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: HUDTheme.primaryButtonHeight)
                .background(
                    LinearGradient(
                        colors: [HUDTheme.rogRedDeep, HUDTheme.rogRed],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                        .stroke(HUDTheme.borderStrong, lineWidth: HUDTheme.borderWidth)
                )
                .shadow(color: HUDTheme.glowStrong, radius: 18, x: 0, y: 0)
                .cornerRadius(HUDTheme.smallCornerRadius)
        }
        .buttonStyle(.plain)
    }
}

private struct ROGSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(HUDTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: HUDTheme.secondaryButtonHeight)
                .background(Color.black.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                        .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
                )
                .shadow(color: HUDTheme.glowSoft, radius: 12, x: 0, y: 0)
                .cornerRadius(HUDTheme.smallCornerRadius)
        }
        .buttonStyle(.plain)
    }
}

private struct ROGIconTile: View {
    let title: String
    let systemImage: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(HUDTheme.rogCyan)

            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(HUDTheme.textPrimary)

            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(HUDTheme.textSecondary)
        }
        .frame(width: HUDTheme.iconTileSize, height: HUDTheme.iconTileSize)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
        )
        .shadow(color: HUDTheme.glowSoft, radius: 12, x: 0, y: 0)
        .overlay(HUDScanlineOverlay(opacity: 0.03))
        .cornerRadius(8)
    }
}
