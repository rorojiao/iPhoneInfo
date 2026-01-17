//
//  BenchmarkCoordinator.swift
//  iPhoneInfo
//
//  Comprehensive benchmark coordination and scoring system
//

import Foundation
import Combine
import Metal
import UIKit

// MARK: - Comprehensive Result
struct ComprehensiveBenchmarkResult {
    let date: Date
    let deviceModel: String
    let deviceName: String

    let lowPowerModeEnabled: Bool
    let thermalStateStart: String
    let thermalStateEnd: String
    let stutterRisk: String
    let cpuProbeStartOpsPerSec: Double
    let cpuProbeEndOpsPerSec: Double
    let cpuSpeedDropPercent: Double

    // Individual test results
    let cpuResult: CPUBenchmarkResult
    let gpuResult: BenchmarkScore
    let memoryResult: MemoryBenchmarkResult
    let storageResult: StorageBenchmarkResult

    // Overall scores
    let overallScore: Int
    let overallGrade: String
    let testDuration: TimeInterval

    // Analysis
    let performanceLevel: PerformanceLevel
    let recommendations: [String]
    let comparisonWithAverage: ScoreComparison

    var description: String { 
        return """
        iPhone 综合性能测试报告
        =========================

        设备: \(deviceName) (\(deviceModel))
        测试时间: \(formatDate(date))
        测试耗时: \(String(format: "%.1f", testDuration)) 秒

        低电量模式: \(lowPowerModeEnabled ? "开启" : "关闭")
        热状态(开始→结束): \(thermalStateStart) → \(thermalStateEnd)
        游戏卡顿风险: \(stutterRisk)
        CPU 探针(开始→结束): \(String(format: "%.0f", cpuProbeStartOpsPerSec)) → \(String(format: "%.0f", cpuProbeEndOpsPerSec)) ops/s
        CPU 降速估计: \(String(format: "%.1f", cpuSpeedDropPercent))%

        CPU 性能: \(cpuResult.totalScore) 分 - 等级 \(cpuResult.grade)
        GPU 性能: \(gpuResult.score) 分 - 等级 \(gpuResult.grade)
        内存性能: \(memoryResult.totalScore) 分 - 等级 \(memoryResult.grade)
        存储性能: \(storageResult.totalScore) 分 - 等级 \(storageResult.grade)

        ------------------------
        综合得分: \(overallScore)
        综合等级: \(overallGrade)
        性能水平: \(performanceLevel.description)

        CPU 详情:
        - 单核: \(cpuResult.singleCoreScore)
        - 多核: \(cpuResult.multiCoreScore)
        - 整数: \(cpuResult.integerScore)
        - 浮点: \(cpuResult.floatScore)
        - 加密: \(cpuResult.cryptoScore)

        GPU 详情:
        - 平均帧率: \(String(format: "%.1f", gpuResult.averageFPS)) FPS
        - 稳定性: \(String(format: "%.1f", gpuResult.stability))%

        内存详情:
        - 顺序读取: \(String(format: "%.1f", Double(memoryResult.sequentialReadSpeed) / 1024.0)) GB/s
        - 顺序写入: \(String(format: "%.1f", Double(memoryResult.sequentialWriteSpeed) / 1024.0)) GB/s

        存储详情:
        - 顺序读取: \(String(format: "%.1f", Double(storageResult.sequentialReadSpeed) / 1024.0)) GB/s
        - 顺序写入: \(String(format: "%.1f", Double(storageResult.sequentialWriteSpeed) / 1024.0)) GB/s

        性能评估:
        \(performanceLevel.detailedDescription)

        优化建议:
        \(recommendations.joined(separator: "\n"))

        与平均水平对比:
        \(comparisonWithAverage.description)
        """
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - Performance Level
enum PerformanceLevel {
    case entry       // 入门级
    case mid         // 中端
    case highEnd     // 高端
    case flagship    // 旗舰
    case ultra       // 顶级

    var description: String {
        switch self {
        case .entry: return "入门级"
        case .mid: return "中端"
        case .highEnd: return "高端"
        case .flagship: return "旗舰"
        case .ultra: return "顶级"
        }
    }

    var detailedDescription: String {
        switch self {
        case .entry:
            return "您的设备性能处于入门水平，适合日常轻度使用。"
        case .mid:
            return "您的设备性能处于中端水平，可以流畅运行大多数应用和游戏。"
        case .highEnd:
            return "您的设备性能出色，可以流畅运行各种大型应用和3D游戏。"
        case .flagship:
            return "您的设备性能优异，属于旗舰级别，可以轻松应对所有应用场景。"
        case .ultra:
            return "您的设备性能处于顶级水平，是目前最强大的移动设备之一。"
        }
    }

    static func from(score: Int) -> PerformanceLevel {
        switch score {
        case 0..<5000: return .entry
        case 5000..<10000: return .mid
        case 10000..<15000: return .highEnd
        case 15000..<20000: return .flagship
        default: return .ultra
        }
    }
}

// MARK: - Score Comparison
struct ScoreComparison {
    let cpuPercentile: Double      // 0-100
    let gpuPercentile: Double      // 0-100
    let memoryPercentile: Double   // 0-100
    let storagePercentile: Double  // 0-100

    var description: String {
        return """
        CPU: 超过 \(String(format: "%.1f", cpuPercentile))% 的设备
        GPU: 超过 \(String(format: "%.1f", gpuPercentile))% 的设备
        内存: 超过 \(String(format: "%.1f", memoryPercentile))% 的设备
        存储: 超过 \(String(format: "%.1f", storagePercentile))% 的设备
        """
    }
}

// MARK: - Benchmark Coordinator
class BenchmarkCoordinator: ObservableObject {
    static let shared = BenchmarkCoordinator()

    struct SustainedGamingResult {
        let startDate: Date
        let endDate: Date
        let cycles: Int

        let firstScore: Int
        let lastScore: Int
        let stabilityPercent: Double

        let cpuProbeStartOpsPerSec: Double
        let cpuProbeEndOpsPerSec: Double
        let cpuSpeedDropPercent: Double

        let thermalStateStart: String
        let thermalStateEnd: String

        let batteryStartPercent: Int
        let batteryEndPercent: Int

        let perCycleScores: [Int]
    }

    @Published var isRunning = false
    @Published var progress: Double = 0
    @Published var currentPhase: String = ""
    @Published var currentResult: ComprehensiveBenchmarkResult?

    @Published var isSustainedRunning = false
    @Published var sustainedProgress: Double = 0
    @Published var sustainedPhase: String = ""
    @Published var sustainedResult: SustainedGamingResult?

    private let cpuBenchmark = CPUBenchmark()
    private let memoryBenchmark = MemoryBenchmark()
    private let storageBenchmark = StorageBenchmark()
    private let historyManager = BenchmarkHistoryManager.shared

    private let device: MTLDevice?
    private var runningTask: Task<Void, Never>?

    private init() {
        self.device = MTLCreateSystemDefaultDevice()
    }

    func startFullBenchmark(progressUpdate: @escaping (Double, String) -> Void) {
        startBenchmark(type: .full, progressUpdate: progressUpdate)
    }

    func startQuickBenchmark(progressUpdate: @escaping (Double, String) -> Void) {
        startBenchmark(type: .quick, progressUpdate: progressUpdate)
    }

    func startSustainedGamingBenchmark(progressUpdate: @escaping (Double, String) -> Void) {
        startSustainedGamingBenchmark(config: .default, progressUpdate: progressUpdate)
    }

    struct SustainedGamingConfig {
        let minCycles: Int
        let maxCycles: Int
        let intervalSeconds: Double
        let stableThermalCycles: Int

        static let `default` = SustainedGamingConfig(minCycles: 3, maxCycles: 8, intervalSeconds: 8, stableThermalCycles: 2)
    }

    func startSustainedGamingBenchmark(config: SustainedGamingConfig, progressUpdate: @escaping (Double, String) -> Void) {
        guard !isRunning, !isSustainedRunning else { return }

        runningTask?.cancel()
        sustainedResult = nil

        runningTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            await MainActor.run {
                self.isSustainedRunning = true
                self.sustainedProgress = 0
                self.sustainedPhase = "准备中..."
                self.sustainedResult = nil
                progressUpdate(0, "准备中...")
            }

            let startDate = Date()
            let thermalStartState = ProcessInfo.processInfo.thermalState
            let thermalStart = self.describeThermalState(thermalStartState)

            let batteryStartPercent = await MainActor.run {
                UIDevice.current.isBatteryMonitoringEnabled = true
                return Int((UIDevice.current.batteryLevel * 100).rounded())
            }

            let cpuProbeStart = self.cpuBenchmark.runThrottlingProbe()

            var perCycleScores: [Int] = []
            var thermalStates: [ProcessInfo.ThermalState] = []

            for cycleIndex in 0..<max(1, config.maxCycles) {
                if Task.isCancelled { break }

                let phaseText = "稳定性测试：第 \(cycleIndex + 1) 轮"
                await MainActor.run {
                    self.sustainedPhase = phaseText
                    progressUpdate(self.sustainedProgress, phaseText)
                }

                let gpuScore = self.runGPUBenchmark().score
                perCycleScores.append(gpuScore)

                let thermalNow = ProcessInfo.processInfo.thermalState
                thermalStates.append(thermalNow)

                let progress = Double(cycleIndex + 1) / Double(max(1, config.maxCycles))
                await MainActor.run {
                    self.sustainedProgress = progress
                    progressUpdate(progress, phaseText)
                }

                let canStop: Bool = {
                    guard perCycleScores.count >= config.minCycles else { return false }
                    guard thermalStates.count >= config.stableThermalCycles else { return false }

                    let recent = thermalStates.suffix(config.stableThermalCycles)
                    guard let first = recent.first else { return false }
                    return recent.allSatisfy { $0 == first }
                }()

                if canStop { break }

                if cycleIndex < config.maxCycles - 1 {
                    let nanos = UInt64(max(0, config.intervalSeconds) * 1_000_000_000)
                    try? await Task.sleep(nanoseconds: nanos)
                }
            }

            if Task.isCancelled {
                await MainActor.run {
                    self.isSustainedRunning = false
                    self.sustainedPhase = ""
                    self.sustainedProgress = 0
                }
                return
            }

            let cpuProbeEnd = self.cpuBenchmark.runThrottlingProbe()
            let cpuDropPercent: Double = {
                guard cpuProbeStart > 0 else { return 0 }
                return max(0, (cpuProbeStart - cpuProbeEnd) / cpuProbeStart * 100.0)
            }()

            let thermalEndState = thermalStates.last ?? ProcessInfo.processInfo.thermalState
            let thermalEnd = self.describeThermalState(thermalEndState)

            let batteryEndPercent = await MainActor.run {
                UIDevice.current.isBatteryMonitoringEnabled = true
                return Int((UIDevice.current.batteryLevel * 100).rounded())
            }

            let endDate = Date()

            let firstScore = perCycleScores.first ?? 0
            let lastScore = perCycleScores.last ?? 0
            let stabilityPercent: Double = {
                guard firstScore > 0 else { return 0 }
                return Double(lastScore) / Double(firstScore) * 100.0
            }()

            let result = SustainedGamingResult(
                startDate: startDate,
                endDate: endDate,
                cycles: perCycleScores.count,
                firstScore: firstScore,
                lastScore: lastScore,
                stabilityPercent: stabilityPercent,
                cpuProbeStartOpsPerSec: cpuProbeStart,
                cpuProbeEndOpsPerSec: cpuProbeEnd,
                cpuSpeedDropPercent: cpuDropPercent,
                thermalStateStart: thermalStart,
                thermalStateEnd: thermalEnd,
                batteryStartPercent: batteryStartPercent,
                batteryEndPercent: batteryEndPercent,
                perCycleScores: perCycleScores
            )

            await MainActor.run {
                self.sustainedResult = result
                self.isSustainedRunning = false
                self.sustainedPhase = ""
            }
        }
    }

    private enum BenchmarkType {
        case full
        case quick
    }

    private func startBenchmark(type: BenchmarkType, progressUpdate: @escaping (Double, String) -> Void) {
        guard !isRunning else { return }

        runningTask?.cancel()
        runningTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            await MainActor.run {
                self.isRunning = true
                self.progress = 0
                self.currentPhase = "准备中..."
                self.currentResult = nil
                progressUpdate(0, "准备中...")
            }

            let startTime = Date()
            let deviceModel = self.getDeviceModel()
            let deviceName = await MainActor.run { UIDevice.current.name }

            let lowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
            let thermalStartState = ProcessInfo.processInfo.thermalState
            let thermalStart = self.describeThermalState(thermalStartState)
            let cpuProbeStart = self.cpuBenchmark.runThrottlingProbe()

            await MainActor.run {
                self.currentPhase = "正在测试 CPU 性能..."
                progressUpdate(0.0, "正在测试 CPU 性能...")
            }
            let cpuResult: CPUBenchmarkResult = {
                switch type {
                case .full:
                    return self.cpuBenchmark.runFullBenchmark()
                case .quick:
                    return self.cpuBenchmark.runQuickTest()
                }
            }()

            await MainActor.run {
                self.progress = (type == .full) ? 0.25 : 0.33
                progressUpdate(self.progress, "CPU 测试完成")
            }

            await MainActor.run {
                self.currentPhase = "正在测试 GPU 性能..."
                progressUpdate(self.progress, "正在测试 GPU 性能...")
            }
            let gpuResult = self.runGPUBenchmark()

            await MainActor.run {
                self.progress = (type == .full) ? 0.5 : 0.66
                progressUpdate(self.progress, "GPU 测试完成")
            }

            await MainActor.run {
                self.currentPhase = "正在测试内存性能..."
                progressUpdate(self.progress, "正在测试内存性能...")
            }
            let memoryResult: MemoryBenchmarkResult = {
                switch type {
                case .full:
                    return self.memoryBenchmark.runFullBenchmark()
                case .quick:
                    return self.memoryBenchmark.runQuickTest()
                }
            }()

            await MainActor.run {
                self.progress = (type == .full) ? 0.75 : 1.0
                progressUpdate(self.progress, "内存测试完成")
            }

            let storageResult: StorageBenchmarkResult
            if type == .full {
                await MainActor.run {
                    self.currentPhase = "正在测试存储性能..."
                    progressUpdate(self.progress, "正在测试存储性能...")
                }
                storageResult = self.storageBenchmark.runFullBenchmark()

                await MainActor.run {
                    self.progress = 1.0
                    progressUpdate(1.0, "存储测试完成")
                }
            } else {
                storageResult = StorageBenchmarkResult(
                    sequentialReadSpeed: memoryResult.sequentialReadSpeed / 2,
                    sequentialWriteSpeed: memoryResult.sequentialWriteSpeed / 2,
                    randomReadSpeed: memoryResult.sequentialReadSpeed / 4,
                    randomWriteSpeed: memoryResult.sequentialWriteSpeed / 4,
                    smallFileRW: memoryResult.sequentialReadSpeed / 3,
                    totalScore: memoryResult.totalScore / 2,
                    testDuration: 0
                )
            }

            let elapsed = Date().timeIntervalSince(startTime)

            let overallScore = self.calculateOverallScore(
                cpu: cpuResult.totalScore,
                gpu: gpuResult.score,
                memory: memoryResult.totalScore,
                storage: storageResult.totalScore
            )

            let overallGrade = self.calculateGrade(score: overallScore)
            let performanceLevel = PerformanceLevel.from(score: overallScore)

            let thermalEndState = ProcessInfo.processInfo.thermalState
            let thermalEnd = self.describeThermalState(thermalEndState)

            let cpuProbeEnd = self.cpuBenchmark.runThrottlingProbe()
            let cpuDropPercent: Double = {
                guard cpuProbeStart > 0 else { return 0 }
                return max(0, min((1.0 - (cpuProbeEnd / cpuProbeStart)) * 100.0, 100.0))
            }()

            let stutterRisk = self.evaluateStutterRisk(
                gpuStability: Double(gpuResult.stability),
                thermalEndState: thermalEndState,
                lowPowerMode: lowPowerMode,
                cpuDropPercent: cpuDropPercent
            )

            var recommendations = self.generateRecommendations(
                cpu: cpuResult,
                gpu: gpuResult,
                memory: memoryResult,
                storage: storageResult
            )

            if lowPowerMode {
                recommendations.insert("当前处于低电量模式，可能导致游戏帧率波动/降频", at: 0)
            }

            if thermalEndState != .nominal {
                recommendations.insert("设备温度偏高（热状态：\(thermalEnd)），可能触发降频与卡顿", at: 0)
            }

            if stutterRisk != "低" {
                recommendations.insert("游戏卡顿风险评估：\(stutterRisk)（参考 GPU 稳定性、热状态与 CPU 探针降速）", at: 0)
            }

            let comparison = self.calculateComparison(
                cpu: cpuResult.totalScore,
                gpu: gpuResult.score,
                memory: memoryResult.totalScore,
                storage: storageResult.totalScore
            )

            let result = ComprehensiveBenchmarkResult(
                date: Date(),
                deviceModel: deviceModel,
                deviceName: deviceName,
                lowPowerModeEnabled: lowPowerMode,
                thermalStateStart: thermalStart,
                thermalStateEnd: thermalEnd,
                stutterRisk: stutterRisk,
                cpuProbeStartOpsPerSec: cpuProbeStart,
                cpuProbeEndOpsPerSec: cpuProbeEnd,
                cpuSpeedDropPercent: cpuDropPercent,
                cpuResult: cpuResult,
                gpuResult: gpuResult,
                memoryResult: memoryResult,
                storageResult: storageResult,
                overallScore: overallScore,
                overallGrade: overallGrade,
                testDuration: elapsed,
                performanceLevel: performanceLevel,
                recommendations: recommendations,
                comparisonWithAverage: comparison
            )

            await MainActor.run {
                self.historyManager.saveResult(
                    cpuScore: cpuResult.totalScore,
                    gpuScore: gpuResult.score,
                    memoryScore: memoryResult.totalScore,
                    storageScore: storageResult.totalScore,
                    totalScore: overallScore,
                    grade: overallGrade,
                    testType: (type == .full) ? "full" : "quick",
                    testDuration: elapsed,
                    details: result.description
                )

                self.currentResult = result
                self.isRunning = false
                self.currentPhase = ""
            }
        }
    }

    private func runGPUBenchmark() -> BenchmarkScore {
        guard device != nil else {
            return BenchmarkScore(averageFPS: 0, minFPS: 0, maxFPS: 0, frameCount: 0, totalTime: 0, score: 0, stability: 0)
        }

        let simpleBenchmark = SimpleGPUBenchmark()
        return simpleBenchmark.runBenchmark()
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

    private func evaluateStutterRisk(
        gpuStability: Double,
        thermalEndState: ProcessInfo.ThermalState,
        lowPowerMode: Bool,
        cpuDropPercent: Double
    ) -> String {
        if lowPowerMode {
            return "高"
        }

        if cpuDropPercent >= 25 {
            return "高"
        }

        if cpuDropPercent >= 15 {
            return "中"
        }

        switch thermalEndState {
        case .critical:
            return "高"
        case .serious:
            return gpuStability >= 90 ? "中" : "高"
        case .fair:
            return gpuStability >= 85 ? "低" : "中"
        case .nominal:
            return gpuStability >= 80 ? "低" : "中"
        @unknown default:
            return "中"
        }
    }

    // MARK: - Calculate Overall Score
    private func calculateOverallScore(cpu: Int, gpu: Int, memory: Int, storage: Int) -> Int {
        // Weighted scoring:
        // CPU: 30%
        // GPU: 35%
        // Memory: 20%
        // Storage: 15%
        return Int(
            Double(cpu) * 0.30 +
            Double(gpu) * 0.35 +
            Double(memory) * 0.20 +
            Double(storage) * 0.15
        )
    }

    // MARK: - Calculate Grade
    private func calculateGrade(score: Int) -> String {
        switch score {
        case 0..<3000: return "D"
        case 3000..<6000: return "C"
        case 6000..<10000: return "B"
        case 10000..<15000: return "A"
        case 15000...Int.max: return "S"
        default: return "D"
        }
    }

    // MARK: - Generate Recommendations
    private func generateRecommendations(
        cpu: CPUBenchmarkResult,
        gpu: BenchmarkScore,
        memory: MemoryBenchmarkResult,
        storage: StorageBenchmarkResult
    ) -> [String] {
        var recommendations: [String] = []

        // CPU recommendations
        if cpu.totalScore < 5000 {
            recommendations.append("CPU 性能较低，建议关闭后台应用刷新以提高响应速度")
        } else if cpu.totalScore > 15000 {
            recommendations.append("CPU 性能优异，可以轻松运行所有应用")
        }

        // GPU recommendations
        if gpu.score < 5000 {
            recommendations.append("GPU 性能一般，建议降低游戏画质以获得更好体验")
        } else if gpu.score > 12000 {
            recommendations.append("GPU 性能出色，可以开启最高画质设置")
        }

        // Memory recommendations
        if memory.totalScore < 5000 {
            recommendations.append("内存性能较低，建议定期清理后台应用")
        }

        // Storage recommendations
        if storage.totalScore < 5000 {
            recommendations.append("存储速度较慢，建议定期清理设备以维持性能")
        }

        // Stability recommendations
        if gpu.stability < 80 {
            recommendations.append("GPU 稳定性较低，建议检查设备散热情况")
        }

        if recommendations.isEmpty {
            recommendations.append("您的设备各项性能表现均衡，状态良好")
        }

        return recommendations
    }

    // MARK: - Calculate Comparison
    private func calculateComparison(cpu: Int, gpu: Int, memory: Int, storage: Int) -> ScoreComparison {
        // These are approximate percentile calculations based on typical device scores
        let cpuPercentile = min(Double(cpu) / 200.0, 100.0)
        let gpuPercentile = min(Double(gpu) / 180.0, 100.0)
        let memoryPercentile = min(Double(memory) / 150.0, 100.0)
        let storagePercentile = min(Double(storage) / 120.0, 100.0)

        return ScoreComparison(
            cpuPercentile: cpuPercentile,
            gpuPercentile: gpuPercentile,
            memoryPercentile: memoryPercentile,
            storagePercentile: storagePercentile
        )
    }

    // MARK: - Helper
    private func getDeviceModel() -> String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    func cancelBenchmark() {
        runningTask?.cancel()
        runningTask = nil

        isRunning = false
        currentPhase = ""
        progress = 0

        isSustainedRunning = false
        sustainedPhase = ""
        sustainedProgress = 0
    }
}
