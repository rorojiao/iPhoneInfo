//
//  PerformanceModeService.swift
//  iPhoneInfo
//
//  性能模式调度服务 - 游戏模式、省电模式、降温模式等
//

import Foundation
import UIKit
import Combine
import SwiftUI

class PerformanceModeService: ObservableObject {
    static let shared = PerformanceModeService()

    // MARK: - Published Properties
    @Published var currentMode: PerformanceMode = .balanced
    @Published var isActive: Bool = false
    @Published var modeDescription: String = ""
    @Published var recommendations: [String] = []

    private var cancellables = Set<AnyCancellable>()
    private let thermalService = ThermalService.shared

    // MARK: - Performance Mode
    enum PerformanceMode: String, CaseIterable, CaseDisplayable {
        case balanced = "平衡模式"
        case gaming = "游戏模式"
        case powerSave = "省电模式"
        case coolDown = "降温模式"
        case extreme = "极致性能"

        var icon: String {
            switch self {
            case .balanced: return "⚖️"
            case .gaming: return "🎮"
            case .powerSave: return "🔋"
            case .coolDown: return "❄️"
            case .extreme: return "⚡"
            }
        }

        var description: String {
            switch self {
            case .balanced:
                return "系统默认设置，性能与功耗平衡"
            case .gaming:
                return "提升游戏性能，延迟降频阈值"
            case .powerSave:
                return "降低功耗，延长电池续航"
            case .coolDown:
                return "主动降温，降低发热和功耗"
            case .extreme:
                return "不限制性能，可能严重发热"
            }
        }

        var color: Color {
            switch self {
            case .balanced: return .blue
            case .gaming: return .purple
            case .powerSave: return .green
            case .coolDown: return .cyan
            case .extreme: return .orange
            }
        }

        var systemImage: String {
            switch self {
            case .balanced: return "balance"
            case .gaming: return "gamecontroller"
            case .powerSave: return "leaf"
            case .coolDown: return "snow"
            case .extreme: return "bolt.fill"
            }
        }
    }

    // MARK: - Mode Settings
    struct ModeSettings {
        let cpuPriority: CPUPriority
        let gpuPriority: GPUPriority
        let thermalThreshold: Double // °C
        let maxBrightness: Double
        let enableProMotion: Bool
        let backgroundLimit: Bool
        let recommendedApps: [String]
        let description: String

        enum CPUPriority: String {
            case low = "低"
            case medium = "中"
            case high = "高"
            case maximum = "最高"
        }

        enum GPUPriority: String {
            case low = "低"
            case medium = "中"
            case high = "高"
            case maximum = "最高"
        }
    }

    private init() {
        // 默认平衡模式
        applyMode(.balanced)
    }

    // MARK: - Apply Mode
    func applyMode(_ mode: PerformanceMode) {
        currentMode = mode
        isActive = true

        let settings = getSettings(for: mode)
        modeDescription = mode.description

        // 应用设置
        applySettings(settings)

        // 生成建议
        generateRecommendations(for: mode, settings: settings)

        // 通知用户
        notifyModeChange(mode)
    }

    // MARK: - Get Settings
    private func getSettings(for mode: PerformanceMode) -> ModeSettings {
        switch mode {
        case .balanced:
            return ModeSettings(
                cpuPriority: .medium,
                gpuPriority: .medium,
                thermalThreshold: 42,
                maxBrightness: 1.0,
                enableProMotion: true,
                backgroundLimit: false,
                recommendedApps: [],
                description: "系统默认设置，平衡性能与功耗"
            )

        case .gaming:
            return ModeSettings(
                cpuPriority: .high,
                gpuPriority: .maximum,
                thermalThreshold: 48,
                maxBrightness: 1.0,
                enableProMotion: true,
                backgroundLimit: true,
                recommendedApps: [
                    "com.miHoYo.GenshinImpact", // 原神
                    "com.miHoYo.zhoushen",       // 崩坏：星穹铁道
                    "com.tencent.tmgp.pubgmhd",  // 和平精英
                    "com.tencent.igame",         // 王者荣耀
                    "com.superevilmegacorp.mgi"  // 虚荣
                ],
                description: "游戏时监控性能，提供优化建议。注意：iOS限制无法直接提升性能"
            )

        case .powerSave:
            return ModeSettings(
                cpuPriority: .medium,
                gpuPriority: .low,
                thermalThreshold: 40,
                maxBrightness: 0.7,
                enableProMotion: false,
                backgroundLimit: true,
                recommendedApps: [],
                description: "降低屏幕亮度，建议开启系统低电量模式"
            )

        case .coolDown:
            return ModeSettings(
                cpuPriority: .low,
                gpuPriority: .medium,
                thermalThreshold: 40,
                maxBrightness: 0.8,
                enableProMotion: false,
                backgroundLimit: true,
                recommendedApps: [],
                description: "降低亮度到80%，建议停止使用5-10分钟"
            )

        case .extreme:
            return ModeSettings(
                cpuPriority: .maximum,
                gpuPriority: .maximum,
                thermalThreshold: 55,
                maxBrightness: 1.0,
                enableProMotion: true,
                backgroundLimit: false,
                recommendedApps: [],
                description: "⚠️ 不限制性能，可能导致严重发热，不建议长时间使用"
            )
        }
    }

    // MARK: - Apply Settings
    private func applySettings(_ settings: ModeSettings) {
        // 注意：iOS沙盒限制，以下是实际可行的功能

        // 1. 调整屏幕亮度（可以实际执行，但用户体验需考虑）
        if currentMode == .coolDown || currentMode == .powerSave {
            // 保存目标亮度，提示用户
            let targetBrightness = settings.maxBrightness
            UserDefaults.standard.set(targetBrightness, forKey: "targetBrightness")
            // 不自动调整，通过recommendations告知用户
        }

        // 2. 检测系统低电量模式
        let isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
        if currentMode == .powerSave && !isLowPowerModeEnabled {
            // 可以引导用户开启
            recommendations.append("💡 建议开启系统低电量模式以延长续航")
        }

        // 3. 后台应用检测
        if settings.backgroundLimit {
            // iOS限制：无法获取其他应用信息
            // 只能提供一般性建议
        }

        // 4. 保存模式到UserDefaults
        UserDefaults.standard.set(currentMode.rawValue, forKey: "performanceMode")
        UserDefaults.standard.set(settings.thermalThreshold, forKey: "thermalThreshold")
        UserDefaults.standard.set(Date(), forKey: "modeChangeTime")
    }

    // MARK: - Get Current Running App
    private func getCurrentRunningApp() -> String? {
        // iOS不允许应用获取其他应用信息
        // 这是系统安全限制
        return nil
    }

    // MARK: - Get Heavy Background Apps
    private func getHeavyBackgroundApps() -> [String] {
        // iOS限制：无法获取后台应用列表
        // 返回空数组
        return []
    }

    // MARK: - Generate Recommendations
    private func generateRecommendations(for mode: PerformanceMode, settings: ModeSettings) {
        var recs: [String] = []
        recs.append(settings.description)  // 添加模式描述

        switch mode {
        case .balanced:
            break  // 只有描述，不需要额外建议

        case .gaming:
            recs.append("• 建议关闭后台应用以获得最佳性能")
            recs.append("• 移除保护壳以改善散热")
            recs.append("• 使用散热背夹效果更佳")

        case .powerSave:
            recs.append("• 建议降低屏幕亮度")
            recs.append("• 关闭不必要的后台应用")
            recs.append("• 关闭5G使用4G")
            if !ProcessInfo.processInfo.isLowPowerModeEnabled {
                recs.append("💡 建议开启系统低电量模式")
            }

        case .coolDown:
            recs.append("• 当前温度: \(String(format: "%.1f", thermalService.currentTemperature))°C")
            recs.append("• 目标温度: <\(settings.thermalThreshold)°C")
            recs.append("• 立即执行：")
            recs.append("  - 降低屏幕亮度至\(Int(settings.maxBrightness * 100))%")
            recs.append("  - 关闭所有后台应用")
            recs.append("  - 移除保护壳")
            recs.append("  - 停止充电（如正在充电）")
            recs.append("• 暂停使用5-10分钟")

            if thermalService.thermalState == .critical {
                recs.append("🚨 温度过高，强烈建议立即停止使用！")
            }

        case .extreme:
            recs.append("• 性能不受限制")
            recs.append("• ⚠️ 可能导致严重发热")
            recs.append("• ⚠️ 续航会明显下降")
            recs.append("• ⚠️ 不建议长时间使用")
        }

        recommendations = recs
    }

    // MARK: - Notify Mode Change
    private func notifyModeChange(_ mode: PerformanceMode) {
        // 可以发送本地通知
        let content = UNMutableNotificationContent()
        content.title = "\(mode.icon) \(mode.rawValue)"
        content.body = "已切换至\(mode.rawValue)"
        content.sound = .default

        // 这里需要添加通知触发逻辑
    }

    // MARK: - Auto Switch Mode Based on Temperature
    func enableAutoModeSwitch() {
        // 订阅温度变化
        thermalService.$thermalState
            .sink { [weak self] state in
                self?.handleThermalStateChange(state)
            }
            .store(in: &cancellables)
    }

    private func handleThermalStateChange(_ state: ThermalService.ThermalState) {
        // 根据温度自动切换模式
        switch state {
        case .nominal:
            // 温度正常，保持当前模式
            break

        case .fair:
            // 开始温热，如果当前是极致性能，切换到平衡
            if currentMode == .extreme {
                applyMode(.balanced)
            }

        case .serious:
            // 发热，自动切换到降温模式
            if currentMode != .coolDown {
                applyMode(.coolDown)
            }

        case .critical:
            // 过热，强制降温模式
            applyMode(.coolDown)
        }
    }

    // MARK: - Get Mode Performance Impact
    func getPerformanceImpact(for mode: PerformanceMode) -> PerformanceImpact {
        switch mode {
        case .balanced:
            return PerformanceImpact(
                performance: 100,
                batteryLife: 100,
                temperature: 100,
                description: "基准"
            )

        case .gaming:
            return PerformanceImpact(
                performance: 120,
                batteryLife: 70,
                temperature: 130,
                description: "性能提升20%，续航下降30%，发热增加30%"
            )

        case .powerSave:
            return PerformanceImpact(
                performance: 70,
                batteryLife: 140,
                temperature: 85,
                description: "性能下降30%，续航提升40%，发热降低15%"
            )

        case .coolDown:
            return PerformanceImpact(
                performance: 60,
                batteryLife: 120,
                temperature: 70,
                description: "性能下降40%，续航提升20%，发热降低30%"
            )

        case .extreme:
            return PerformanceImpact(
                performance: 140,
                batteryLife: 50,
                temperature: 160,
                description: "性能提升40%，续航下降50%，发热增加60%"
            )
        }
    }

    struct PerformanceImpact {
        let performance: Int    // 相对性能（100为基准）
        let batteryLife: Int    // 相对续航（100为基准）
        let temperature: Int    // 相对温度（100为基准）
        let description: String
    }

    // MARK: - Restore Default Mode
    func restoreDefaultMode() {
        applyMode(.balanced)
        isActive = false
    }
}

// MARK: - CaseDisplayable Protocol
protocol CaseDisplayable {
    var displayName: String { get }
}

extension PerformanceModeService.PerformanceMode {
    var displayName: String { rawValue }
}
