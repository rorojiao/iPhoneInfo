import Foundation
import Combine
import UIKit

final class GamerDashboardService: ObservableObject {
    static let shared = GamerDashboardService()

    struct BatteryPlaytimeEstimate {
        let minutes: Int?
        let drainPercentPerMinute: Double?
        let isEstimate: Bool
    }

    struct Snapshot {
        let timestamp: Date

        let risk: GameRiskLevel
        let reasons: [String]
        let advice: String

        let thermalState: String
        let lowPowerModeEnabled: Bool

        let cpuUsage: Double
        let memoryUsage: Double
        let gpuUsage: Double

        let batteryLevelPercent: Int
        let batteryState: UIDevice.BatteryState
        let playtimeEstimate: BatteryPlaytimeEstimate

        let wifiIP: String?
        let cellularIP: String?

        let latencyMs: Double?
        let jitterMs: Double?
        let lossPercent: Double?

        let sustainedStabilityPercent: Double?
        let sustainedFirstScore: Int?
        let sustainedLastScore: Int?
        let sustainedThermalStart: String?
        let sustainedThermalEnd: String?

        let temperatureCelsius: Double?
        let performancePercent: Double?
        let realtimeStabilityPercent: Double?

        static let empty = Snapshot(
            timestamp: Date(),
            risk: .low,
            reasons: ["等待监控数据"],
            advice: "",
            thermalState: "未知",
            lowPowerModeEnabled: false,
            cpuUsage: 0,
            memoryUsage: 0,
            gpuUsage: 0,
            batteryLevelPercent: 0,
            batteryState: .unknown,
            playtimeEstimate: BatteryPlaytimeEstimate(minutes: nil, drainPercentPerMinute: nil, isEstimate: true),
            wifiIP: nil,
            cellularIP: nil,
            latencyMs: nil,
            jitterMs: nil,
            lossPercent: nil,
            sustainedStabilityPercent: nil,
            sustainedFirstScore: nil,
            sustainedLastScore: nil,
            sustainedThermalStart: nil,
            sustainedThermalEnd: nil,
            temperatureCelsius: nil,
            performancePercent: nil,
            realtimeStabilityPercent: nil
        )
    }

    @Published var snapshot: Snapshot = .empty

    private var batterySamples: [(timestamp: Date, levelPercent: Int)] = []
    private let maxBatterySamples = 20

    private var cancellables = Set<AnyCancellable>()

    private var lastMetrics: SystemMetrics?
    private var lastAssessment: GameExperienceAssessment?
    private var lastSustained: BenchmarkCoordinator.SustainedGamingResult?

    private init() {
        SystemMonitor.shared.$currentMetrics
            .sink { [weak self] metrics in
                guard let self else { return }
                self.lastMetrics = metrics
                GameExperienceService.shared.update(metrics: metrics, lastBenchmark: BenchmarkCoordinator.shared.currentResult)
                self.refreshSnapshot()
            }
            .store(in: &cancellables)

        GameExperienceService.shared.$assessment
            .sink { [weak self] assessment in
                self?.lastAssessment = assessment
                self?.refreshSnapshot()
            }
            .store(in: &cancellables)

        BenchmarkCoordinator.shared.$currentResult
            .sink { result in
                GameExperienceService.shared.update(metrics: SystemMonitor.shared.currentMetrics, lastBenchmark: result)
            }
            .store(in: &cancellables)

        BenchmarkCoordinator.shared.$sustainedResult
            .sink { [weak self] result in
                self?.lastSustained = result
                self?.refreshSnapshot()
            }
            .store(in: &cancellables)

        NetworkLatencyService.shared.$latestLatencyMs
            .sink { [weak self] _ in
                self?.refreshSnapshot()
            }
            .store(in: &cancellables)

        NetworkLatencyService.shared.$jitterMs
            .sink { [weak self] _ in
                self?.refreshSnapshot()
            }
            .store(in: &cancellables)

        NetworkLatencyService.shared.$lossPercent
            .sink { [weak self] _ in
                self?.refreshSnapshot()
            }
            .store(in: &cancellables)
    }

    func startGamerMonitoring() {
        if !SystemMonitor.shared.isMonitoring {
            SystemMonitor.shared.startMonitoring(interval: 1.0)
        }

        if !NetworkLatencyService.shared.isMonitoring {
            NetworkLatencyService.shared.startMonitoring()
        }
    }

    func stopGamerMonitoring() {
        NetworkLatencyService.shared.stopMonitoring()
    }

    private func refreshSnapshot() {
        let latencySummary = NetworkLatencyService.shared.currentSummary()
        update(
            metrics: lastMetrics,
            gameAssessment: lastAssessment,
            latency: latencySummary,
            sustained: lastSustained
        )
    }

    private func update(
        metrics: SystemMetrics?,
        gameAssessment: GameExperienceAssessment?,
        latency: NetworkLatencyService.Summary?,
        sustained: BenchmarkCoordinator.SustainedGamingResult?
    ) {
        guard let metrics else {
            snapshot = .empty
            return
        }

        let batteryPercent = Int((metrics.batteryLevel * 100).rounded())
        recordBatterySample(levelPercent: batteryPercent, timestamp: metrics.timestamp)

        let playtime = estimatePlaytimeMinutes(currentBatteryPercent: batteryPercent, lowPowerModeEnabled: metrics.lowPowerModeEnabled)

        let thermalStateText = describeThermalState(metrics.processThermalState)

        let performancePercent = computePerformancePercent(metrics: metrics, sustained: sustained)
        let realtimeStability = computeRealtimeStabilityPercent(metrics: metrics, latency: latency)

        let assessedRisk = gameAssessment?.risk ?? .low
        let assessedReasons = gameAssessment?.reasons ?? ["等待评估"]
        let assessedAdvice = gameAssessment?.advice ?? ""

        snapshot = Snapshot(
            timestamp: metrics.timestamp,
            risk: assessedRisk,
            reasons: assessedReasons,
            advice: assessedAdvice,
            thermalState: thermalStateText,
            lowPowerModeEnabled: metrics.lowPowerModeEnabled,
            cpuUsage: metrics.cpuUsage,
            memoryUsage: metrics.memoryUsage,
            gpuUsage: metrics.gpuUsage,
            batteryLevelPercent: batteryPercent,
            batteryState: metrics.batteryState,
            playtimeEstimate: playtime,
            wifiIP: metrics.wifiIP,
            cellularIP: metrics.cellularIP,
            latencyMs: latency?.latencyMs,
            jitterMs: latency?.jitterMs,
            lossPercent: latency?.lossPercent,
            sustainedStabilityPercent: sustained?.stabilityPercent,
            sustainedFirstScore: sustained?.firstScore,
            sustainedLastScore: sustained?.lastScore,
            sustainedThermalStart: sustained?.thermalStateStart,
            sustainedThermalEnd: sustained?.thermalStateEnd,
            temperatureCelsius: approximateTemperatureCelsius(metrics.thermalState),
            performancePercent: performancePercent,
            realtimeStabilityPercent: realtimeStability
        )
    }

    func oneTapOptimizationAdvice() -> [String] {
        var items: [String] = []

        if snapshot.lowPowerModeEnabled {
            items.append("低电量模式已开启：性能可能受限")
        } else {
            if snapshot.batteryLevelPercent <= 20 {
                items.append("电量偏低：建议开启低电量模式")
            }
        }

        if snapshot.thermalState == "发热" || snapshot.thermalState == "过热" {
            items.append("设备较热：建议降亮度/摘壳/停止充电")
        }

        if let latency = snapshot.latencyMs, latency >= 80 {
            items.append("网络延迟偏高：建议切换 Wi‑Fi/5G 或更换节点")
        }

        if let loss = snapshot.lossPercent, loss >= 5 {
            items.append("丢包偏高：建议重连网络或关闭 VPN 试试")
        }

        if items.isEmpty {
            items.append("当前状态良好")
        }

        return items
    }

    private func recordBatterySample(levelPercent: Int, timestamp: Date) {
        batterySamples.append((timestamp: timestamp, levelPercent: levelPercent))
        if batterySamples.count > maxBatterySamples {
            batterySamples.removeFirst(batterySamples.count - maxBatterySamples)
        }
    }

    private func estimatePlaytimeMinutes(currentBatteryPercent: Int, lowPowerModeEnabled: Bool) -> BatteryPlaytimeEstimate {
        guard batterySamples.count >= 2 else {
            return BatteryPlaytimeEstimate(minutes: nil, drainPercentPerMinute: nil, isEstimate: true)
        }

        guard let first = batterySamples.first, let last = batterySamples.last else {
            return BatteryPlaytimeEstimate(minutes: nil, drainPercentPerMinute: nil, isEstimate: true)
        }

        let deltaPercent = first.levelPercent - last.levelPercent
        let deltaSeconds = last.timestamp.timeIntervalSince(first.timestamp)
        guard deltaSeconds >= 30 else {
            return BatteryPlaytimeEstimate(minutes: nil, drainPercentPerMinute: nil, isEstimate: true)
        }

        let drainPerMinuteRaw = Double(deltaPercent) / (deltaSeconds / 60.0)
        let drainPerMinute = max(0.1, drainPerMinuteRaw)

        let adjustedDrain: Double = {
            if lowPowerModeEnabled {
                return drainPerMinute * 0.85
            }
            return drainPerMinute
        }()

        let minutes = Int(Double(currentBatteryPercent) / adjustedDrain)
        return BatteryPlaytimeEstimate(minutes: max(0, minutes), drainPercentPerMinute: adjustedDrain, isEstimate: true)
    }

    private func approximateTemperatureCelsius(_ state: ThermalState) -> Double? {
        switch state {
        case .normal:
            return 35
        case .light:
            return 38
        case .moderate:
            return 42
        case .heavy:
            return 48
        case .critical:
            return 55
        }
    }

    private func computePerformancePercent(metrics: SystemMetrics, sustained: BenchmarkCoordinator.SustainedGamingResult?) -> Double? {
        var score = 100.0

        if metrics.lowPowerModeEnabled {
            score -= 15
        }

        switch metrics.processThermalState {
        case .nominal:
            break
        case .fair:
            score -= 8
        case .serious:
            score -= 18
        case .critical:
            score -= 30
        @unknown default:
            score -= 12
        }

        let loadPenalty = (max(0, metrics.cpuUsage - 70) / 2) + (max(0, metrics.memoryUsage - 75) / 3)
        score -= min(20, loadPenalty)

        if let sustained, sustained.cpuSpeedDropPercent > 0 {
            score -= min(35, sustained.cpuSpeedDropPercent)
        }

        return max(0, min(100, score))
    }

    private func computeRealtimeStabilityPercent(metrics: SystemMetrics, latency: NetworkLatencyService.Summary?) -> Double? {
        var score = 100.0

        if let latency = latency?.latencyMs {
            if latency >= 120 {
                score -= 20
            } else if latency >= 80 {
                score -= 12
            } else if latency >= 50 {
                score -= 6
            }
        }

        if let jitter = latency?.jitterMs {
            if jitter >= 30 {
                score -= 20
            } else if jitter >= 15 {
                score -= 10
            } else if jitter >= 8 {
                score -= 5
            }
        }

        if let loss = latency?.lossPercent {
            score -= min(30, loss * 2)
        }

        switch metrics.processThermalState {
        case .nominal:
            break
        case .fair:
            score -= 5
        case .serious:
            score -= 12
        case .critical:
            score -= 22
        @unknown default:
            score -= 10
        }

        return max(0, min(100, score))
    }

    private func describeThermalState(_ state: ProcessInfo.ThermalState) -> String {
        switch state {
        case .nominal:
            return "正常"
        case .fair:
            return "温热"
        case .serious:
            return "发热"
        case .critical:
            return "过热"
        @unknown default:
            return "未知"
        }
    }
}
