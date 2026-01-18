//
//  CloudSyncService.swift
//  iPhoneInfo
//
//  Cloud data synchronization service
//

import Foundation
import Combine
import CloudKit

// MARK: - Sync Data Models
struct SyncBenchmarkResult: Codable {
    let id: UUID
    let date: Date
    let deviceModel: String
    let cpuScore: Int
    let gpuScore: Int
    let memoryScore: Int
    let storageScore: Int
    let totalScore: Int
    let grade: String
    let testType: String
    let testDuration: Double
    let details: String?
}

struct SyncSettings: Codable {
    let preferredTestType: String?
    let syncEnabled: Bool
    let lastSyncTimestamp: Date?
}

struct SyncData: Codable {
    let benchmarks: [SyncBenchmarkResult]
    let settings: SyncSettings
    let version: Int
    let timestamp: Date

    var isEmpty: Bool {
        benchmarks.isEmpty
    }
}

// MARK: - Sync Status
enum SyncStatus {
    case idle
    case syncing
    case success
    case failed(Error?)
    case syncingProgress(Double)

    var displayName: String {
        switch self {
        case .idle:
            return "未同步"
        case .syncing:
            return "同步中..."
        case .success:
            return "已同步"
        case .failed(let error):
            return "同步失败: \(error?.localizedDescription ?? "未知错误")"
        case .syncingProgress(let progress):
            return "同步中 \(Int(progress * 100))%"
        }
    }
}

// MARK: - Cloud Sync Service
@MainActor
class CloudSyncService: ObservableObject {
    static let shared = CloudSyncService()

    // Published properties
    @Published private(set) var syncStatus: SyncStatus = .idle
    @Published private(set) var lastSyncDate: Date?

    // Private properties
    private let historyManager = BenchmarkHistoryManager.shared
    private var cloudKitManager: CloudKitManager?
    private var proCloudManager: ProCloudManager?

    // Sync configuration
    private let freeSyncLimit = 30  // Free users: 30 records
    private let syncDebounceDelay: TimeInterval = 5.0

    private init() {
        if SubscriptionManager.shared.isPro {
            proCloudManager = ProCloudManager()
        } else {
            cloudKitManager = CloudKitManager()
        }
    }

    // MARK: - Public Methods

    /// Sync data to cloud
    func syncToCloud() async throws {
        guard SubscriptionManager.shared.isPro else {
            throw SyncError.requiresPro
        }

        syncStatus = .syncing
        defer {
            if case .syncing = syncStatus {
                syncStatus = .idle
            }
        }

        do {
            // Fetch all local history
            let results = historyManager.fetchAll()

            // Convert to sync format
            let syncResults = results.compactMap { result -> SyncBenchmarkResult? in
                guard let date = ISO8601DateFormatter().date(from: result.date) else { return nil }
                return SyncBenchmarkResult(
                    id: result.id ?? UUID(),
                    date: date,
                    deviceModel: result.deviceModel ?? "",
                    cpuScore: result.cpuScore,
                    gpuScore: result.gpuScore,
                    memoryScore: result.memoryScore,
                    storageScore: result.storageScore,
                    totalScore: result.totalScore,
                    grade: result.grade ?? "",
                    testType: result.testType ?? "quick",
                    testDuration: result.testDuration,
                    details: result.details
                )
            }

            // Get settings
            let settings = SyncSettings(
                preferredTestType: nil,
                syncEnabled: true,
                lastSyncTimestamp: Date()
            )

            let syncData = SyncData(
                benchmarks: syncResults,
                settings: settings,
                version: 1,
                timestamp: Date()
            )

            // Upload to cloud
            if let proManager = proCloudManager {
                try await proManager.uploadSyncData(syncData)
            } else if let cloudKit = cloudKitManager {
                try await cloudKit.uploadSyncData(syncData)
            }

            lastSyncDate = Date()
            syncStatus = .success
        } catch {
            syncStatus = .failed(error)
            throw error
        }
    }

    /// Pull data from cloud
    func pullFromCloud() async throws {
        guard SubscriptionManager.shared.isPro else {
            throw SyncError.requiresPro
        }

        syncStatus = .syncing

        do {
            let syncData: SyncData

            if let proManager = proCloudManager {
                syncData = try await proManager.fetchSyncData()
            } else if let cloudKit = cloudKitManager {
                syncData = try await cloudKit.fetchSyncData()
            } else {
                throw SyncError.serviceUnavailable
            }

            // Import to local database
            for result in syncData.benchmarks {
                historyManager.saveResult(
                    cpuScore: result.cpuScore,
                    gpuScore: result.gpuScore,
                    memoryScore: result.memoryScore,
                    storageScore: result.storageScore,
                    totalScore: result.totalScore,
                    grade: result.grade,
                    testType: result.testType,
                    testDuration: result.testDuration,
                    details: result.details ?? ""
                )
            }

            lastSyncDate = Date()
            syncStatus = .success
        } catch {
            syncStatus = .failed(error)
            throw error
        }
    }

    /// Get sync statistics
    func getSyncStats() -> (localCount: Int, cloudCount: Int?, lastSync: Date?) {
        let localCount = historyManager.fetchAll().count
        return (localCount, nil, lastSyncDate)
    }

    /// Clear local data
    func clearLocalData() async throws {
        historyManager.clearHistory()
        lastSyncDate = nil
    }
}

// MARK: - Pro Cloud Manager (Custom Backend)
class ProCloudManager {
    private let baseURL = "https://api.iphoneinfo.example.com/v1/sync"
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        self.session = URLSession(configuration: config)
    }

    func uploadSyncData(_ data: SyncData) async throws {
        let url = URL(string: "\(baseURL)/upload")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getAuthToken())", forHTTPHeaderField: "Authorization")

        request.httpBody = try JSONEncoder().encode(data)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw SyncError.uploadFailed
        }
    }

    func fetchSyncData() async throws -> SyncData {
        let url = URL(string: "\(baseURL)/download")!

        var request = URLRequest(url: url)
        request.setValue("Bearer \(getAuthToken())", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SyncError.downloadFailed
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(SyncData.self, from: data)
    }

    private func getAuthToken() -> String {
        // Get auth token from subscription receipt
        return UserDefaults.standard.string(forKey: "auth_token") ?? ""
    }
}

// MARK: - CloudKit Manager (iCloud)
class CloudKitManager {
    private let container: CKContainer
    private let privateDatabase: CKDatabase

    init() {
        container = CKContainer(identifier: "iCloud.com.iphoneinfo.benchmark")
        privateDatabase = container.privateCloudDatabase
    }

    func uploadSyncData(_ data: SyncData) async throws {
        let record = CKRecord(recordType: "Benchmark")
        record["data"] = try JSONEncoder().encode(data)
        record["timestamp"] = Date()

        try await privateDatabase.save(record)
    }

    func fetchSyncData() async throws -> SyncData {
        let query = CKQuery(recordType: "Benchmark", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)

        var records: [CKRecord] = []

        operation.recordMatchedBlock = { record in
            records.append(record)
        }

        operation.queryCompletionBlock = { _, error in
            if let error = error {
                throw error
            }
        }

        try await privateDatabase.add(operation)

        guard let record = records.first,
              let data = record["data"] as? Data else {
            throw SyncError.noData
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(SyncData.self, from: data)
    }
}

// MARK: - Sync Error
enum SyncError: LocalizedError {
    case requiresPro
    case uploadFailed
    case downloadFailed
    case serviceUnavailable
    case noData
    case quotaExceeded

    var errorDescription: String? {
        switch self {
        case .requiresPro:
            return "需要专业版才能使用云同步"
        case .uploadFailed:
            return "上传失败"
        case .downloadFailed:
            return "下载失败"
        case .serviceUnavailable:
            return "服务不可用"
        case .noData:
            return "没有云端数据"
        case .quotaExceeded:
            return "已达到配额限制"
        }
    }
}

// MARK: - Helper
private func ISO8601DateFormatter() -> ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}
