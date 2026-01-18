//
//  LeaderboardView.swift
//  iPhoneInfo
//
//  Cloud leaderboard UI
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var leaderboardService = CloudLeaderboardServiceObserver.shared

    @State private var selectedTab: LeaderboardType = .global
    @State private var selectedDeviceFilter: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 0) {
                // Header
                leaderboardHeader

                // Tab Picker
                tabPicker

                // Content
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error)
                } else {
                    leaderboardContent
                }
            }
            .padding(.top, 10)
        }
    }

    // MARK: - Header
    private var leaderboardHeader: some View {
        HStack {
            Text("云端排行榜")
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

    // MARK: - Tab Picker
    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LeaderboardType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedTab = type
                        Task { await loadLeaderboard() }
                    }) {
                        Text(type.displayName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedTab == type ? HUDTheme.textPrimary : HUDTheme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedTab == type ? HUDTheme.rogRed : Color.black.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTab == type ? HUDTheme.borderStrong : HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
                            )
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Content
    private var leaderboardContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // User Ranking Card
                if let userRanking = leaderboardService.userRankingCard {
                    userRankingCard(userRanking)
                }

                // Device Filter (for device leaderboard)
                if selectedTab == .byDevice {
                    deviceFilterPicker
                }

                // Leaderboard Entries
                if leaderboardService.entries.isEmpty {
                    emptyStateView
                } else {
                    leaderboardEntries
                }

                // Footer info
                footerInfo
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }

    // MARK: - User Ranking Card
    private func userRankingCard(_ ranking: UserRankingCard) -> some View {
        ROGCard(title: "我的排名", accent: HUDTheme.rogCyan) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("全球排名")
                            .font(.caption)
                            .foregroundColor(HUDTheme.textSecondary)
                        Text("#\(ranking.globalRank)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(HUDTheme.rogCyan)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("超越用户")
                            .font(.caption)
                            .foregroundColor(HUDTheme.textSecondary)
                        Text("\(ranking.percentile)%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }

                Divider().background(Color.white.opacity(0.1))

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("同设备排名")
                            .font(.caption)
                            .foregroundColor(HUDTheme.textSecondary)
                        Text("#\(ranking.deviceRank ?? "-")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(HUDTheme.textPrimary)
                    }

                    Spacer()

                    Text("查看详情 →")
                        .font(.caption)
                        .foregroundColor(HUDTheme.rogCyan)
                }
            }
        }
    }

    // MARK: - Device Filter
    private var deviceFilterPicker: some View {
        ROGCard(title: "筛选设备", accent: .clear) {
            Menu {
                Button("全部设备") {
                    selectedDeviceFilter = nil
                    Task { await loadLeaderboard() }
                }

                Divider()

                ForEach(popularDevices, id: \.self) { device in
                    Button(device) {
                        selectedDeviceFilter = device
                        Task { await loadLeaderboard() }
                    }
                }
            } label: {
                HStack {
                    Text(selectedDeviceFilter ?? "全部设备")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .foregroundColor(HUDTheme.textPrimary)
                .font(.subheadline)
            }
        }
    }

    // MARK: - Leaderboard Entries
    private var leaderboardEntries: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("排名")
                    .frame(width: 50, alignment: .leading)
                Text("设备")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("得分")
                    .frame(width: 80, alignment: .trailing)
                Text("等级")
                    .frame(width: 50, alignment: .trailing)
            }
            .font(.caption)
            .foregroundColor(HUDTheme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.3))

            // Entries
            ForEach(Array(leaderboardService.entries.enumerated()), id: \.element.id) { index, entry in
                LeaderboardEntryRow(
                    rank: index + 1,
                    entry: entry,
                    isCurrentUser: entry.deviceId == leaderboardService.currentDeviceId
                )
            }

            // Load More
            if leaderboardService.hasMore {
                Button(action: {
                    Task { await loadMoreEntries() }
                }) {
                    HStack {
                        ProgressView()
                            .tint(HUDTheme.rogCyan)
                        Text("加载更多...")
                    }
                    .font(.subheadline)
                    .foregroundColor(HUDTheme.textSecondary)
                }
                .padding(.vertical, 12)
            }
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }

    // MARK: - Supporting Views
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(HUDTheme.rogCyan)

            Text("正在加载排行榜...")
                .font(.subheadline)
                .foregroundColor(HUDTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("加载失败")
                .font(.headline)

            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("重试") {
                Task { await loadLeaderboard() }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
        .padding(.horizontal)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundColor(HUDTheme.textSecondary)

            Text("暂无排行数据")
                .font(.headline)

            Text("完成测试后您的分数将显示在排行榜中")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }

    private var footerInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("数据每小时更新一次")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 8) {
                Image(systemName: "lock.shield")
                    .foregroundColor(.green)
                Text("设备ID已匿名化处理")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(8)
    }

    // MARK: - Data
    private var popularDevices: [String] {
        [
            "iPhone 15 Pro Max",
            "iPhone 15 Pro",
            "iPhone 15",
            "iPhone 14 Pro Max",
            "iPhone 14 Pro",
            "iPhone 14"
        ]
    }

    // MARK: - Actions
    private func loadLeaderboard() async {
        isLoading = true
        errorMessage = nil

        do {
            try await leaderboardService.fetchLeaderboard(
                type: selectedTab,
                deviceModel: selectedDeviceFilter
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadMoreEntries() async {
        do {
            try await leaderboardService.loadMore()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Leaderboard Entry Row
struct LeaderboardEntryRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            // Rank
            Text("#\(rank)")
                .frame(width: 50, alignment: .leading)
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(rankColor)
                .fontWeight(.bold)

            // Device
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.deviceModel)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(entry.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Score
            Text("\(entry.totalScore)")
                .frame(width: 80, alignment: .trailing)
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(HUDTheme.textPrimary)

            // Grade
            Text(entry.grade)
                .frame(width: 50, alignment: .trailing)
                .font(.headline)
                .foregroundColor(gradeColor(entry.grade))
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isCurrentUser ? HUDTheme.rogRed.opacity(0.2) : Color.clear)
        .overlay(
            Rectangle()
                .stroke(isCurrentUser ? HUDTheme.rogRed : Color.clear, lineWidth: isCurrentUser ? 2 : 0)
        )
    }

    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .orange
        case 3: return .red
        default: return HUDTheme.textSecondary
        }
    }

    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "S": return .purple
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        default: return .gray
        }
    }
}

// MARK: - User Ranking Card
struct UserRankingCard {
    let globalRank: Int
    let deviceRank: Int?
    let percentile: Double
}

// MARK: - Leaderboard Service Observer
@MainActor
class CloudLeaderboardServiceObserver: ObservableObject {
    static let shared = CloudLeaderboardServiceObserver()

    @Published private(set) var entries: [LeaderboardEntry] = []
    @Published private(set) var userRankingCard: UserRankingCard?
    @Published private(set) var hasMore = false
    @Published private(set) var currentDeviceId: String = ""

    private let service = CloudLeaderboardService.shared
    private var currentOffset = 0
    private let pageSize = 50

    func fetchLeaderboard(
        type: LeaderboardType,
        deviceModel: String? = nil
    ) async throws {
        currentOffset = 0

        let response = try await service.fetchLeaderboard(
            type: type,
            deviceModel: deviceModel,
            limit: pageSize,
            offset: 0
        )

        entries = response.entries
        hasMore = response.entries.count == pageSize

        if let rank = response.userRank {
            userRankingCard = UserRankingCard(
                globalRank: rank,
                deviceRank: nil,
                percentile: response.userPercentile ?? 0
            )
        }

        currentDeviceId = generateDeviceId()
    }

    func loadMore() async throws {
        let response = try await service.fetchLeaderboard(
            type: .global,
            deviceModel: nil,
            limit: pageSize,
            offset: currentOffset
        )

        entries.append(contentsOf: response.entries)
        currentOffset += response.entries.count
        hasMore = response.entries.count == pageSize
    }

    private func generateDeviceId() -> String {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        return deviceId.sha256()
    }
}

// MARK: - String SHA256 Extension
extension String {
    func sha256() -> String {
        guard let data = self.data(using: .utf8) else { return self }

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG($0.count), &hash)
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Preview
#Preview {
    LeaderboardView()
}
