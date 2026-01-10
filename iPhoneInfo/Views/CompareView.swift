//
//  CompareView.swift
//  iPhoneInfo
//
//  Historical data and comparison view
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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Tab Picker
                    Picker("Compare Tab", selection: $selectedTab) {
                        ForEach(CompareTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Tab Content
                    switch selectedTab {
                    case .history:
                        HistoryView()
                    case .comparison:
                        ComparisonView()
                    case .leaderboard:
                        LeaderboardView()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("数据对比")
        }
    }
}

// MARK: - History View
struct HistoryView: View {
    @State private var mockHistory: [BenchmarkRecord] = [
        BenchmarkRecord(date: Date(), cpuScore: 8234, gpuScore: 15678, totalScore: 12345, grade: "A"),
        BenchmarkRecord(date: Date().addingTimeInterval(-86400), cpuScore: 8156, gpuScore: 15432, totalScore: 12100, grade: "A"),
        BenchmarkRecord(date: Date().addingTimeInterval(-172800), cpuScore: 8289, gpuScore: 15789, totalScore: 12456, grade: "A"),
    ]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(mockHistory) { record in
                HistoryRecordCard(record: record)
            }
            .padding(.horizontal)

            if mockHistory.isEmpty {
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "暂无历史记录",
                    message: "运行性能测试后，记录将显示在这里"
                )
            }
        }
    }
}

struct HistoryRecordCard: View {
    let record: BenchmarkRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(record.date))
                        .font(.headline)
                    Text(formatTime(record.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                GradeBadge(grade: record.grade)
            }

            Divider()

            HStack(spacing: 20) {
                ScoreItem(label: "CPU", value: record.cpuScore, color: .blue)
                ScoreItem(label: "GPU", value: record.gpuScore, color: .green)
                ScoreItem(label: "总分", value: record.totalScore, color: .purple)
            }

            Text("iOS 17.2 | iPhone 15 Pro Max")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月 dd日"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct GradeBadge: View {
    let grade: String

    var body: some View {
        Text(grade)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(gradeColor(for: grade))
            .clipShape(Capsule())
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

struct ScoreItem: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.headline)
                .foregroundColor(color)
        }
    }
}

// MARK: - Comparison View
struct ComparisonView: View {
    var body: some View {
        EmptyStateView(
            icon: "chart.bar.doc.horizontal",
            title: "设备对比",
            message: "添加其他设备的测试记录进行对比"
        )
        .padding(.horizontal)
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @State private var selectedCategory: LeaderboardCategory = .total

    enum LeaderboardCategory: String, CaseIterable {
        case total = "总分"
        case cpu = "CPU"
        case gpu = "GPU"
    }

    var body: some View {
        VStack(spacing: 16) {
            // Category Picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(LeaderboardCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Leaderboard List
            VStack(spacing: 0) {
                LeaderboardRow(rank: 1, device: "iPhone 15 Pro Max", score: 12567, isUser: true)
                Divider()
                LeaderboardRow(rank: 2, device: "iPhone 15 Pro", score: 11890, isUser: false)
                Divider()
                LeaderboardRow(rank: 3, device: "iPhone 14 Pro Max", score: 11234, isUser: false)
                Divider()
                LeaderboardRow(rank: 4, device: "iPhone 15 Plus", score: 10567, isUser: false)
                Divider()
                LeaderboardRow(rank: 5, device: "iPhone 14 Pro", score: 10234, isUser: false)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)

            // User Rank
            VStack(spacing: 8) {
                Text("您的排名")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("第 1 名")
                    .font(.title)
                    .fontWeight(.bold)
                Text("超越 95% 的用户")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let device: String
    let score: Int
    let isUser: Bool

    var body: some View {
        HStack {
            // Rank
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor(for: rank))
                        .frame(width: 32, height: 32)
                    Text("\(rank)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text("\(rank)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 32)
                }
            }

            // Device
            VStack(alignment: .leading, spacing: 2) {
                Text(device)
                    .font(.subheadline)
                    .fontWeight(isUser ? .bold : .regular)
                if isUser {
                    Text("您的设备")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            // Score
            Text("\(score)")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
        .background(isUser ? Color.blue.opacity(0.1) : Color.clear)
    }

    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .clear
        }
    }
}

// MARK: - Models
struct BenchmarkRecord: Identifiable {
    let id = UUID()
    let date: Date
    let cpuScore: Int
    let gpuScore: Int
    let totalScore: Int
    let grade: String
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    CompareView()
}
