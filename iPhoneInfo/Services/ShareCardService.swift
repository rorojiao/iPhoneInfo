//
//  ShareCardService.swift
//  iPhoneInfo
//
//  Shareable result card generation
//

import Foundation
import UIKit
import SwiftUI
import CoreGraphics

// MARK: - Share Card Style
enum ShareCardStyle {
    case standard
    case dark
    case rog
    case minimalist

    var backgroundColor: UIColor {
        switch self {
        case .standard:
            return .systemBackground
        case .dark:
            return UIColor(white: 0.1)
        case .rog:
            return UIColor(rgba(30, 30, 30, 1.0))
        case .minimalist:
            return .white
        }
    }

    var textColor: UIColor {
        switch self {
        case .standard:
            return .label
        case .dark, .rog:
            return .white
        case .minimalist:
            return .black
        }
    }

    var accentColor: UIColor {
        switch self {
        case .standard:
            return .systemBlue
        case .dark:
            return .systemPurple
        case .rog:
            return UIColor(rgba(220, 20, 60, 1.0))
        case .minimalist:
            return .black
        }
    }
}

// MARK: - Share Card Configuration
struct ShareCardConfiguration {
    let style: ShareCardStyle
    let includeWatermark: Bool
    let includeQRCode: Bool
    let includeRanking: Bool
    let includeComparison: Bool

    static let `default` = ShareCardConfiguration(
        style: .rog,
        includeWatermark: true,
        includeQRCode: true,
        includeRanking: false,
        includeComparison: false
    )
}

// MARK: - Share Card Service
class ShareCardService {
    static let shared = ShareCardService()

    // MARK: - Public Methods

    /// Generate shareable image for benchmark result
    func generateShareCard(
        for result: ComprehensiveBenchmarkResult,
        configuration: ShareCardConfiguration = .default
    ) async -> UIImage {
        return await ImageRenderer(content: {
            ShareCardContentView(result: result, configuration: configuration)
        }.render())
    }

    /// Generate shareable image for sustained gaming result
    func generateShareCard(
        for result: BenchmarkCoordinator.SustainedGamingResult,
        configuration: ShareCardConfiguration = .default
    ) async -> UIImage {
        return await ImageRenderer(content: {
            SustainedGamingShareCardContentView(result: result, configuration: configuration)
        }).render()
    }

    /// Generate shareable text for social media
    func generateShareText(for result: ComprehensiveBenchmarkResult) -> String {
        let deviceName = result.deviceName
        let score = result.overallScore
        let grade = result.overallGrade

        return """
📱 iPhone 性能测试

我的 \(deviceName) 得分：\(score) 分
等级：\(grade) 级
性能水平：\(result.performanceLevel.description)

#iPhone性能测试 #iPhone跑分
"""
    }

    /// Generate quick share text
    func generateQuickShareText(score: Int, grade: String, deviceModel: String) -> String {
        return """
🎮 我的 \(deviceModel) 性能测试结果：

⚡ 总分：\(score) 分
🏆 等级：\(grade) 级

快来试试吧！
#iPhoneInfo #性能测试
"""
    }
}

// MARK: - Share Card Content View
struct ShareCardContentView: View {
    let result: ComprehensiveBenchmarkResult
    let configuration: ShareCardConfiguration

    var body: some View {
        GeometryReader { geometry in
            let cardSize = calculateCardSize(for: geometry.size)

            ZStack {
                // Background gradient
                backgroundGradient
                    .frame(width: cardSize.width, height: cardSize.height)

                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Score Section
                    scoreSection

                    // Details Section
                    detailsSection

                    // Footer
                    if configuration.includeWatermark {
                        footerSection
                    }
                }
                .padding(20)
            }
            .frame(width: cardSize.width, height: cardSize.height)
        }
    }

    // MARK: - Sections
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("iPhone 性能测试")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(textColor)

                Text(result.deviceName)
                    .font(.subheadline)
                    .foregroundColor(textSecondaryColor)
            }

            Spacer()

            if configuration.includeQRCode {
                qrCodePlaceholder
            }
        }
    }

    private var scoreSection: some View {
        VStack(spacing: 12) {
            // Large score display
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 120, height: 120)

                VStack(spacing: 4) {
                    Text("\(result.overallScore)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)

                    Text(result.overallGrade)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(gradeColor)
                        .clipShape(Capsule())
                }
            }

            // Performance level badge
            HStack(spacing: 8) {
                Image(systemName: performanceIcon)
                    .font(.caption)
                Text(result.performanceLevel.description)
                    .font(.caption)
            }
            .font(.subheadline)
            .foregroundColor(textSecondaryColor)
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            detailRow(icon: "cpu", label: "CPU", value: "\(result.cpuResult.totalScore)")
            detailRow(icon: "cube", label: "GPU", value: "\(result.gpuResult.score)")
            detailRow(icon: "memorychip", label: "内存", value: "\(result.memoryResult.totalScore)")
            detailRow(icon: "internaldrive", label: "存储", value: "\(result.storageResult.totalScore)")
        }
        .font(.caption)
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            Divider()
                .background(textColor.opacity(0.1))

            HStack {
                Image(systemName: "app.fill")
                    .font(.caption2)
                Text("iPhoneInfo")
                    .font(.caption2)
                Spacer()
                Text(result.date.formatted(date: .abbreviated))
                    .font(.caption2)
            }
            .foregroundColor(textSecondaryColor)
        }
    }

    // MARK: - Supporting Views
    private var qrCodePlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(textColor.opacity(0.1))
            .frame(width: 60, height: 60)
            .overlay(
                Image(systemName: "qrcode")
                    .font(.title3)
                    .foregroundColor(textColor)
            )
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .frame(width: 16)

            Text(label)
                .font(.caption2)

            Spacer()

            Text(value)
                .font(.caption2)
                .fontWeight(.semibold)
        }
    }

    // MARK: - Computed Properties
    private var textColor: Color { Color(textColor) }
    private var textSecondaryColor: Color { Color(textSecondaryColor) }

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(rgba(30, 30, 30, 1.0)),
                Color(rgba(10, 10, 10, 1.0)),
                Color(rgba(30, 30, 30, 1.0))
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var accentColor: Color { Color(accentColor) }

    private func gradeColor(for grade: String) -> Color {
        switch grade {
        case "S": return .purple
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        case "D": return .red
        default: return .gray
        }
    }

    private var gradeColor: UIColor { UIColor(gradeColor(for: result.overallGrade)) }

    private var performanceIcon: String {
        switch result.performanceLevel {
        case .entry: return "star.circle"
        case .mid: return "star.circle.fill"
        case .highEnd: return "star.fill"
        case .flagship: return "star.circle.fill"
        case .ultra: return "sparkles"
        }
    }

    // MARK: - Helper Methods
    private func calculateCardSize(for availableSize: CGSize) -> CGSize {
        let targetAspectRatio: CGFloat = 4 / 5
        let maxWidth = min(availableSize.width - 40, 400)

        var width = maxWidth
        var height = width / targetAspectRatio

        if height > availableSize.height - 40 {
            height = availableSize.height - 40
            width = height * targetAspectRatio
        }

        return CGSize(width: width, height: height: height)
    }
}

// MARK: - Sustained Gaming Share Card
struct SustainedGamingShareCardContentView: View {
    let result: BenchmarkCoordinator.SustainedGamingResult
    let configuration: ShareCardConfiguration

    var body: some View {
        GeometryReader { geometry in
            let cardSize = calculateCardSize(for: geometry.size)

            ZStack {
                // Background
                configuration.style.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("持续性能测试")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            Text(result.cycles > 0 ? "(\(result.cycles)轮)" : "")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Main score
                    VStack(spacing: 8) {
                        Text("首次得分")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))

                        Text("\(result.firstScore)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("最终得分")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))

                        Text("\(result.lastScore)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    // Stability
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("稳定性")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))

                            Text("\(String(format: "%.1f", result.stabilityPercent))%")
                                .font(.title2)
                                .foregroundColor(stabilityColor)
                        }

                        VStack(spacing: 4) {
                            Text("性能下降")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))

                            Text("-\(String(format: "%.1f", result.cpuSpeedDropPercent))%")
                                .font(.title2)
                                .foregroundColor(dropColor)
                        }

                        VStack(spacing: 4) {
                            Text("热状态")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))

                            Text(result.thermalStateEnd)
                                .font(.title2)
                                .foregroundColor(thermalColor)
                        }
                    }
                    .padding(.vertical, 20)

                    // Footer
                    HStack {
                        Text("iPhoneInfo")
                            .font(.caption2)
                        Spacer()
                        Text("持续性能测试")
                            .font(.caption2)
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .frame(width: cardSize.width, height: cardSize.height)
        }
    }

    private var stabilityColor: Color {
        if result.stabilityPercent >= 90 {
            return .green
        } else if result.stabilityPercent >= 80 {
            return .blue
        } else if result.stabilityPercent >= 70 {
            return .orange
        } else {
            return .red
        }
    }

    private var dropColor: Color {
        if result.cpuSpeedDropPercent <= 10 {
            return .green
        } else if result.cpuSpeedDropPercent <= 20 {
            return .orange
        } else {
            return .red
        }
    }

    private var thermalColor: Color {
        switch result.thermalStateEnd {
        case "正常", "温热": return .green
        case "发热": return .orange
        case "过热": return .red
        default: return .gray
        }
    }

    private func calculateCardSize(for availableSize: CGSize) -> CGSize {
        let targetAspectRatio: CGFloat = 4 / 5
        let maxWidth = min(availableSize.width - 40, 400)

        var width = maxWidth
        var height = width / targetAspectRatio

        if height > availableSize.height - 40 {
            height = availableSize.height - 40
            width = height * targetAspectRatio
        }

        return CGSize(width: width, height: height)
    }
}

// MARK: - Share Sheet Helper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
}
