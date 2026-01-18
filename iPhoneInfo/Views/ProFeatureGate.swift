//
//  ProFeatureGate.swift
//  iPhoneInfo
//
//  UI components for Pro feature gating
//

import SwiftUI

// MARK: - Pro Feature Gate View
struct ProFeatureGate<Content: View>: View {
    let feature: ProFeature
    let title: String
    let description: String
    let icon: String
    let content: Content

    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingSubscription = false

    init(
        title: String,
        description: String,
        icon: String = "lock.circle.fill",
        @ViewBuilder content: () -> Content
    ) {
        self.feature = ProFeature(wrappedValue: false)
        self.title = title
        self.description = description
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        Group {
            if subscriptionManager.isFeatureAvailable(feature) {
                content
            } else {
                lockedView
            }
        }
    }

    private var lockedView: some View {
        ROGCard(title: title, accent: HUDTheme.rogCyan) {
            VStack(spacing: 16) {
                // Lock icon
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundColor(HUDTheme.rogCyan)

                // Description
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(HUDTheme.textSecondary)
                    .multilineTextAlignment(.center)

                // Upgrade button
                Button(action: { showingSubscription = true }) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("升级到专业版解锁")
                        Image(systemName: "crown.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(HUDTheme.rogCyan)
                    .cornerRadius(25)
                }

                // Trial badge
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("7天免费试用")
                }
                .font(.caption)
                .foregroundColor(.green)

                Divider()
                    .background(Color.white.opacity(0.1))

                // Pro features preview
                VStack(alignment: .leading, spacing: 8) {
                    ProFeatureRow(icon: "checkmark.circle.fill", text: "完全无广告")
                    ProFeatureRow(icon: "checkmark.circle.fill", text: "完整测试场景")
                    ProFeatureRow(icon: "checkmark.circle.fill", text: "云端排行榜")
                    ProFeatureRow(icon: "checkmark.circle.fill", text: "无限历史记录")
                }
            }
            .padding(.vertical, 8)
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
    }
}

// MARK: - Inline Pro Feature Banner
struct ProFeatureBanner: View {
    let title: String
    let action: () -> Void

    @StateObject private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .foregroundColor(HUDTheme.rogCyan)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                Text("升级专业版解锁")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: action) {
                Text("升级")
                    .font(.subheadline.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(HUDTheme.rogCyan)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

// MARK: - Helper Views
private struct ProFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)

            Text(text)
                .font(.caption)
                .foregroundColor(HUDTheme.textSecondary)

            Spacer()
        }
    }
}

// MARK: - View Extensions
extension View {
    /// Wrap view in a Pro feature gate
    @ViewBuilder
    func proFeature(
        title: String,
        description: String,
        icon: String = "lock.circle.fill",
        @ViewBuilder content: () -> some View
    ) -> some View {
        ProFeatureGate(
            title: title,
            description: description,
            icon: icon,
            content: content
        )
    }

    /// Show Pro banner if feature is locked
    @ViewBuilder
    func proBanner(
        _ isLocked: Bool,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        if isLocked && !SubscriptionManager.shared.isPro {
            ProFeatureBanner(title: title, action: action)
        } else {
            self
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        ProFeatureGate(
            title: "完整GPU测试",
            description: "Aztec Ruins、Solar Bay等高级GPU测试场景需要专业版",
            icon: "cpu"
        ) {
            Text("这里是被锁定的内容")
        }

        ProFeatureBanner(title: "导出数据") {
            print("Upgrade")
        }
    }
    .padding()
    .background(Color(.systemBackground))
}
