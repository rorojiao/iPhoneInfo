//
//  ThermalService.swift
//  iPhoneInfo
//
//  温度监控和发热指数计算服务
//

import Foundation
import UIKit
import Combine
import SwiftUI

class ThermalService: ObservableObject {
    static let shared = ThermalService()

    // MARK: - Published Properties
    @Published var currentTemperature: Double = 0
    @Published var thermalState: ThermalState = .nominal
    @Published var heatIndex: Double = 0
    @Published var heatIndexDescription: String = "舒适"
    @Published var temperatureHistory: [TemperatureRecord] = []
    @Published var cpuUsage: Double = 0
    @Published var gpuUsage: Double = 0
    @Published var isMonitoring: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?
    private let maxHistoryCount = 60 // 保存60个记录（每秒一个，共1分钟）

    // 温度平均窗口 - 使用最近30秒的平均值
    private let averagingWindowSeconds: TimeInterval = 30
    private var temperatureBuffer: [Double] = []
    private let maxBufferSize = 30

    // MARK: - Thermal State
    enum ThermalState: String, CaseIterable {
        case nominal = "正常"
        case fair = "温热"
        case serious = "发热"
        case critical = "过热"

        var color: Color {
            switch self {
            case .nominal: return .green
            case .fair: return .yellow
            case .serious: return .orange
            case .critical: return .red
            }
        }

        var emoji: String {
            switch self {
            case .nominal: return "✅"
            case .fair: return "⚠️"
            case .serious: return "🔥"
            case .critical: return "🚨"
            }
        }
    }

    // MARK: - Temperature Record
    struct TemperatureRecord {
        let timestamp: Date
        let temperature: Double
        let thermalState: ThermalState
        let heatIndex: Double
        let cpuUsage: Double
    }

    private init() {
        loadTemperatureHistory()
    }

    // MARK: - Start/Stop Monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true

        // 每秒更新一次温度
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTemperature()
            self?.updateHeatIndex()
            self?.saveTemperatureRecord()
        }

        // 立即更新一次
        updateTemperature()
        updateHeatIndex()
    }

    func stopMonitoring() {
        isMonitoring = false
        updateTimer?.invalidate()
        updateTimer = nil
    }

    // MARK: - Update Temperature
    private func updateTemperature() {
        // 获取瞬时温度
        let instantaneousTemp = getSoCTemperature() > 0 ? getSoCTemperature() : estimateTemperature()

        // 添加到缓冲区
        temperatureBuffer.append(instantaneousTemp)
        if temperatureBuffer.count > maxBufferSize {
            temperatureBuffer.removeFirst()
        }

        // 计算平均温度（滑动窗口平均）
        let averagedTemperature = temperatureBuffer.reduce(0, +) / Double(temperatureBuffer.count)

        DispatchQueue.main.async {
            self.currentTemperature = averagedTemperature
            self.thermalState = self.getThermalState(for: averagedTemperature)
        }
    }

    // MARK: - Get SoC Temperature
    private func getSoCTemperature() -> Double {
        // 尝试通过sysctl获取温度
        var size: Int = 0
        sysctlbyname("machdep.xcpm.cpu_thermal_level", nil, &size, nil, 0)

        if size > 0 {
            var thermalLevel = UInt32(0)
            sysctlbyname("machdep.xcpm.cpu_thermal_level", &thermalLevel, &size, nil, 0)

            // thermalLevel是0-100的值，转换为温度
            // iOS thermal level: 0-25=正常, 26-50=温和, 51-75=热, 76-100=过热
            // 转换为摄氏度: 35°C (正常) 到 45°C+ (过热)
            let thermalPercent = Double(thermalLevel) / 100.0
            return 35.0 + (thermalPercent * 15.0) // 35-50°C 范围
        }

        return 0
    }

    // MARK: - Estimate Temperature
    private func estimateTemperature() -> Double {
        // 基于多个因素估算温度 - 更保守的估算
        var factors: [Double] = []

        // 1. CPU使用率 (降低影响)
        let cpu = getCPUUsage()
        // CPU对温度的影响更保守：每10%增加约0.5°C
        factors.append(cpu * 0.05)

        // 2. 是否在充电
        if UIDevice.current.batteryState == .charging {
            factors.append(2) // 充电时温度通常高2°C (降低)
        }

        // 3. 屏幕亮度 (降低影响)
        let brightness = getCurrentScreen().brightness
        factors.append(Double(brightness) * 1.5) // 最大亮度可能增加1.5°C

        // 4. 设备使用时长（估算）- 移除，影响太小

        // 基础温度 - 更合理的空闲温度
        let baseTemperature = 30.0 // 空闲时基础温度约30°C
        return baseTemperature + factors.reduce(0, +)
    }

    // MARK: - Get CPU Usage
    private func getCPUUsage() -> Double {
        var totalUsageOfCPU: Double = 0
        var threadsList: thread_act_array_t?
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
            return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadsCount)
            }
        }

        if threadsResult == KERN_SUCCESS, let threadsList = threadsList {
            for index in 0..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                    }
                }

                guard infoResult == KERN_SUCCESS else {
                    break
                }

                let threadBasicInfo = threadInfo as thread_basic_info
                if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalUsageOfCPU += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                }
            }

            vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount)))
        }

        DispatchQueue.main.async {
            self.cpuUsage = totalUsageOfCPU
        }

        return totalUsageOfCPU
    }

    // MARK: - Update 发热指数
    private func updateHeatIndex() {
        // 发热指数计算公式 (改进版)
        // 综合考虑温度、CPU占用和充电状态

        // 温度分数: 30°C=0分, 45°C=60分 (温度范围30-45)
        let tempScore = max(0, min((currentTemperature - 30) / 15 * 60, 60))

        // CPU分数: 0%=0分, 100%=30分
        let cpuScore = min(cpuUsage * 0.3, 30)

        // 充电分数
        let chargingScore: Double = {
            if UIDevice.current.batteryState == .charging {
                return 10
            } else if UIDevice.current.batteryState == .full {
                return 5
            }
            return 0
        }()

        let 总分 = tempScore + cpuScore + chargingScore
        let 指数 = min(max(总分, 0), 100)

        DispatchQueue.main.async {
            self.heatIndex = 指数
            self.heatIndexDescription = self.getHeatIndexDescription(for: 指数)
        }
    }

    // MARK: - Get 发热指数 Description
    private func getHeatIndexDescription(for index: Double) -> String {
        switch index {
        case 0..<25: return "舒适"
        case 25..<50: return "温热"
        case 50..<75: return "发热"
        case 75...100: return "过热"
        default: return "未知"
        }
    }

    // MARK: - Get Thermal State
    private func getThermalState(for temperature: Double) -> ThermalState {
        switch temperature {
        case 0..<35: return .nominal   // 正常: < 35°C
        case 35..<40: return .fair     // 温热: 35-40°C
        case 40..<45: return .serious   // 发热: 40-45°C
        case 45...100: return .critical // 过热: > 45°C
        default: return .nominal
        }
    }

    // MARK: - Save Temperature Record
    private func saveTemperatureRecord() {
        let record = TemperatureRecord(
            timestamp: Date(),
            temperature: currentTemperature,
            thermalState: thermalState,
            heatIndex: heatIndex,
            cpuUsage: cpuUsage
        )

        temperatureHistory.append(record)

        // 限制历史记录数量
        if temperatureHistory.count > maxHistoryCount {
            temperatureHistory.removeFirst(temperatureHistory.count - maxHistoryCount)
        }

        // 持久化
        persistTemperatureHistory()
    }

    // MARK: - Persist Temperature History
    private func persistTemperatureHistory() {
        // 只保存最近的记录到UserDefaults
        let records = temperatureHistory.suffix(10).map { record in
            return [
                "timestamp": record.timestamp.timeIntervalSince1970,
                "temperature": record.temperature,
                "thermalState": record.thermalState.rawValue,
                "heatIndex": record.heatIndex,
                "cpuUsage": record.cpuUsage
            ]
        }

        UserDefaults.standard.set(records, forKey: "temperatureHistory")
    }

    // MARK: - Load Temperature History
    private func loadTemperatureHistory() {
        guard let records = UserDefaults.standard.array(forKey: "temperatureHistory") as? [[String: Any]] else {
            return
        }

        temperatureHistory = records.compactMap { dict in
            guard let timestamp = dict["timestamp"] as? TimeInterval,
                  let temperature = dict["temperature"] as? Double,
                  let thermalStateString = dict["thermalState"] as? String,
                  let heatIndex = dict["heatIndex"] as? Double,
                  let cpuUsage = dict["cpuUsage"] as? Double else {
                return nil
            }

            let thermalState = ThermalState(rawValue: thermalStateString) ?? .nominal

            return TemperatureRecord(
                timestamp: Date(timeIntervalSince1970: timestamp),
                temperature: temperature,
                thermalState: thermalState,
                heatIndex: heatIndex,
                cpuUsage: cpuUsage
            )
        }
    }

    // MARK: - Get Temperature Trend
    func getTemperatureTrend() -> TemperatureTrend {
        guard temperatureHistory.count >= 5 else {
            return .stable
        }

        let recent5 = temperatureHistory.suffix(5)
        let avgFirst2 = recent5.prefix(2).map { $0.temperature }.reduce(0, +) / 2
        let avgLast2 = recent5.suffix(2).map { $0.temperature }.reduce(0, +) / 2

        let diff = avgLast2 - avgFirst2

        if diff > 2 {
            return .rising
        } else if diff < -2 {
            return .falling
        } else {
            return .stable
        }
    }

    enum TemperatureTrend {
        case rising    // 上升
        case falling   // 下降
        case stable    // 稳定

        var description: String {
            switch self {
            case .rising: return "升温中"
            case .falling: return "降温中"
            case .stable: return "稳定"
            }
        }

        var arrow: String {
            switch self {
            case .rising: return "↗️"
            case .falling: return "↘️"
            case .stable: return "→"
            }
        }
    }

    // MARK: - Predict Temperature
    func predictTemperature(minutes: Int = 10) -> (temperature: Double, confidence: String)? {
        guard temperatureHistory.count >= 10 else {
            return nil
        }

        let recent10 = Array(temperatureHistory.suffix(10))
        let temperatures = recent10.map { $0.temperature }

        // 简单线性回归预测
        let n = Double(temperatures.count)
        let indices = Array(0..<temperatures.count)
        let sumX = Double(indices.reduce(0, +))
        let sumY = temperatures.reduce(0, +)

        var sumXY = 0.0
        for (idx, temp) in zip(indices, temperatures) {
            sumXY += Double(idx) * temp
        }

        var sumX2 = 0.0
        for idx in indices {
            sumX2 += Double(idx * idx)
        }

        let slope = (n * sumXY - Double(sumX) * sumY) / (n * sumX2 - Double(sumX * sumX))
        let intercept = (sumY - slope * Double(sumX)) / n

        // 预测未来值
        let futureX = Double(temperatures.count + minutes * 60) // 每分钟60个数据点
        let predictedTemp = slope * futureX + intercept

        // 计算置信度
        var residuals: [Double] = []
        for (idx, temp) in zip(indices, temperatures) {
            let predicted = slope * Double(idx) + intercept
            residuals.append(temp - predicted)
        }
        let mse = residuals.map { $0 * $0 }.reduce(0, +) / Double(residuals.count)
        let confidence = mse < 4 ? "高" : (mse < 9 ? "中" : "低")

        return (predictedTemp, confidence)
    }

    // MARK: - Get Recommendations
    func getRecommendations() -> [String] {
        var recommendations: [String] = []

        switch thermalState {
        case .nominal:
            recommendations.append("设备温度正常，可继续使用")

        case .fair:
            recommendations.append("设备开始升温，注意散热")
            if cpuUsage > 50 {
                recommendations.append("CPU占用较高，考虑关闭后台应用")
            }

        case .serious:
            recommendations.append("⚠️ 设备发热，建议：")
            recommendations.append("• 降低屏幕亮度")
            recommendations.append("• 关闭不必要的后台应用")
            recommendations.append("• 移除保护壳以助散热")
            recommendations.append("• 暂停使用，等待降温")

            if UIDevice.current.batteryState == .charging {
                recommendations.append("• 暂停充电，温度会更高")
            }

        case .critical:
            recommendations.append("🚨 设备严重过热！")
            recommendations.append("• 立即停止使用")
            recommendations.append("• 关闭所有应用")
            recommendations.append("• 移至阴凉处")
            recommendations.append("• 取消充电（如正在充电）")
            recommendations.append("• 可能需要等待5-10分钟降温")
        }

        return recommendations
    }
}

// MARK: - Color Extension
import SwiftUI
extension Color {
    static let thermalGreen = Color(red: 52/255, green: 211/255, blue: 153/255)
    static let thermalYellow = Color(red: 255/255, green: 214/255, blue: 10/255)
    static let thermalOrange = Color(red: 255/255, green: 159/255, blue: 10/255)
    static let thermalRed = Color(red: 255/255, green: 69/255, blue: 58/255)
}
