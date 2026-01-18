//
//  DataExportView.swift
//  iPhoneInfo
//
//  Data export UI
//

import SwiftUI

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var exportService = DataExportServiceObserver.shared

    @State private var selectedFormat: ExportFormat = .csv
    @State private var includeDetails = true
    @State private var limitEnabled = false
    @State private var selectedLimit: Int = 50
    @State private var isExporting = false
    @State private var exportedURL: URL?
    @State private var showingShareSheet = false

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 0) {
                // Header
                headerView

                ScrollView {
                    VStack(spacing: 20) {
                        // Export format selection
                        formatSelectionCard

                        // Export options
                        exportOptionsCard

                        // Export summary
                        exportSummaryCard

                        // Export button
                        exportButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .padding(.top, 10)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedURL {
                ShareSheet(activityItems: [url])
            }
        }
        .alert("导出提示", isPresented: Binding(
            get: { exportService.errorMessage != nil },
            set: { _ in exportService.errorMessage = nil }
        )) {
            Button("确定") { }
        } message: {
            Text(exportService.errorMessage ?? "")
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("数据导出")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(HUDTheme.textPrimary)

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(HUDTheme.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: - Format Selection
    private var formatSelectionCard: some View {
        ROGCard(title: "导出格式", accent: HUDTheme.rogCyan) {
            VStack(spacing: 12) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Button(action: {
                        selectedFormat = format
                    }) {
                        HStack {
                            Image(systemName: formatIcon(format))
                                .foregroundColor(selectedFormat == format ? HUDTheme.rogCyan : HUDTheme.textSecondary)
                                .frame(width: 30)

                            Text(format.displayName)
                                .font(.subheadline)
                                .foregroundColor(HUDTheme.textPrimary)

                            Spacer()

                            if selectedFormat == format {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(selectedFormat == format ? Color.white.opacity(0.1) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedFormat == format ? HUDTheme.rogCyan : HUDTheme.borderSoft, lineWidth: selectedFormat == format ? 2 : 1)
                        )
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }

                // Format descriptions
                formatDescriptionRow(format: .csv, desc: "Excel表格兼容，适合数据分析", icon: "tablecells")
                formatDescriptionRow(format: .json, desc: "结构化数据，开发者友好", icon: "curlybraces")
                formatDescriptionRow(format: .pdf, desc: "专业报告格式，适合分享", icon: "doc.richtext")
            }
        }
    }

    // MARK: - Export Options
    private var exportOptionsCard: some View {
        ROGCard(title: "导出选项", accent: .clear) {
            VStack(alignment: .leading, spacing: 16) {
                // Include details toggle
                ToggleRow(
                    icon: "doc.text",
                    title: "包含详细信息",
                    subtitle: "包含完整的测试详情数据",
                    isOn: $includeDetails
                )

                Divider().background(Color.white.opacity(0.1))

                // Limit toggle
                ToggleRow(
                    icon: "line.3.horizontal.decrease.circle",
                    title: "限制导出数量",
                    subtitle: limitEnabled ? "最近\(selectedLimit)条记录" : "导出所有记录",
                    isOn: $limitEnabled
                )

                if limitEnabled {
                    HStack {
                        Text("数量:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Stepper(value: $selectedLimit, in: 10...500, step: 10) {
                            Text("\(selectedLimit)条")
                        }
                    }
                    .padding(.leading, 40)
                }
            }
        }
    }

    // MARK: - Export Summary
    private var exportSummaryCard: some View {
        ROGCard(title: "导出预览", accent: .clear) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("导出内容将包含:")
                        .font(.subheadline)
                }

                VStack(alignment: .leading, spacing: 8) {
                    summaryRow(icon: "calendar", text: "测试日期和设备信息")
                    summaryRow(icon: "chart.bar", text: "CPU/GPU/内存/存储得分")
                    summaryRow(icon: "info.circle", text: includeDetails ? "详细测试结果" : "仅基础数据")
                    summaryRow(icon: "line.3.horizontal.decrease.circle", text: limitEnabled ? "最近\(selectedLimit)条记录" : "所有历史记录")
                }
            }
        }
    }

    // MARK: - Export Button
    private var exportButton: some View {
        Button(action: performExport) {
            HStack {
                if isExporting {
                    ProgressView()
                        .tint(.white)

                    Text("导出中...")
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)

                    Text("导出数据")
                        .font(.headline.bold())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canExport ? HUDTheme.rogRed : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isExporting || !canExport)
    }

    // MARK: - Helper Views
    private func formatIcon(_ format: ExportFormat) -> String {
        switch format {
        case .csv: return "tablecells"
        case .json: return "curlybraces"
        case .pdf: return "doc.richtext"
        }
    }

    private func formatDescriptionRow(format: ExportFormat, desc: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(desc)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text(format.displayName.uppercased())
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
        }
    }

    private struct ToggleRow: View {
        let icon: String
        let title: String
        let subtitle: String
        @Binding var isOn: Bool

        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("", isOn: $isOn)
                    .tint(HUDTheme.rogCyan)
            }
        }
    }

    private func summaryRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Computed Properties
    private var canExport: Bool {
        exportService.availableCount > 0
    }

    // MARK: - Actions
    private func performExport() {
        isExporting = true

        Task {
            do {
                let config = DataExportService.ExportConfig(
                    format: selectedFormat,
                    includeDetails: includeDetails,
                    dateRange: nil,
                    limit: limitEnabled ? selectedLimit : nil
                )

                let url = try await exportService.exportHistory(config: config)

                await MainActor.run {
                    exportedURL = url
                    isExporting = false
                    showingShareSheet = true
                }
            } catch {
                await MainActor.run {
                    exportService.errorMessage = error.localizedDescription
                    isExporting = false
                }
            }
        }
    }
}

// MARK: - Export Service Observer
@MainActor
class DataExportServiceObserver: ObservableObject {
    static let shared = DataExportServiceObserver()

    @Published private(set) var availableCount: Int = 0
    @Published private(set) var errorMessage: String?

    private let historyManager = BenchmarkHistoryManager.shared

    init() {
        updateAvailableCount()
    }

    func updateAvailableCount() {
        availableCount = historyManager.fetchAll().count
    }
}

// MARK: - Preview
#Preview {
    DataExportView()
}
