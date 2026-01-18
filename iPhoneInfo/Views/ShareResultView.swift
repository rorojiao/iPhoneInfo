//
//  ShareResultView.swift
//  iPhoneInfo
//
//  Share result UI
//

import SwiftUI

struct ShareResultView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var shareCardService = ShareCardService.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    let result: ComprehensiveBenchmarkResult
    let sustainedResult: BenchmarkCoordinator.SustainedGamingResult?

    @State private var selectedStyle: ShareCardStyle = .rog
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    @State private var isGenerating = false
    @State private var copySuccess = false

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 0) {
                // Header
                headerView

                ScrollView {
                    VStack(spacing: 16) {
                        // Style selection
                        styleSelectionCard

                        // Preview card
                        previewCard

                        // Share actions
                        shareActionsCard

                        // Copy text section
                        copyTextSection

                        // Tips
                        tipsCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .padding(.top, 10)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(activityItems: [image])
            }
        }
        .alert("分享成功", isPresented: $copySuccess) {
            Button("确定") { }
        } message: {
            Text("文本已复制到剪贴板")
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("分享结果")
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

    // MARK: - Style Selection
    private var styleSelectionCard: some View {
        ROGCard(title: "卡片风格", accent: HUDTheme.rogCyan) {
            HStack(spacing: 12) {
                ForEach([ShareCardStyle.rog, ShareCardStyle.dark, ShareCardStyle.minimalist], id: \.self) { style in
                    Button(action: { selectedStyle = style }) {
                        HStack(spacing: 8) {
                            Image(systemName: styleIcon(style))
                                .foregroundColor(selectedStyle == style ? HUDTheme.rogCyan : HUDTheme.textSecondary)

                            Text(styleDisplayName(style))
                                .font(.subheadline)
                                .foregroundColor(HUDTheme.textPrimary)

                            if selectedStyle == style {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedStyle == style ? Color.white.opacity(0.1) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedStyle == style ? HUDTheme.rogCyan : HUDTheme.borderSoft, lineWidth: selectedStyle == style ? 2 : 1)
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Preview Card
    private var previewCard: some View {
        VStack(spacing: 12) {
            Text("预览")
                .font(.headline)
                .foregroundColor(HUDTheme.textPrimary)

            if let image = shareImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400)
                    .cornerRadius(12)
            } else if isGenerating {
                HStack {
                    ProgressView()
                        .tint(HUDTheme.rogCyan)
                    Text("生成卡片中...")
                }
                .foregroundColor(HUDTheme.textSecondary)
            } else {
                Text("选择风格后自动生成预览")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }

    // MARK: - Share Actions
    private var shareActionsCard: some View {
        ROGCard(title: "分享操作", accent: .clear) {
            VStack(alignment: .leading, spacing: 12) {
                // Generate card button
                Button(action: generateCard) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("生成分享卡片")
                        Spacer()
                        Text("→")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                }
                .buttonStyle(.plain)

                Divider().background(Color.white.opacity(0.1))

                // Share image button
                Button(action: shareImage) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("分享图片")
                        Spacer()
                        Text("→")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                }
                .disabled(shareImage == nil)
                .buttonStyle(.plain)

                Divider().background(Color.white.opacity(0.1))

                // Share text button
                Button(action: shareText) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("复制文本")
                        Spacer()
                        Text("→")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Copy Text Section
    private var copyTextSection: some View {
        ROGCard(title: "文本分享", accent: .clear) {
            VStack(alignment: .leading, spacing: 12) {
                Text("复制以下文本到社交媒体：")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(shareText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: copyToClipboard) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("复制文本")
                        Spacer()

                        if copySuccess {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Tips Card
    private var tipsCard: some View {
        ROGCard(title: "分享提示", accent: .clear) {
            VStack(alignment: .leading, spacing: 8) {
                TipRow(icon: "checkmark.circle.fill", text: "分享到微博、朋友圈等社交媒体")
                TipRow(icon: "checkmark.circle.fill", text: "可保存图片到相册后再分享")
                TipRow(icon: "checkmark.circle.fill", text: "图片包含二维码可引导好友下载")
                TipRow(icon: "info.circle.fill", text: "分享后可获得临时Pro权益")
            }
        }
    }

    // MARK: - Supporting Views
    private func styleIcon(_ style: ShareCardStyle) -> String {
        switch style {
        case .standard: return "doc.text"
        case .dark: return "moon.stars.fill"
        case .rog: return "flame.fill"
        case .minimalist: return "circle"
        }
    }

    private func styleDisplayName(_ style: ShareCardStyle) -> String {
        switch style {
        case .standard: return "标准"
        case .dark: return "暗色"
        case .rog: return "ROG风格"
        case .minimalist: return "极简"
        }
    }

    private var shareText: String {
        if let sustained = sustainedResult {
            return """
🎮 我的持续性能测试结果：

⚡ 首次得分：\(sustained.firstScore) → 最终得分：\(sustained.lastScore)
📊 稳定性：\(String(format: "%.1f", sustained.stabilityPercent))%
🔋 CPU降速：\(String(format: "%.1f", sustained.cpuSpeedDropPercent))%

#iPhoneInfo #持续性能测试
"""
        } else {
            return shareCardService.generateShareText(for: result)
        }
    }

    // MARK: - Actions
    private func generateCard() {
        isGenerating = true

        Task {
            do {
                if let sustained = sustainedResult {
                    shareImage = try? await shareCardService.generateShareCard(
                        for: sustained,
                        configuration: ShareCardConfiguration(style: selectedStyle, includeWatermark: true, includeQRCode: true)
                    )
                } else {
                    shareImage = try? await shareCardService.generateShareCard(
                        for: result,
                        configuration: ShareCardConfiguration(style: selectedStyle, includeWatermark: true, includeQRCode: true)
                    )
                }
            }
            isGenerating = false
        }
    }

    private func shareImage() {
        guard let image = shareImage else { return }
        showShareSheet = true
    }

    private func shareText() {
        UIPasteboard.general.string = shareText
        copySuccess = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copySuccess = false
        }
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = shareText
        copySuccess = true
    }
}

// MARK: - Helper Views
private struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.caption2)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview
#Preview {
    ShareResultView(
        result: ComprehensiveBenchmarkResult(
            date: Date(),
            deviceModel: "iPhone 15 Pro Max",
            deviceName: "我的iPhone",
            lowPowerModeEnabled: false,
            thermalStateStart: "正常",
            thermalStateEnd: "温热",
            stutterRisk: "低",
            cpuProbeStartOpsPerSec: 150000,
            cpuProbeEndOpsPerSec: 145000,
            cpuSpeedDropPercent: 3.3,
            cpuResult: CPUBenchmarkResult(
                singleCoreScore: 5000,
                multiCoreScore: 18000,
                integerScore: 8000,
                floatScore: 9000,
                cryptoScore: 7000,
                totalScore: 39000,
                grade: "A",
                testDuration: 30
            ),
            gpuResult: BenchmarkScore(
                averageFPS: 58.3,
                minFPS: 45,
                maxFPS: 60,
                frameCount: 8748,
                totalTime: 150,
                score: 8748,
                stability: 88.5,
                grade: "A"
            ),
            memoryResult: MemoryBenchmarkResult(
                sequentialReadSpeed: 8000,
                sequentialWriteSpeed: 6000,
                randomReadSpeed: 4000,
                randomWriteSpeed: 3000,
                smallFileRW: 5000,
                totalScore: 12000,
                grade: "A",
                testDuration: 15
            ),
            storageResult: StorageBenchmarkResult(
                sequentialReadSpeed: 9000,
                sequentialWriteSpeed: 7000,
                randomReadSpeed: 5000,
                randomWriteSpeed: 4000,
                smallFileRW: 6000,
                totalScore: 13000,
                grade: "A",
                testDuration: 10
            ),
            overallScore: 82000,
            overallGrade: "A",
            testDuration: 100,
            performanceLevel: .highEnd,
            recommendations: [
                "设备性能表现出色，可以流畅运行各种大型应用和3D游戏。",
                "GPU性能优异，可以开启最高画质设置。"
            ],
            comparisonWithAverage: ScoreComparison(
                cpuPercentile: 65.0,
                gpuPercentile: 70.0,
                memoryPercentile: 60.0,
                storagePercentile: 75.0
            )
        ),
        sustainedResult: BenchmarkCoordinator.SustainedGamingResult(
            startDate: Date(),
            endDate: Date().addingTimeInterval(-600),
            cycles: 3,
            firstScore: 8748,
            lastScore: 8520,
            stabilityPercent: 97.4,
            cpuProbeStartOpsPerSec: 150000,
            cpuProbeEndOpsPerSec: 145000,
            cpuSpeedDropPercent: 3.3,
            thermalStateStart: "正常",
            thermalStateEnd: "温热",
            batteryStartPercent: 85,
            batteryEndPercent: 82,
            perCycleScores: [8748, 8650, 8520]
        )
    )
}
