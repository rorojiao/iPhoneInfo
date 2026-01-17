//
//  SettingsView.swift
//  iPhoneInfo
//
//  Settings view - ROG HUD Style
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("testDuration") private var testDuration = 2.0
    @AppStorage("testResolution") private var testResolution = 0
    @AppStorage("enableCloudSync") private var enableCloudSync = false
    @AppStorage("anonymousUpload") private var anonymousUpload = true
    @AppStorage("useDarkMode") private var useDarkMode = 0

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 14) {
                ROGSettingsHeader()

                ScrollView {
                    VStack(spacing: 16) {
                        // Test Configuration
                        ROGSettingsSection(title: "测试配置", icon: "slider.horizontal.3") {
                            VStack(spacing: 12) {
                                ROGSettingsPicker(
                                    label: "测试时长",
                                    selection: $testDuration,
                                    options: [(1.0, "1 分钟"), (2.0, "2 分钟"), (5.0, "5 分钟")]
                                )

                                Divider().background(Color.white.opacity(0.1))

                                ROGSettingsPicker(
                                    label: "测试分辨率",
                                    selection: $testResolution,
                                    options: [(0, "自动"), (1, "1080p"), (2, "原生")]
                                )
                            }
                        }

                        // Data & Privacy
                        ROGSettingsSection(title: "数据与隐私", icon: "lock.shield") {
                            VStack(spacing: 12) {
                                ROGSettingsToggle(label: "云端同步", isOn: $enableCloudSync)

                                Divider().background(Color.white.opacity(0.1))

                                ROGSettingsToggle(label: "匿名上传", isOn: $anonymousUpload)

                                Divider().background(Color.white.opacity(0.1))

                                ROGSettingsLink(label: "导出数据", icon: "square.and.arrow.up") {
                                    DataExportView()
                                }

                                Divider().background(Color.white.opacity(0.1))

                                ROGSettingsLink(label: "清除历史", icon: "trash") {
                                    ClearHistoryView()
                                }
                            }
                        }

                        // Appearance
                        ROGSettingsSection(title: "显示", icon: "paintbrush") {
                            ROGSettingsPicker(
                                label: "外观模式",
                                selection: $useDarkMode,
                                options: [(0, "跟随系统"), (1, "浅色模式"), (2, "深色模式")]
                            )
                        }

                        // About
                        ROGSettingsSection(title: "关于", icon: "info.circle") {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("版本")
                                        .foregroundColor(HUDTheme.textSecondary)
                                    Spacer()
                                    Text("1.0.0")
                                        .font(.system(.subheadline, design: .monospaced))
                                        .foregroundColor(HUDTheme.textPrimary)
                                }

                                Divider().background(Color.white.opacity(0.1))

                                ROGSettingsLink(label: "用户协议", icon: "doc.text") {
                                    UserAgreementView()
                                }

                                Divider().background(Color.white.opacity(0.1))

                                ROGSettingsLink(label: "隐私政策", icon: "hand.raised") {
                                    PrivacyPolicyView()
                                }

                                Divider().background(Color.white.opacity(0.1))

                                ROGSettingsLink(label: "开源协议", icon: "chevron.left.forwardslash.chevron.right") {
                                    OpenSourceLicenseView()
                                }
                            }
                        }

                        // Advanced
                        ROGSettingsSection(title: "高级", icon: "gearshape.2") {
                            VStack(spacing: 12) {
                                ROGSettingsLink(label: "传感器", icon: "gyroscope") {
                                    SensorToolsView()
                                }

                                Divider().background(Color.white.opacity(0.1))

                                ROGSettingsLink(label: "设备调试信息", icon: "hammer") {
                                    DeviceDebugView()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .padding(.top, 10)
        }
    }
}

// MARK: - ROG Settings Header
private struct ROGSettingsHeader: View {
    var body: some View {
        HStack {
            Text("设置")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(HUDTheme.textPrimary)

            Spacer()

            Image(systemName: "gear")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(HUDTheme.rogCyan)
                .padding(10)
                .background(Color.black.opacity(0.45))
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - ROG Settings Section
private struct ROGSettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(HUDTheme.rogCyan)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(HUDTheme.textPrimary)
            }

            content
        }
        .padding(14)
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: HUDTheme.cornerRadius)
                .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
        )
        .shadow(color: HUDTheme.glowSoft, radius: 14, x: 0, y: 0)
        .overlay(HUDScanlineOverlay(opacity: 0.04))
        .cornerRadius(HUDTheme.cornerRadius)
    }
}

// MARK: - ROG Settings Toggle
private struct ROGSettingsToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .foregroundColor(HUDTheme.textSecondary)
        }
        .tint(HUDTheme.rogRed)
    }
}

// MARK: - ROG Settings Picker
private struct ROGSettingsPicker<T: Hashable>: View {
    let label: String
    @Binding var selection: T
    let options: [(T, String)]

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(HUDTheme.textSecondary)

            Spacer()

            Menu {
                ForEach(options, id: \.0) { value, text in
                    Button(text) {
                        selection = value
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selectedText)
                        .font(.subheadline)
                        .foregroundColor(HUDTheme.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(HUDTheme.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(HUDTheme.borderSoft, lineWidth: 1)
                )
                .cornerRadius(8)
            }
        }
    }

    private var selectedText: String {
        options.first(where: { $0.0 == selection })?.1 ?? ""
    }
}

// MARK: - ROG Settings Link
private struct ROGSettingsLink<Destination: View>: View {
    let label: String
    let icon: String
    let destination: Destination

    init(label: String, icon: String, @ViewBuilder destination: () -> Destination) {
        self.label = label
        self.icon = icon
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(HUDTheme.rogCyan)
                    .frame(width: 24)

                Text(label)
                    .foregroundColor(HUDTheme.textSecondary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(HUDTheme.textSecondary.opacity(0.5))
            }
        }
    }
}

// MARK: - Data Export View
struct DataExportView: View {
    @StateObject private var historyManager = BenchmarkHistoryManager.shared
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 14) {
                ROGSubpageHeader(title: "导出数据")

                ScrollView {
                    VStack(spacing: 16) {
                        ROGCard(title: "选择格式", accent: HUDTheme.rogCyan) {
                            VStack(spacing: 12) {
                                ROGExportButton(title: "导出为 CSV", icon: "tablecells", disabled: historyManager.history.isEmpty) {
                                    exportCSV()
                                }

                                Divider().background(Color.white.opacity(0.1))

                                ROGExportButton(title: "导出为 JSON", icon: "curlybraces", disabled: historyManager.history.isEmpty) {
                                    exportJSON()
                                }

                                Divider().background(Color.white.opacity(0.1))

                                ROGExportButton(title: "导出为 PDF", icon: "doc.richtext", disabled: historyManager.history.isEmpty) {
                                    exportPDF()
                                }
                            }
                        }

                        if historyManager.history.isEmpty {
                            ROGCard(title: nil, accent: HUDTheme.borderSoft) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(HUDTheme.neonOrange)
                                    Text("暂无数据可导出")
                                        .foregroundColor(HUDTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
        .alert("导出结果", isPresented: $showingAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
    }

    private func exportCSV() {
        guard let csv = historyManager.exportToCSV() else {
            showAlert(message: "CSV 导出失败")
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("iPhoneInfo_\(dateString()).csv")

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            shareItems = [url]
            showShareSheet = true
        } catch {
            showAlert(message: "保存 CSV 文件失败: \(error.localizedDescription)")
        }
    }

    private func exportJSON() {
        guard let json = historyManager.exportToJSON() else {
            showAlert(message: "JSON 导出失败")
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("iPhoneInfo_\(dateString()).json")

        do {
            try json.data(using: .utf8)?.write(to: url)
            shareItems = [url]
            showShareSheet = true
        } catch {
            showAlert(message: "保存 JSON 文件失败: \(error.localizedDescription)")
        }
    }

    private func exportPDF() {
        guard let pdfData = historyManager.exportToPDF() else {
            showAlert(message: "PDF 导出功能正在开发中，敬请期待")
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("iPhoneInfo_\(dateString()).pdf")

        do {
            try pdfData.write(to: url)
            shareItems = [url]
            showShareSheet = true
        } catch {
            showAlert(message: "保存 PDF 文件失败: \(error.localizedDescription)")
        }
    }

    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }

    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - ROG Export Button
private struct ROGExportButton: View {
    let title: String
    let icon: String
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(disabled ? HUDTheme.textSecondary.opacity(0.5) : HUDTheme.rogCyan)
                    .frame(width: 24)

                Text(title)
                    .foregroundColor(disabled ? HUDTheme.textSecondary.opacity(0.5) : HUDTheme.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(HUDTheme.textSecondary.opacity(0.5))
            }
        }
        .disabled(disabled)
        .buttonStyle(.plain)
    }
}

// MARK: - ROG Subpage Header
private struct ROGSubpageHeader: View {
    let title: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("返回")
                        .font(.system(size: 16))
                }
                .foregroundColor(HUDTheme.rogCyan)
            }

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(HUDTheme.textPrimary)

            Spacer()

            Color.clear.frame(width: 60)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Clear History View
struct ClearHistoryView: View {
    @StateObject private var historyManager = BenchmarkHistoryManager.shared
    @State private var showConfirmation = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 14) {
                ROGSubpageHeader(title: "清除历史")

                Spacer()

                VStack(spacing: 24) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(HUDTheme.rogRed)
                        .shadow(color: HUDTheme.rogRed.opacity(0.5), radius: 20, x: 0, y: 0)

                    Text("清除历史记录")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(HUDTheme.textPrimary)

                    Text("此操作将删除所有 \(historyManager.history.count) 条测试历史记录，无法恢复。")
                        .font(.subheadline)
                        .foregroundColor(HUDTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    ROGRedActionButton(title: "确认删除", systemImage: "trash.fill") {
                        if historyManager.history.isEmpty {
                            showAlert(message: "暂无历史记录可删除")
                        } else {
                            showConfirmation = true
                        }
                    }
                    .padding(.horizontal, 40)
                    .opacity(historyManager.history.isEmpty ? 0.5 : 1.0)
                }

                Spacer()
            }
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
        .alert("确认删除", isPresented: $showConfirmation) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                historyManager.clearAllHistory()
                showAlert(message: "已成功删除所有历史记录")
            }
        } message: {
            Text("确定要删除所有历史记录吗？此操作无法撤销。")
        }
        .alert("操作结果", isPresented: $showingAlert) {
            Button("确定", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - User Agreement View
struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 14) {
                ROGSubpageHeader(title: "用户协议")

                ScrollView {
                    ROGCard(title: nil, accent: HUDTheme.rogCyan) {
                        Text("""
                        感谢您使用 iPhoneInfo 应用！

                        1. 本应用仅供个人学习和技术研究使用。
                        2. 测试结果仅供参考，不代表设备的官方性能指标。
                        3. 应用收集的信息仅存储在您的设备本地，不会上传到任何服务器。
                        4. 请在电量充足的环境下进行性能测试。
                        5. 长时间运行测试可能导致设备发热，请合理使用。

                        使用本应用即表示您同意本协议。
                        """)
                        .font(.body)
                        .foregroundColor(HUDTheme.textSecondary)
                        .lineSpacing(6)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 14) {
                ROGSubpageHeader(title: "隐私政策")

                ScrollView {
                    ROGCard(title: nil, accent: HUDTheme.rogCyan) {
                        Text("""
                        iPhoneInfo 应用尊重您的隐私。

                        1. 本应用所有数据均存储在您的设备本地。
                        2. 不会收集任何个人身份信息。
                        3. 设备信息仅用于性能测试和对比，不会用于其他用途。
                        4. 测试历史记录仅在本地存储，不会上传。
                        5. 不会与第三方共享您的数据。
                        6. 您可以随时在设置中清除所有历史记录。

                        如有任何隐私相关问题，请联系开发者。
                        """)
                        .font(.body)
                        .foregroundColor(HUDTheme.textSecondary)
                        .lineSpacing(6)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Open Source License View
struct OpenSourceLicenseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 14) {
                ROGSubpageHeader(title: "开源协议")

                ScrollView {
                    ROGCard(title: nil, accent: HUDTheme.rogCyan) {
                        Text("""
                        本应用使用以下开源库：

                        1. SwiftUI - Apple Inc.
                           https://developer.apple.com/documentation/swiftui

                        2. Metal - Apple Inc.
                           https://developer.apple.com/documentation/metal

                        3. CoreData - Apple Inc.
                           https://developer.apple.com/documentation/coredata

                        本应用遵循 MIT 许可证。
                        """)
                        .font(.body)
                        .foregroundColor(HUDTheme.textSecondary)
                        .lineSpacing(6)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Sensor Tools View
struct SensorToolsView: View {
    @StateObject private var sensorService = SensorService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 14) {
                ROGSubpageHeader(title: "传感器")

                ScrollView {
                    VStack(spacing: 16) {
                        let availability = sensorService.getSensorAvailability()

                        ROGCard(title: "可用性", accent: HUDTheme.rogCyan) {
                            VStack(spacing: 10) {
                                ROGSensorRow(label: "加速度计", value: availability.accelerometerAvailable ? "可用" : "不可用", available: availability.accelerometerAvailable)
                                Divider().background(Color.white.opacity(0.1))
                                ROGSensorRow(label: "陀螺仪", value: availability.gyroscopeAvailable ? "可用" : "不可用", available: availability.gyroscopeAvailable)
                                Divider().background(Color.white.opacity(0.1))
                                ROGSensorRow(label: "磁力计", value: availability.magnetometerAvailable ? "可用" : "不可用", available: availability.magnetometerAvailable)
                            }
                        }

                        ROGCard(title: "实时数据", accent: HUDTheme.neonGreen) {
                            VStack(spacing: 10) {
                                if let a = sensorService.accelerometerData {
                                    ROGSensorDataRow(label: "加速度", value: a.formattedMagnitude)
                                    ROGSensorDataRow(label: "X/Y/Z", value: String(format: "%.2f / %.2f / %.2f", a.x, a.y, a.z))
                                } else {
                                    Text("加速度计暂无数据")
                                        .foregroundColor(HUDTheme.textSecondary)
                                }

                                Divider().background(Color.white.opacity(0.1))

                                if let g = sensorService.gyroscopeData {
                                    ROGSensorDataRow(label: "角速度", value: String(format: "%.2f", g.totalRotationRate))
                                    ROGSensorDataRow(label: "X/Y/Z", value: String(format: "%.2f / %.2f / %.2f", g.x, g.y, g.z))
                                } else {
                                    Text("陀螺仪暂无数据")
                                        .foregroundColor(HUDTheme.textSecondary)
                                }

                                Divider().background(Color.white.opacity(0.1))

                                if let m = sensorService.magnetometerData {
                                    ROGSensorDataRow(label: "磁场强度", value: String(format: "%.2f", m.magneticFieldStrength))
                                    ROGSensorDataRow(label: "朝向", value: m.formattedHeading)
                                } else {
                                    Text("磁力计暂无数据")
                                        .foregroundColor(HUDTheme.textSecondary)
                                }
                            }
                        }

                        ROGCard(title: nil, accent: HUDTheme.borderSoft) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(HUDTheme.rogCyan)
                                Text("提示：传感器数据只反映本机当前状态，无法读取其他 App 的传感器使用情况")
                                    .font(.caption)
                                    .foregroundColor(HUDTheme.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
        .onAppear {
            sensorService.startMonitoring()
        }
        .onDisappear {
            sensorService.stopMonitoring()
        }
    }
}

// MARK: - ROG Sensor Row
private struct ROGSensorRow: View {
    let label: String
    let value: String
    let available: Bool

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(HUDTheme.textSecondary)
            Spacer()
            Text(value)
                .foregroundColor(available ? HUDTheme.neonGreen : HUDTheme.rogRed)
        }
    }
}

// MARK: - ROG Sensor Data Row
private struct ROGSensorDataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(HUDTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(HUDTheme.textPrimary)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

#Preview {
    SettingsView()
}
