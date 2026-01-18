//
//  SubscriptionView.swift
//  iPhoneInfo
//
//  Subscription management UI
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedProduct: Product?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isPurchasing = false
    @State private var showingRestoreSuccess = false

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Content
            VStack(spacing: 0) {
                // Header
                headerView

                ScrollView {
                    VStack(spacing: 20) {
                        // Current Status
                        statusCard

                        // Pro Features
                        featuresCard

                        // Pricing Options
                        pricingOptionsCard

                        // Terms
                        termsText
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 20)
            )
            .padding(.horizontal, 20)
        }
        .alert("购买提示", isPresented: $showError) {
            Button("确定") { }
        } message: {
            Text(errorMessage)
        }
        .alert("恢复成功", isPresented: $showingRestoreSuccess) {
            Button("确定") { }
        } message: {
            Text("您的购买已成功恢复")
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("升级到专业版")
                .font(.title2.bold())
                .foregroundColor(.white)

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Status Card
    private var statusCard: some View {
        ROGCard(title: nil, accent: .clear) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: subscriptionManager.isPro ? "checkmark.circle.fill" : "lock.circle.fill")
                        .font(.title2)
                        .foregroundColor(subscriptionManager.isPro ? .green : .orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(subscriptionManager.isPro ? "专业版已激活" : "当前为免费版")
                            .font(.headline)

                        if subscriptionManager.isPro, let days = subscriptionManager.daysRemaining {
                            Text("\(days)天后到期")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if subscriptionManager.isPro {
                            Text("已激活")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("升级解锁所有功能")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    if subscriptionManager.isPro {
                        Button("管理订阅") {
                            subscriptionManager.manageSubscription()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
    }

    // MARK: - Features Card
    private var featuresCard: some View {
        ROGCard(title: "专业版功能", accent: HUDTheme.rogCyan) {
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "checkmark.circle.fill", color: .green, title: "完全无广告", subtitle: "移除所有广告")
                FeatureRow(icon: "checkmark.circle.fill", color: .green, title: "完整测试场景", subtitle: "所有GPU测试场景")
                FeatureRow(icon: "checkmark.circle.fill", color: .green, title: "云端排行榜", subtitle: "全球设备性能对比")
                FeatureRow(icon: "checkmark.circle.fill", color: .green, title: "无限历史记录", subtitle: "云端同步所有测试")
                FeatureRow(icon: "checkmark.circle.fill", color: .green, title: "数据导出", subtitle: "CSV/JSON/PDF格式")
                FeatureRow(icon: "checkmark.circle.fill", color: .green, title: "高级设备对比", subtitle: "多维度分析")
                FeatureRow(icon: "checkmark.circle.fill", color: .green, title: "优先更新", subtitle: "提前体验新功能")
            }
        }
    }

    // MARK: - Pricing Options
    private var pricingOptionsCard: some View {
        ROGCard(title: "选择订阅方案", accent: .clear) {
            VStack(spacing: 12) {
                ForEach(Array(subscriptionManager.availableProducts.enumerated()), id: \.element) { index, product in
                    PricingOptionCard(
                        product: product,
                        isSelected: selectedProduct == product,
                        onTap: { selectedProduct = product },
                        onPurchase: purchase
                    )
                }

                // Restore purchases
                Button(action: restorePurchases) {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle")
                        Text("恢复购买")
                    }
                    .font(.subheadline)
                    .foregroundColor(HUDTheme.textSecondary)
                }
                .disabled(isPurchasing)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Terms Text
    private var termsText: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("订阅说明：")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("• 订阅会自动续期，除非在当前期间结束前至少24小时关闭自动续期")
                .font(.caption2)
                .foregroundColor(.secondary)

            Text("• 确认购买后，费用将从您的Apple ID账户中扣除")
                .font(.caption2)
                .foregroundColor(.secondary)

            Text("• 订阅期间，您可以随时在Apple ID设置中管理或取消订阅")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }

    // MARK: - Helper Views

    private struct FeatureRow: View {
        let icon: String
        let color: Color
        let title: String
        let subtitle: String

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
    }

    private struct PricingOptionCard: View {
        let product: Product
        let isSelected: Bool
        let onTap: () -> Void
        let onPurchase: () async -> Void

        @State private var isLoading = false

        var body: some View {
            HStack(spacing: 16) {
                // Selection indicator
                Circle()
                    .fill(isSelected ? HUDTheme.rogRed : Color.clear)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(HUDTheme.borderStrong, lineWidth: 2)
                    )

                // Pricing
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(SubscriptionManager.formatPrice(product))
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    // Savings badge
                    if product.id.contains("yearly"),
                       let monthlyProduct = monthlyProduct(for: product) {
                        if let savings = SubscriptionManager.yearlySavings(monthlyProduct: monthlyProduct, yearlyProduct: product) {
                            Text(savings)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }

                Spacer()

                // Action button
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Button(isSelected ? "已选择" : "订阅") {
                        onTap()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? HUDTheme.rogRed : HUDTheme.borderSoft, lineWidth: isSelected ? 2 : 1)
                    )
            )
            .onTapGesture {
                guard !isLoading else { return }
                onTap()
                Task {
                    isLoading = true
                    await onPurchase()
                    isLoading = false
                }
            }
        }

        private func monthlyProduct(for yearlyProduct: Product) -> Product? {
            SubscriptionManager.shared.availableProducts.first { $0.id.contains("monthly") }
        }
    }

    // MARK: - Actions

    private func purchase() async {
        guard let product = selectedProduct else {
            errorMessage = "请先选择订阅方案"
            showError = true
            return
        }

        isPurchasing = true

        do {
            try await subscriptionManager.purchase(product)
            dismiss()
        } catch SubscriptionError.userCancelled {
            // User cancelled, don't show error
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isPurchasing = false
    }

    private func restorePurchases() {
        Task {
            do {
                try await subscriptionManager.restorePurchases()
                showingRestoreSuccess = true
            } catch {
                errorMessage = "无法恢复购买：\(error.localizedDescription)"
                showError = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SubscriptionView()
}
