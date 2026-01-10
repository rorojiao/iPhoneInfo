//
//  BenchmarkCoordinator.swift
//  iPhoneInfo
//
//  Comprehensive benchmark coordination and scoring system
//

import Foundation
import Combine
import Metal

// MARK: - Comprehensive Result
struct ComprehensiveBenchmarkResult {
    let date: Date
    let deviceModel: String
    let deviceName: String

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

    @Published var isRunning = false
    @Published var progress: Double = 0
    @Published var currentPhase: String = ""
    @Published var currentResult: ComprehensiveBenchmarkResult?

    private let cpuBenchmark = CPUBenchmark()
    private let memoryBenchmark = MemoryBenchmark()
    private let storageBenchmark = StorageBenchmark()
    private let historyManager = BenchmarkHistoryManager.shared

    private let device: MTLDevice?

    private init() {
        self.device = MTLCreateSystemDefaultDevice()
    }

    // MARK: - Run Comprehensive Benchmark
    func runFullBenchmark(progressUpdate: @escaping (Double, String) -> Void) -> ComprehensiveBenchmarkResult? {
        isRunning = true
        progress = 0
        let startTime = Date()

        // Get device info
        let deviceModel = getDeviceModel()
        let deviceName = UIDevice.current.name

        // Phase 1: CPU Benchmark (25%)
        currentPhase = "正在测试 CPU 性能..."
        progressUpdate(0.0, "正在测试 CPU 性能...")
        let cpuResult = cpuBenchmark.runFullBenchmark()
        progress = 0.25
        progressUpdate(0.25, "CPU 测试完成")

        // Phase 2: GPU Benchmark (50%)
        currentPhase = "正在测试 GPU 性能..."
        progressUpdate(0.25, "正在测试 GPU 性能...")
        let gpuResult = runGPUBenchmark()
        progress = 0.5
        progressUpdate(0.5, "GPU 测试完成")

        // Phase 3: Memory Benchmark (75%)
        currentPhase = "正在测试内存性能..."
        progressUpdate(0.5, "正在测试内存性能...")
        let memoryResult = memoryBenchmark.runFullBenchmark()
        progress = 0.75
        progressUpdate(0.75, "内存测试完成")

        // Phase 4: Storage Benchmark (100%)
        currentPhase = "正在测试存储性能..."
        progressUpdate(0.75, "正在测试存储性能...")
        let storageResult = storageBenchmark.runFullBenchmark()
        progress = 1.0
        progressUpdate(1.0, "存储测试完成")

        let elapsed = Date().timeIntervalSince(startTime)

        // Calculate overall score
        let overallScore = calculateOverallScore(
            cpu: cpuResult.totalScore,
            gpu: gpuResult.score,
            memory: memoryResult.totalScore,
            storage: storageResult.totalScore
        )

        let overallGrade = calculateGrade(score: overallScore)
        let performanceLevel = PerformanceLevel.from(score: overallScore)

        // Generate recommendations
        let recommendations = generateRecommendations(
            cpu: cpuResult,
            gpu: gpuResult,
            memory: memoryResult,
            storage: storageResult
        )

        // Calculate comparison
        let comparison = calculateComparison(
            cpu: cpuResult.totalScore,
            gpu: gpuResult.score,
            memory: memoryResult.totalScore,
            storage: storageResult.totalScore
        )

        // Create result
        let result = ComprehensiveBenchmarkResult(
            date: Date(),
            deviceModel: deviceModel,
            deviceName: deviceName,
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

        // Save to history
        historyManager.saveResult(
            cpuScore: cpuResult.totalScore,
            gpuScore: gpuResult.score,
            memoryScore: memoryResult.totalScore,
            storageScore: storageResult.totalScore,
            totalScore: overallScore,
            grade: overallGrade,
            testType: "full",
            testDuration: elapsed,
            details: result.description
        )

        currentResult = result
        isRunning = false
        currentPhase = ""

        return result
    }

    // MARK: - Run Quick Benchmark
    func runQuickBenchmark(progressUpdate: @escaping (Double, String) -> Void) -> ComprehensiveBenchmarkResult? {
        isRunning = true
        progress = 0
        let startTime = Date()

        let deviceModel = getDeviceModel()
        let deviceName = UIDevice.current.name

        // CPU Quick Test
        currentPhase = "正在测试 CPU 性能..."
        progressUpdate(0.0, "正在测试 CPU 性能...")
        let cpuResult = cpuBenchmark.runQuickTest()
        progress = 0.33

        // GPU Quick Test (simplified)
        currentPhase = "正在测试 GPU 性能..."
        progressUpdate(0.33, "正在测试 GPU 性能...")
        let gpuResult = runGPUBenchmark()
        progress = 0.66

        // Memory Quick Test
        currentPhase = "正在测试内存性能..."
        progressUpdate(0.66, "正在测试内存性能...")
        let memoryResult = memoryBenchmark.runQuickTest()
        progress = 1.0

        // Use simplified storage results
        let storageResult = StorageBenchmarkResult(
            sequentialReadSpeed: memoryResult.sequentialReadSpeed / 2,
            sequentialWriteSpeed: memoryResult.sequentialWriteSpeed / 2,
            randomReadSpeed: memoryResult.sequentialReadSpeed / 4,
            randomWriteSpeed: memoryResult.sequentialWriteSpeed / 4,
            smallFileRW: memoryResult.sequentialReadSpeed / 3,
            totalScore: memoryResult.totalScore / 2,
            testDuration: 0
        )

        let elapsed = Date().timeIntervalSince(startTime)

        let overallScore = calculateOverallScore(
            cpu: cpuResult.totalScore,
            gpu: gpuResult.score,
            memory: memoryResult.totalScore,
            storage: storageResult.totalScore
        )

        let overallGrade = calculateGrade(score: overallScore)
        let performanceLevel = PerformanceLevel.from(score: overallScore)
        let recommendations = generateRecommendations(
            cpu: cpuResult,
            gpu: gpuResult,
            memory: memoryResult,
            storage: storageResult
        )
        let comparison = calculateComparison(
            cpu: cpuResult.totalScore,
            gpu: gpuResult.score,
            memory: memoryResult.totalScore,
            storage: storageResult.totalScore
        )

        let result = ComprehensiveBenchmarkResult(
            date: Date(),
            deviceModel: deviceModel,
            deviceName: deviceName,
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

        historyManager.saveResult(
            cpuScore: cpuResult.totalScore,
            gpuScore: gpuResult.score,
            memoryScore: memoryResult.totalScore,
            storageScore: storageResult.totalScore,
            totalScore: overallScore,
            grade: overallGrade,
            testType: "quick",
            testDuration: elapsed,
            details: result.description
        )

        currentResult = result
        isRunning = false
        currentPhase = ""

        return result
    }

    // MARK: - GPU Benchmark
    private func runGPUBenchmark() -> BenchmarkScore {
        guard let device = device else {
            return BenchmarkScore(averageFPS: 0, minFPS: 0, maxFPS: 0, frameCount: 0, totalTime: 0, score: 0, stability: 0)
        }

        let simpleBenchmark = SimpleGPUBenchmark()
        return simpleBenchmark.runBenchmark()
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

    // MARK: - Cancel Benchmark
    func cancelBenchmark() {
        isRunning = false
        currentPhase = ""
        progress = 0
    }
}
