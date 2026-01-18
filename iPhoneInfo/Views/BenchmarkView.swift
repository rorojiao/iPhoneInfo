//
//  BenchmarkView.swift
//  iPhoneInfo
//
//  Performance benchmark testing view
//

import SwiftUI

struct BenchmarkView: View {
    @StateObject private var benchmarkCoordinator = BenchmarkCoordinator.shared
    @State private var selectedTestType: TestType = .quick
    @State private var showingResults = false
    @State private var showingDetailedResults = false

    enum TestType: String, CaseIterable {
        case quick = "快速测试"
        case full = "完整测试"
    }

    var body: some View {
        NavigationView {
            ROGPage(title: "性能测试") {
                ScrollView {
                    VStack(spacing: 16) {
                        ROGCard(title: "选择测试类型", accent: HUDTheme.rogCyan) {
                            ROGSegmentedPicker(
                                title: "Test Type",
                                selection: $selectedTestType,
                                items: TestType.allCases.map { ($0, $0.rawValue) }
                            )
                        }

                    // Progress Section
                    if benchmarkCoordinator.isRunning {
                        ROGCard(title: "测试进度", accent: HUDTheme.rogRed) {
                            VStack(spacing: 14) {
                                Text(benchmarkCoordinator.currentPhase)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(HUDTheme.textPrimary)

                                ProgressView(value: benchmarkCoordinator.progress)
                                    .tint(HUDTheme.rogRed)

                                Text("\(Int(benchmarkCoordinator.progress * 100))%")
                                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                                    .foregroundColor(HUDTheme.rogCyan)
                            }
                        }
                    }

                    // Results Section
                    if let result = benchmarkCoordinator.currentResult, !benchmarkCoordinator.isRunning {
                        VStack(alignment: .leading, spacing: 12) {
                            ROGCard(title: "测试结果", accent: HUDTheme.rogRed) {
                                OverallScoreCard(result: result)

                                Button(action: {
                                    showingDetailedResults = true
                                }) {
                                    HStack {
                                        Text("查看详细报告")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(HUDTheme.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: HUDTheme.secondaryButtonHeight)
                                    .padding(.horizontal, 14)
                                    .background(Color.black.opacity(0.55))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                                            .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
                                    )
                                    .shadow(color: HUDTheme.glowSoft, radius: 12, x: 0, y: 0)
                                    .cornerRadius(HUDTheme.smallCornerRadius)
                                }
                                .buttonStyle(.plain)

                                PerformanceLevelCard(level: result.performanceLevel, score: result.overallScore, grade: result.overallGrade)

                                VStack(spacing: 0) {
                                    TestScoreRow(icon: "cpu", name: "CPU 性能", score: result.cpuResult.totalScore, grade: result.cpuResult.grade)
                                    Divider().background(Color.white.opacity(0.12))
                                    TestScoreRow(icon: "cube", name: "GPU 性能", score: result.gpuResult.score, grade: result.gpuResult.grade)
                                    Divider().background(Color.white.opacity(0.12))
                                    TestScoreRow(icon: "memorychip", name: "内存性能", score: result.memoryResult.totalScore, grade: result.memoryResult.grade)
                                    Divider().background(Color.white.opacity(0.12))
                                    TestScoreRow(icon: "internaldrive", name: "存储性能", score: result.storageResult.totalScore, grade: result.storageResult.grade)
                                }
                                .background(Color.black.opacity(0.55))
                                .overlay(
                                    RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                                        .stroke(HUDTheme.borderSoft.opacity(0.7), lineWidth: HUDTheme.borderWidth)
                                )
                                .cornerRadius(HUDTheme.smallCornerRadius)
                            }

                            // Recommendations
                            if !result.recommendations.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("优化建议")
                                        .font(.headline)
                                        .padding(.horizontal)

                                    ForEach(result.recommendations, id: \.self) { recommendation in
                                        HStack(alignment: .top, spacing: 8) {
                                            Image(systemName: "lightbulb.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                            Text(recommendation)
                                                .font(.subheadline)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.top)
                            }
                        }
                    }

                    // Test Items (Info Only)
                    if !benchmarkCoordinator.isRunning && benchmarkCoordinator.currentResult == nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("测试项目")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                TestItemRow(icon: "cpu", name: "CPU 单核测试", duration: selectedTestType == .quick ? "10秒" : "10秒")
                                if selectedTestType == .full {
                                    Divider()
                                    TestItemRow(icon: "cpu.fill", name: "CPU 多核测试", duration: "10秒")
                                    Divider()
                                    TestItemRow(icon: "cpu.fill", name: "CPU 整数运算", duration: "5秒")
                                    Divider()
                                    TestItemRow(icon: "cpu.fill", name: "CPU 浮点运算", duration: "5秒")
                                    Divider()
                                    TestItemRow(icon: "cpu.fill", name: "CPU 加密性能", duration: "5秒")
                                    Divider()
                                    TestItemRow(icon: "cube", name: "GPU 渲染测试 (Manhattan 3.0)", duration: "15秒")
                                    Divider()
                                    TestItemRow(icon: "cube", name: "GPU 高复杂度 (Aztec Ruins)", duration: "20秒")
                                }
                                Divider()
                                TestItemRow(icon: "memorychip", name: "内存读写测试", duration: "10秒")
                                if selectedTestType == .full {
                                    Divider()
                                    TestItemRow(icon: "internaldrive", name: "存储读写测试", duration: "~5秒")
                                }
                            }
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }

                    // Device Status
                    if !benchmarkCoordinator.isRunning {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("设备状态")
                                .font(.headline)
                                .padding(.horizontal)

                            HStack(spacing: 30) {
                                StatusItem(icon: "battery.100", label: "电量", value: "\(Int(UIDevice.current.batteryLevel * 100))%")
                                StatusItem(icon: "thermometer", label: "温度", value: "\(Int(ThermalService.shared.currentTemperature))°C")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }

                    // Start Button
                    if !benchmarkCoordinator.isRunning {
                        ROGRedActionButton(title: "开始测试", systemImage: "play.circle.fill") {
                            startBenchmark()
                        }
                    }

                    // Test Info
                    if benchmarkCoordinator.currentResult == nil {
                        ROGCard(title: "提示", accent: HUDTheme.rogCyan) {
                            VStack(alignment: .leading, spacing: 8) {
                                InfoBullet(text: "预计耗时: \(estimatedTime)")
                                InfoBullet(text: "建议充电使用以获得最佳结果")
                                InfoBullet(text: "测试期间请保持屏幕常亮")
                                InfoBullet(text: "测试将真实运行计算密集型任务")
                                InfoBullet(text: "测试结果将自动保存到历史记录")
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        }
        .sheet(isPresented: $showingDetailedResults) {
            if let result = benchmarkCoordinator.currentResult {
                DetailedReportView(result: result)
            }
        }
    }

    private var estimatedTime: String {
        switch selectedTestType {
        case .quick: return "约 40 秒"
        case .full: return "约 2.5 分钟"
        }
    }

    private func startBenchmark() {
        switch selectedTestType {
        case .quick:
            benchmarkCoordinator.startQuickBenchmark { progress, phase in
                benchmarkCoordinator.progress = progress
                benchmarkCoordinator.currentPhase = phase
            }
        case .full:
            benchmarkCoordinator.startFullBenchmark { progress, phase in
                benchmarkCoordinator.progress = progress
                benchmarkCoordinator.currentPhase = phase
            }
        }
    }
}

// MARK: - Overall Score Card
struct OverallScoreCard: View {
    let result: ComprehensiveBenchmarkResult

    var body: some View {
        VStack(spacing: 16) {
            // Score Display
            ZStack {
                Circle()
                    .fill(gradeColor(for: result.overallGrade).opacity(0.2))
                    .frame(width: 120, height: 120)

                VStack(spacing: 4) {
                    Text("\(result.overallScore)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(gradeColor(for: result.overallGrade))

                    Text(result.overallGrade)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(gradeColor(for: result.overallGrade))
                        .clipShape(Capsule())
                }
            }

            // Test Duration
            Text("测试耗时: \(String(format: "%.1f", result.testDuration)) 秒")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func gradeColor(for grade: String) -> Color {
        switch grade {
        case "S": return .purple
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        default: return .gray
        }
    }
}

// MARK: - Performance Level Card
struct PerformanceLevelCard: View {
    let level: PerformanceLevel
    let score: Int
    let grade: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("性能水平")
                    .font(.headline)

                Spacer()

                Text(level.description)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(gradeColor(for: grade))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(gradeColor(for: grade).opacity(0.1))
                    .cornerRadius(8)
            }

            Text(level.detailedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
    }

    private func gradeColor(for grade: String) -> Color {
        switch grade {
        case "S": return .purple
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        default: return .gray
        }
    }
}

// MARK: - Test Score Row
struct TestScoreRow: View {
    let icon: String
    let name: String
    let score: Int
    let grade: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)

                HStack(spacing: 4) {
                    Text("得分: \(score)")
                        .font(.headline)
                        .foregroundColor(gradeColor(for: grade))

                    Text("等级: \(grade)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(gradeColor(for: grade))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }

            Spacer()
        }
        .padding()
    }

    private func gradeColor(for grade: String) -> Color {
        switch grade {
        case "S": return .purple
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        default: return .gray
        }
    }
}

// MARK: - Detailed Report View
struct DetailedReportView: View {
    let result: ComprehensiveBenchmarkResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(result.description)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("详细报告")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct TestItemRow: View {
    let icon: String
    let name: String
    let duration: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                Text(duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "clock")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .contentShape(Rectangle())
    }
}

struct StatusItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}

struct InfoBullet: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    BenchmarkView()
}
