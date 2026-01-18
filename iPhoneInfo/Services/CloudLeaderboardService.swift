//
//  CloudLeaderboardService.swift
//  iPhoneInfo
//
//  Cloud leaderboard service
//

import Foundation
import CommonCrypto

// MARK: - Leaderboard Models
struct LeaderboardEntry: Codable, Identifiable {
    let id: String
    let deviceId: String          // 匿名哈希ID
    let deviceModel: String       // 设备型号
    let cpuScore: Int
    let gpuScore: Int
    let totalScore: Int
    let grade: String
    let testDate: Date
    let region: String            // 地区代码

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: testDate)
    }
}

struct LeaderboardResponse: Codable {
    let entries: [LeaderboardEntry]
    let totalCount: Int
    let userRank: Int?
    let userPercentile: Double?     // 超越用户的百分比

    enum CodingKeys: String, CodingKey {
        case entries, totalCount, userRank, userPercentile
    }
}

struct LeaderboardSubmitRequest: Codable {
    let deviceModel: String
    let cpuScore: Int
    let gpuScore: Int
    let totalScore: Int
    let grade: String
    let testType: String
    let lowPowerMode: Bool
    let thermalState: String
    let testDuration: Double
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case deviceModel, cpuScore, gpuScore, totalScore, grade
        case testType, lowPowerMode, thermalState, testDuration, timestamp
    }
}

// MARK: - Leaderboard Type
enum LeaderboardType: String, CaseIterable {
    case global = "global"
    case byDevice = "device"
    case weekly = "weekly"
    case monthly = "monthly"

    var displayName: String {
        switch self {
        case .global: return "全球总榜"
        case .byDevice: return "同设备对比"
        case .weekly: return "本周排行"
        case .monthly: return "本月排行"
        }
    }
}

// MARK: - Cloud Leaderboard Service
class CloudLeaderboardService {
    static let shared = CloudLeaderboardService()

    // API Configuration
    private let baseURL = "https://api.iphoneinfo.example.com/v1"
    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public Methods

    /// Fetch leaderboard
    func fetchLeaderboard(
        type: LeaderboardType,
        deviceModel: String? = nil,
        limit: Int = 100,
        offset: Int = 0
    ) async throws -> LeaderboardResponse {
        var components = URLComponents(string: "\(baseURL)/leaderboard", resolvingAgainstBaseURL: false)
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "type", value: type.rawValue),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]

        if let device = deviceModel {
            queryItems.append(URLQueryItem(name: "deviceModel", value: device))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw LeaderboardError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LeaderboardError.serverError
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(LeaderboardResponse.self, from: data)
    }

    /// Submit score to leaderboard
    func submitScore(_ result: ComprehensiveBenchmarkResult) async throws -> LeaderboardResponse {
        let url = URL(string: "\(baseURL)/leaderboard/submit")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let submitRequest = LeaderboardSubmitRequest(
            deviceModel: result.deviceModel,
            cpuScore: result.cpuResult.totalScore,
            gpuScore: result.gpuResult.score,
            totalScore: result.overallScore,
            grade: result.overallGrade,
            testType: "full",
            lowPowerMode: result.lowPowerModeEnabled,
            thermalState: result.thermalStateEnd,
            testDuration: result.testDuration,
            timestamp: result.date
        )

        request.httpBody = try JSONEncoder().encode(submitRequest)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw LeaderboardError.serverError
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(LeaderboardResponse.self, from: data)
    }

    /// Get user ranking
    func getUserRanking(score: Int, deviceModel: String) async throws -> Int {
        let url = URL(string: "\(baseURL)/leaderboard/rank")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "score": score,
            "deviceModel": deviceModel
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LeaderboardError.serverError
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let rank = json["rank"] as? Int {
            return rank
        }

        throw LeaderboardError.invalidResponse
    }

    // MARK: - Private Methods

    /// Generate anonymous device ID hash
    private func hashDeviceId() -> String {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let data = deviceId.data(using: .utf8) ?? Data()

        // Add salt to prevent rainbow table attacks
        let salt = "iPhoneInfo_Salt_2025".data(using: .utf8) ?? Data()
        var combined = data + salt

        // SHA256 hash
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        combined.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG($0.count), &hash)
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Leaderboard Error
enum LeaderboardError: LocalizedError {
    case invalidURL
    case serverError
    case invalidResponse
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .serverError:
            return "服务器错误"
        case .invalidResponse:
            return "无效的响应"
        case .networkError:
            return "网络错误"
        }
    }
}
