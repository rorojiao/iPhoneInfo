//
//  SubscriptionManager.swift
//  iPhoneInfo
//
//  Subscription management using StoreKit 2
//

import Foundation
import StoreKit

// MARK: - Subscription Tier
enum SubscriptionTier: Int, Comparable {
    case free = 0
    case pro = 1

    static func < (lhs: SubscriptionTier, rhs: SubscriptionTier) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .free: return "免费版"
        case .pro: return "专业版"
        }
    }

    var isPro: Bool {
        return self == .pro
    }
}

// MARK: - Subscription Product
enum SubscriptionProduct: String, CaseIterable {
    case monthly = "com.iphoneinfo.pro.monthly"
    case quarterly = "com.iphoneinfo.pro.quarterly"
    case yearly = "com.iphoneinfo.pro.yearly"

    var productId: String { rawValue }

    var displayName: String {
        switch self {
        case .monthly: return "月付"
        case .quarterly: return "季付"
        case .yearly: return "年付"
        }
    }

    var localizedDescription: String {
        switch self {
        case .monthly: return "解锁所有专业功能"
        case .quarterly: return "解锁所有专业功能，省17%"
        case .yearly: return "解锁所有专业功能，省45%"
        }
    }
}

// MARK: - Subscription Status
struct SubscriptionStatus: Codable {
    let tier: SubscriptionTier
    let productId: String?
    let startDate: Date?
    let expiryDate: Date?
    let isTrial: Bool
    let willAutoRenew: Bool

    var isActive: Bool {
        guard tier == .pro else { return false }
        guard let expiry = expiryDate else { return true } // Lifetime

        // Add grace period (3 days)
        let gracePeriod: TimeInterval = 3 * 24 * 60 * 60
        return Date() < expiry.addingTimeInterval(gracePeriod)
    }

    var daysRemaining: Int? {
        guard let expiry = expiryDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiry).day
        return max(0, days ?? 0)
    }
}

// MARK: - Pro Feature Property Wrapper
@propertyWrapper
struct ProFeature {
    var wrappedValue: Bool

    init(wrappedValue: Bool = false) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Subscription Manager
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    // Published properties
    @Published private(set) var status: SubscriptionStatus = .init(
        tier: .free,
        productId: nil,
        startDate: nil,
        expiryDate: nil,
        isTrial: false,
        willAutoRenew: false
    )

    @Published private(set) var isUpdatingSubscription = false
    @Published private(set) var availableProducts: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState = .offline

    // Private properties
    private var updateListenerTask: Task<Void, Error>?

    private init() {
        // Load cached status
        loadCachedStatus()

        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        // Load products
        Task {
            await loadProducts()
        }
    }

    // MARK: - Public Methods

    var isPro: Bool {
        status.isActive
    }

    var tier: SubscriptionTier {
        status.tier
    }

    var daysRemaining: Int? {
        status.daysRemaining
    }

    /// Check if a feature is available for current tier
    func isFeatureAvailable(_ feature: ProFeature) -> Bool {
        if isPro {
            return true
        }
        return feature.wrappedValue
    }

    /// Load products from App Store
    func loadProducts() async {
        do {
            // Start loading products from the App Store
            let storeProducts = try await Product.products(for: SubscriptionProduct.allCases.map(\.productId))

            // Filter out subscription products
            var subscriptions: [Product] = []
            var nonSubscriptions: [Product] = []

            for product in storeProducts {
                if product.type == .autoRenewable {
                    subscriptions.append(product)
                } else {
                    nonSubscriptions.append(product)
                }
            }

            self.availableProducts = subscriptions.sorted {
                $0.price < $1.price
            }

            print("[SubscriptionManager] Loaded \(subscriptions.count) subscription products")
        } catch {
            print("[SubscriptionManager] Failed to load products: \(error)")
        }
    }

    /// Purchase a subscription
    func purchase(_ product: Product) async throws {
        guard !isUpdatingSubscription else {
            throw SubscriptionError.purchaseInProgress
        }

        isUpdatingSubscription = true
        defer { isUpdatingSubscription = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            print("[SubscriptionManager] Purchase successful")
            // Check transaction verification
            await checkVerification(result)

        case .userCancelled:
            print("[SubscriptionManager] Purchase cancelled by user")
            throw SubscriptionError.userCancelled

        case .pending:
            print("[SubscriptionManager] Purchase pending")
            throw SubscriptionError.purchasePending

        @unknown default:
            print("[SubscriptionManager] Unknown purchase result")
            throw SubscriptionError.unknown
        }
    }

    /// Restore previous purchases
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updateSubscriptionStatus()
    }

    /// Manage subscription (opens App Store subscription management)
    func manageSubscription() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        Task {
            do {
                try await AppStore.showManageSubscriptions(in: scene)
            } catch {
                print("[SubscriptionManager] Failed to show manage subscriptions: \(error)")
            }
        }
    }

    // MARK: - Private Methods

    private func loadCachedStatus() {
        guard let data = UserDefaults.standard.data(forKey: "subscription_status"),
              let cached = try? JSONDecoder().decode(SubscriptionStatus.self, from: data) else {
            return
        }

        self.status = cached
        print("[SubscriptionManager] Loaded cached status: \(cached.tier.displayName)")
    }

    private func saveStatus(_ status: SubscriptionStatus) {
        self.status = status

        if let data = try? JSONEncoder().encode(status) {
            UserDefaults.standard.set(data, forKey: "subscription_status")
        }

        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: status)
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task(detached: { [weak self] in
            guard let self else { return nil }

            for await result in Transaction.updates {
                self.handleTransaction(result)
            }

            return nil
        } as! Task<Void, Error>)
    }

    private func handleTransaction(_ verification: VerificationResult<Transaction>) {
        guard case .verified(let transaction) = verification else {
            print("[SubscriptionManager] Transaction verification failed")
            return
        }

        if transaction.revocationDate == nil {
            // Transaction is valid
            Task {
                await updateSubscriptionStatus()
            }

            // Finish transaction
            if transaction.productType == .autoRenewable {
                await transaction.finish()
            }
        } else {
            // Transaction was revoked
            print("[SubscriptionManager] Transaction revoked")
            Task {
                await updateSubscriptionStatus()
            }
        }
    }

    private func checkVerification(_ result: VerificationResult<Product.PurchaseResult>) async {
        switch result {
        case .verified(let transaction):
            print("[SubscriptionManager] Purchase verified: \(transaction.productID)")
            await updateSubscriptionStatus()

        case .unverified(let result):
            print("[SubscriptionManager] Purchase unverified: \(result)")
            // Still update status, transaction might be valid locally
            await updateSubscriptionStatus()
        }
    }

    private func updateSubscriptionStatus() async {
        // Get current subscription status
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                // Parse subscription type from product ID
                let tier: SubscriptionTier = .pro

                let status = SubscriptionStatus(
                    tier: tier,
                    productId: transaction.productID,
                    startDate: transaction.purchaseDate,
                    expiryDate: transaction.expirationDate,
                    isTrial: transaction.offerType == .introductory,
                    willAutoRenew: transaction.revocationDate == nil
                )

                saveStatus(status)
                print("[SubscriptionManager] Subscription active, expires: \(status.expiryDate?.description ?? "lifetime")")
                return
            }
        }

        // No active subscription found
        let freeStatus = SubscriptionStatus(
            tier: .free,
            productId: nil,
            startDate: nil,
            expiryDate: nil,
            isTrial: false,
            willAutoRenew: false
        )

        saveStatus(freeStatus)
        print("[SubscriptionManager] No active subscription")
    }

    // MARK: - Static Helpers

    /// Format price with period
    static func formatPrice(_ product: Product) -> String {
        let priceString = product.displayPrice
        let period: String

        if product.id.contains("monthly") {
            period = "/月"
        } else if product.id.contains("quarterly") {
            period = "/季"
        } else if product.id.contains("yearly") {
            period = "/年"
        } else {
            period = ""
        }

        return "\(priceString)\(period)"
    }

    /// Calculate savings for yearly plan
    static func yearlySavings(monthlyProduct: Product, yearlyProduct: Product) -> String? {
        guard let monthlyPrice = monthlyProduct.price,
              let yearlyPrice = yearlyProduct.price else {
            return nil
        }

        let yearlyMonthly = monthlyPrice * 12
        let savings = yearlyMonthly - yearlyPrice
        let savingsPercent = (savings / yearlyMonthly) * 100

        return String(format: "省%.0f%%", savingsPercent)
    }
}

// MARK: - Subscription Error
enum SubscriptionError: LocalizedError {
    case purchaseInProgress
    case userCancelled
    case purchasePending
    case unknown
    case productNotAvailable
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .purchaseInProgress:
            return "购买正在进行中"
        case .userCancelled:
            return "购买已取消"
        case .purchasePending:
            return "购买待处理"
        case .unknown:
            return "未知错误"
        case .productNotAvailable:
            return "产品不可用"
        case .verificationFailed:
            return "验证失败"
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
}

// MARK: - Extensions
extension RenewalState {
    var displayName: String {
        switch self {
        case .offline:
            return "离线"
        case .subscribed:
            return "已订阅"
        case .inGracePeriod:
            return "宽限期内"
        case .revoked:
            return "已取消"
        caseexpired:
            return "已过期"
        @unknown default:
            return "未知"
        }
    }
}
