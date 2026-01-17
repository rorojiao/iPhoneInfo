import Foundation
import SwiftUI

final class GameExperienceService: ObservableObject {
    static let shared = GameExperienceService()

    @Published var assessment = GameExperienceAssessment.empty

    private init() {}

    func update(metrics: SystemMetrics?, lastBenchmark: ComprehensiveBenchmarkResult?) {
        guard let metrics else {
            assessment = .empty
            return
        }

        let lowPowerModeEnabled = metrics.lowPowerModeEnabled
        let thermalEndState = metrics.processThermalState
        let cpuUsage = metrics.cpuUsage
        let memoryUsage = metrics.memoryUsage
        let gpuUsage = metrics.gpuUsage

        let cpuDropPercent = lastBenchmark?.cpuSpeedDropPercent

        let risk = evaluateRisk(
            lowPowerModeEnabled: lowPowerModeEnabled,
            thermalState: thermalEndState,
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            gpuUsage: gpuUsage,
            cpuDropPercent: cpuDropPercent
        )

        let reasons = buildReasons(
            lowPowerModeEnabled: lowPowerModeEnabled,
            thermalState: thermalEndState,
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            gpuUsage: gpuUsage,
            cpuDropPercent: cpuDropPercent
        )

        let advice = buildAdvice(
            risk: risk,
            lowPowerModeEnabled: lowPowerModeEnabled,
            thermalState: thermalEndState,
            cpuDropPercent: cpuDropPercent
        )

        assessment = GameExperienceAssessment(
            timestamp: metrics.timestamp,
            risk: risk,
            reasons: reasons,
            advice: advice,
            lowPowerModeEnabled: lowPowerModeEnabled,
            thermalState: describeThermalState(thermalEndState),
            cpuUsage: cpuUsage,
            gpuUsage: gpuUsage,
            memoryUsage: memoryUsage,
            cpuDropPercent: cpuDropPercent,
            wifiIP: metrics.wifiIP,
            cellularIP: metrics.cellularIP
        )
    }

    private func evaluateRisk(
        lowPowerModeEnabled: Bool,
        thermalState: ProcessInfo.ThermalState,
        cpuUsage: Double,
        memoryUsage: Double,
        gpuUsage: Double,
        cpuDropPercent: Double?
    ) -> GameRiskLevel {
        if lowPowerModeEnabled {
            return .high
        }

        if let cpuDropPercent, cpuDropPercent >= 25 {
            return .high
        }

        if thermalState == .critical {
            return .high
        }

        if thermalState == .serious {
            return .medium
        }

        if cpuUsage >= 85 || memoryUsage >= 90 || gpuUsage >= 90 {
            return .medium
        }

        if let cpuDropPercent, cpuDropPercent >= 15 {
            return .medium
        }

        return .low
    }

    private func buildReasons(
        lowPowerModeEnabled: Bool,
        thermalState: ProcessInfo.ThermalState,
        cpuUsage: Double,
        memoryUsage: Double,
        gpuUsage: Double,
        cpuDropPercent: Double?
    ) -> [String] {
        var reasons: [String] = []

        if lowPowerModeEnabled {
            reasons.append("低电量模式开启")
        }

        if thermalState != .nominal {
            reasons.append("热状态：\(describeThermalState(thermalState))")
        }

        if cpuUsage >= 85 {
            reasons.append("CPU 使用率偏高（\(Int(cpuUsage))%）")
        }

        if gpuUsage >= 90 {
            reasons.append("GPU 使用率偏高（\(Int(gpuUsage))%）")
        }

        if memoryUsage >= 90 {
            reasons.append("内存压力偏高（\(Int(memoryUsage))%）")
        }

        if let cpuDropPercent, cpuDropPercent >= 10 {
            reasons.append("CPU 探针降速估计（\(String(format: "%.1f", cpuDropPercent))%）")
        }

        if reasons.isEmpty {
            reasons.append("当前状态较稳定")
        }

        return reasons
    }

    private func buildAdvice(
        risk: GameRiskLevel,
        lowPowerModeEnabled: Bool,
        thermalState: ProcessInfo.ThermalState,
        cpuDropPercent: Double?
    ) -> String {
        if lowPowerModeEnabled {
            return "建议关闭低电量模式或充电后再进行高负载游戏"
        }

        if thermalState == .critical {
            return "建议暂停游戏降温（摘掉保护壳/降低亮度/停止充电）"
        }

        if thermalState == .serious {
            return "建议降低画质或帧率上限，避免持续高负载"
        }

        if let cpuDropPercent, cpuDropPercent >= 25 {
            return "可能已触发明显降速，建议降温后再测试或降低游戏设置"
        }

        switch risk {
        case .high:
            return "当前不建议长时间高负载游戏"
        case .medium:
            return "可游戏但建议关注温度与稳定性"
        case .low:
            return "状态良好，适合游戏"
        }
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

enum GameRiskLevel: String {
    case low = "低"
    case medium = "中"
    case high = "高"

    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}

struct GameExperienceAssessment {
    let timestamp: Date
    let risk: GameRiskLevel
    let reasons: [String]
    let advice: String

    let lowPowerModeEnabled: Bool
    let thermalState: String
    let cpuUsage: Double
    let gpuUsage: Double
    let memoryUsage: Double
    let cpuDropPercent: Double?

    let wifiIP: String?
    let cellularIP: String?

    static let empty = GameExperienceAssessment(
        timestamp: Date(),
        risk: .low,
        reasons: ["等待监控数据"],
        advice: "",
        lowPowerModeEnabled: false,
        thermalState: "未知",
        cpuUsage: 0,
        gpuUsage: 0,
        memoryUsage: 0,
        cpuDropPercent: nil,
        wifiIP: nil,
        cellularIP: nil
    )
}