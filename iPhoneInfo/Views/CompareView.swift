//
//  CompareView.swift
//  iPhoneInfo
//
//  Historical data and comparison view - ROG HUD Style
//

import SwiftUI

struct CompareView: View {
    @State private var selectedTab: CompareTab = .history

    enum CompareTab: String, CaseIterable {
        case history = "历史记录"
        case comparison = "设备对比"
        case leaderboard = "云端排行"
    }

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 14) {
                ROGCompareHeader()

                ROGCompareTabPicker(selection: $selectedTab)

                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case .history:
                            ROGHistoryView()
                        case .comparison:
                            ROGComparisonView()
                        case .leaderboard:
                            ROGLeaderboardView()
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

// MARK: - ROG Compare Header
private struct ROGCompareHeader: View {
    var body: some View {
        HStack {
            Text("数据对比")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(HUDTheme.textPrimary)

            Spacer()

            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(HUDTheme.rogCyan)
                .padding(10)
                .background(Color.black.opacity(0.45))
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - ROG Compare Tab Picker
private struct ROGCompareTabPicker: View {
    @Binding var selection: CompareView.CompareTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(CompareView.CompareTab.allCases, id: \.self) { tab in
                Button(action: { selection = tab }) {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selection == tab ? HUDTheme.textPrimary : HUDTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
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

// MARK: - ROG History View
private struct ROGHistoryView: View {
    @StateObject private var historyManager = BenchmarkHistoryManager.shared

    var body: some View {
        VStack(spacing: 16) {
            if historyManager.history.isEmpty {
                ROGEmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "暂无历史记录",
                    message: "运行性能测试后，记录将显示在这里"
                )
            } else {
                ForEach(historyManager.history, id: \.id) { record in
                    ROGHistoryRecordCard(record: record)
                }
            }
        }
    }
}

// MARK: - ROG History Record Card
private struct ROGHistoryRecordCard: View {
    let record: BenchmarkRecord

    var body: some View {
        ROGCard(title: nil, accent: gradeColor) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.formattedDate)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(HUDTheme.textPrimary)
                        Text(record.formattedDuration)
                            .font(.caption)
                            .foregroundColor(HUDTheme.textSecondary)
                    }

                    Spacer()

                    ROGGradeBadge(grade: record.grade)
                }

                Divider().background(Color.white.opacity(0.1))

                HStack(spacing: 16) {
                    ROGScoreItem(label: "CPU", value: record.cpuScore, color: HUDTheme.rogCyan)
                    ROGScoreItem(label: "GPU", value: record.gpuScore, color: HUDTheme.neonGreen)
                    ROGScoreItem(label: "内存", value: record.memoryScore, color: .purple)
                    ROGScoreItem(label: "存储", value: record.storageScore, color: HUDTheme.neonOrange)
                    ROGScoreItem(label: "总分", value: record.totalScore, color: HUDTheme.rogRed)
                }

                Text("\(record.deviceName) | \(record.deviceModel)")
                    .font(.caption)
                    .foregroundColor(HUDTheme.textSecondary.opacity(0.7))
            }
        }
    }

    private var gradeColor: Color {
        switch record.grade {
        case "S": return .purple
        case "A": return HUDTheme.neonGreen
        case "B": return HUDTheme.rogCyan
        case "C": return HUDTheme.neonOrange
        default: return .gray
        }
    }
}

// MARK: - ROG Grade Badge
private struct ROGGradeBadge: View {
    let grade: String

    var body: some View {
        Text(grade)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 44, height: 44)
            .background(gradeColor)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(gradeColor.opacity(0.5), lineWidth: 2)
            )
            .shadow(color: gradeColor.opacity(0.5), radius: 8, x: 0, y: 0)
            .cornerRadius(10)
    }

    private var gradeColor: Color {
        switch grade {
        case "S": return .purple
        case "A": return HUDTheme.neonGreen
        case "B": return HUDTheme.rogCyan
        case "C": return HUDTheme.neonOrange
        default: return .gray
        }
    }
}

// MARK: - ROG Score Item
private struct ROGScoreItem: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(HUDTheme.textSecondary)
            Text("\(value)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ROG Comparison View
private struct ROGComparisonView: View {
    @StateObject private var historyManager = BenchmarkHistoryManager.shared
    @State private var selectedRecord1: BenchmarkRecord?
    @State private var selectedRecord2: BenchmarkRecord?

    var body: some View {
        VStack(spacing: 16) {
            ROGCard(title: "选择对比记录", accent: HUDTheme.rogCyan) {
                VStack(spacing: 12) {
                    if historyManager.history.count >= 2 {
                        ROGRecordPicker(
                            selectedRecord: $selectedRecord1,
                            history: historyManager.history,
                            placeholder: "选择第一条记录",
                            otherSelection: selectedRecord2
                        )

                        ROGRecordPicker(
                            selectedRecord: $selectedRecord2,
                            history: historyManager.history,
                            placeholder: "选择第二条记录",
                            otherSelection: selectedRecord1
                        )
                    } else {
                        Text("需要至少2条历史记录才能进行对比")
                            .font(.subheadline)
                            .foregroundColor(HUDTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    }
                }
            }

            if let record1 = selectedRecord1, let record2 = selectedRecord2, record1.id != record2.id {
                ROGComparisonResults(record1: record1, record2: record2)
            }
        }
    }
}

// MARK: - ROG Record Picker
private struct ROGRecordPicker: View {
    @Binding var selectedRecord: BenchmarkRecord?
    let history: [BenchmarkRecord]
    let placeholder: String
    let otherSelection: BenchmarkRecord?

    var body: some View {
        Menu {
            Button(placeholder) {
                selectedRecord = nil
            }
            ForEach(history.filter { $0.id != otherSelection?.id }) { record in
                Button("\(record.formattedDate) - \(record.totalScore)分") {
                    selectedRecord = record
                }
            }
        } label: {
            HStack {
                Text(selectedRecord?.formattedDate ?? placeholder)
                    .foregroundColor(selectedRecord != nil ? HUDTheme.textPrimary : HUDTheme.textSecondary)
                Spacer()
                if let score = selectedRecord?.totalScore {
                    Text("\(score)分")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(HUDTheme.rogCyan)
                }
                Image(systemName: "chevron.down")
                    .foregroundColor(HUDTheme.textSecondary)
            }
            .padding(12)
            .background(Color.black.opacity(0.55))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
            )
            .cornerRadius(8)
        }
    }
}

// MARK: - ROG Comparison Results
private struct ROGComparisonResults: View {
    let record1: BenchmarkRecord
    let record2: BenchmarkRecord

    var body: some View {
        ROGCard(title: "对比结果", accent: HUDTheme.rogRed) {
            VStack(spacing: 12) {
                ROGComparisonBar(label: "CPU", value1: record1.cpuScore, value2: record2.cpuScore)
                ROGComparisonBar(label: "GPU", value1: record1.gpuScore, value2: record2.gpuScore)
                ROGComparisonBar(label: "内存", value1: record1.memoryScore, value2: record2.memoryScore)
                ROGComparisonBar(label: "存储", value1: record1.storageScore, value2: record2.storageScore)
                ROGComparisonBar(label: "总分", value1: record1.totalScore, value2: record2.totalScore)

                Divider().background(Color.white.opacity(0.1))

                HStack {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(HUDTheme.rogCyan)
                            .frame(width: 10, height: 10)
                        Text(record1.formattedDate)
                            .font(.caption2)
                            .foregroundColor(HUDTheme.textSecondary)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Circle()
                            .fill(HUDTheme.neonGreen)
                            .frame(width: 10, height: 10)
                        Text(record2.formattedDate)
                            .font(.caption2)
                            .foregroundColor(HUDTheme.textSecondary)
                    }
                }

                let winner = record1.totalScore > record2.totalScore ? record1 : record2
                Text("最佳成绩: \(winner.formattedDate)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(HUDTheme.rogCyan)
            }
        }
    }
}

// MARK: - ROG Comparison Bar
private struct ROGComparisonBar: View {
    let label: String
    let value1: Int
    let value2: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(HUDTheme.textPrimary)
                Spacer()
                Text("\(value1)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(HUDTheme.rogCyan)
                Text("vs")
                    .font(.caption2)
                    .foregroundColor(HUDTheme.textSecondary)
                Text("\(value2)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(HUDTheme.neonGreen)
            }

            GeometryReader { geometry in
                let maxValue = max(value1, value2, 1)
                let bar1Width = CGFloat(value1) / CGFloat(maxValue) * geometry.size.width
                let bar2Width = CGFloat(value2) / CGFloat(maxValue) * geometry.size.width

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                        .cornerRadius(4)

                    HStack(spacing: 2) {
                        Rectangle()
                            .fill(HUDTheme.rogCyan)
                            .frame(width: bar1Width * 0.48, height: 8)
                            .cornerRadius(4)

                        Spacer()

                        Rectangle()
                            .fill(HUDTheme.neonGreen)
                            .frame(width: bar2Width * 0.48, height: 8)
                            .cornerRadius(4)
                    }
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - ROG Leaderboard View
private struct ROGLeaderboardView: View {
    @State private var selectedCategory: LeaderboardCategory = .total
    @StateObject private var historyManager = BenchmarkHistoryManager.shared

    enum LeaderboardCategory: String, CaseIterable {
        case total = "总分"
        case cpu = "CPU"
        case gpu = "GPU"
    }

    var body: some View {
        VStack(spacing: 16) {
            ROGCard(title: nil, accent: HUDTheme.rogCyan) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(LeaderboardCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
            }

            let sortedRecords = getSortedRecords()

            if sortedRecords.isEmpty {
                ROGEmptyStateView(
                    icon: "chart.bar.doc.horizontal",
                    title: "暂无排名数据",
                    message: "运行性能测试后，您的排名将显示在这里"
                )
            } else {
                ROGCard(title: "排行榜", accent: HUDTheme.rogRed) {
                    VStack(spacing: 0) {
                        ForEach(Array(sortedRecords.prefix(10).enumerated()), id: \.element.id) { index, record in
                            ROGLeaderboardRow(
                                rank: index + 1,
                                device: record.deviceName,
                                score: getScore(for: record),
                                isUser: record.deviceName == UIDevice.current.name
                            )

                            if index < min(sortedRecords.count, 10) - 1 {
                                Divider().background(Color.white.opacity(0.1))
                            }
                        }
                    }
                }

                if let userBest = getUserBestScore() {
                    ROGCard(title: "您的排名", accent: HUDTheme.rogCyan) {
                        VStack(spacing: 8) {
                            let userRank = getUserRank()
                            Text("第 \(userRank) 名")
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(HUDTheme.rogCyan)

                            let percentile = calculatePercentile(rank: userRank, total: sortedRecords.count)
                            Text("超越 \(percentile)% 的用户")
                                .font(.subheadline)
                                .foregroundColor(HUDTheme.neonGreen)

                            Text("最佳成绩: \(getScore(for: userBest)) 分")
                                .font(.caption)
                                .foregroundColor(HUDTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
            }
        }
    }

    private func getScore(for record: BenchmarkRecord) -> Int {
        switch selectedCategory {
        case .total: return record.totalScore
        case .cpu: return record.cpuScore
        case .gpu: return record.gpuScore
        }
    }

    private func getSortedRecords() -> [BenchmarkRecord] {
        return historyManager.history.sorted { getScore(for: $0) > getScore(for: $1) }
    }

    private func getUserBestScore() -> BenchmarkRecord? {
        return historyManager.history
            .filter { $0.deviceName == UIDevice.current.name }
            .max { getScore(for: $0) < getScore(for: $1) }
    }

    private func getUserRank() -> Int {
        let sorted = getSortedRecords()
        if let userBest = getUserBestScore() {
            return (sorted.firstIndex { $0.id == userBest.id } ?? 0) + 1
        }
        return 0
    }

    private func calculatePercentile(rank: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int(Double(total - rank) / Double(total) * 100)
    }
}

// MARK: - ROG Leaderboard Row
private struct ROGLeaderboardRow: View {
    let rank: Int
    let device: String
    let score: Int
    let isUser: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 32, height: 32)
                        .shadow(color: rankColor.opacity(0.5), radius: 6, x: 0, y: 0)
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(HUDTheme.textSecondary)
                        .frame(width: 32)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(device)
                    .font(.subheadline)
                    .fontWeight(isUser ? .bold : .regular)
                    .foregroundColor(HUDTheme.textPrimary)
                if isUser {
                    Text("您的设备")
                        .font(.caption2)
                        .foregroundColor(HUDTheme.rogCyan)
                }
            }

            Spacer()

            Text("\(score)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(HUDTheme.rogCyan)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(isUser ? HUDTheme.rogCyan.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }

    private var rankColor: Color {
        switch rank {
        case 1: return Color.yellow
        case 2: return Color.gray
        case 3: return HUDTheme.neonOrange
        default: return .clear
        }
    }
}

// MARK: - ROG Empty State View
private struct ROGEmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        ROGCard(title: nil, accent: HUDTheme.borderSoft) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundColor(HUDTheme.textSecondary.opacity(0.5))

                Text(title)
                    .font(.headline)
                    .foregroundColor(HUDTheme.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(HUDTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
        }
    }
}

// MARK: - Legacy Components (kept for compatibility)
struct HistoryView: View {
    var body: some View {
        ROGHistoryView()
    }
}

struct HistoryRecordCard: View {
    let record: BenchmarkRecord

    var body: some View {
        ROGHistoryRecordCard(record: record)
    }
}

struct GradeBadge: View {
    let grade: String

    var body: some View {
        ROGGradeBadge(grade: grade)
    }
}

struct ScoreItem: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        ROGScoreItem(label: label, value: value, color: color)
    }
}

struct ComparisonView: View {
    var body: some View {
        ROGComparisonView()
    }
}

struct RecordPicker: View {
    @Binding var selectedRecord: BenchmarkRecord?
    let history: [BenchmarkRecord]
    let placeholder: String

    var body: some View {
        ROGRecordPicker(
            selectedRecord: $selectedRecord,
            history: history,
            placeholder: placeholder,
            otherSelection: nil
        )
    }
}

struct ComparisonResults: View {
    let record1: BenchmarkRecord
    let record2: BenchmarkRecord

    var body: some View {
        ROGComparisonResults(record1: record1, record2: record2)
    }
}

struct ComparisonBar: View {
    let label: String
    let value1: Int
    let value2: Int
    let label1: String
    let label2: String

    var body: some View {
        ROGComparisonBar(label: label, value1: value1, value2: value2)
    }
}

struct ScoreSummary: View {
    let improvement: (cpu: Double, gpu: Double, memory: Double, storage: Double, total: Double)
    let betterRecord: BenchmarkRecord

    var body: some View {
        EmptyView()
    }
}

struct ImprovementRow: View {
    let label: String
    let value: Double

    var body: some View {
        EmptyView()
    }
}

struct LeaderboardView: View {
    var body: some View {
        ROGLeaderboardView()
    }
}

enum LeaderboardCategory: String, CaseIterable {
    case total = "总分"
    case cpu = "CPU"
    case gpu = "GPU"
}

struct LeaderboardContent: View {
    let category: LeaderboardCategory

    var body: some View {
        EmptyView()
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let device: String
    let score: Int
    let isUser: Bool

    var body: some View {
        ROGLeaderboardRow(rank: rank, device: device, score: score, isUser: isUser)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        ROGEmptyStateView(icon: icon, title: title, message: message)
    }
}

#Preview {
    CompareView()
}
