//
//  DeviceModels.swift
//  iPhoneInfo
//
//  Data models for device information
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Device Information Model
struct DeviceInfo: Identifiable {
    let id = UUID()
    let name: String
    let model: String
    let systemVersion: String
    let buildNumber: String
    let deviceType: String
    let screenWidth: Int
    let screenHeight: Int
    let scale: Int
}

// MARK: - Hardware Information Model
struct HardwareInfo {
    let cpuModel: String
    let cpuCores: Int
    let gpuCores: Int
    let neuralEngineCores: Int
    let totalMemory: UInt64  // in bytes
    let totalStorage: UInt64  // in bytes
    let availableStorage: UInt64  // in bytes
    let hasLiDAR: Bool
    let hasProMotion: Bool
    let hasAlwaysOnDisplay: Bool

    var totalMemoryGB: Double {
        Double(totalMemory) / 1_073_741_824  // Convert to GB
    }

    var totalStorageGB: Double {
        // Use marketed capacity instead of actual binary GB
        return getMarketedStorageCapacity()
    }

    var availableStorageGB: Double {
        Double(availableStorage) / 1_073_741_824
    }

    var usedStorageGB: Double {
        return totalStorageGB - availableStorageGB
    }

    var storageUsagePercentage: Double {
        guard totalStorageGB > 0 else { return 0 }
        return (usedStorageGB / totalStorageGB) * 100
    }

    // Convert actual storage capacity to marketed capacity
    // Example: 477GB actual → 512GB marketed
    private func getMarketedStorageCapacity() -> Double {
        let actualGB = Double(totalStorage) / 1_073_741_824

        // Common marketed sizes and their approximate actual capacities
        let capacities: [(marketed: Double, actualRange: ClosedRange<Double>)] = [
            (64, 56.0...60.0),
            (128, 115.0...120.0),
            (256, 230.0...242.0),
            (512, 460.0...485.0),
            (1024, 930.0...980.0),
            (2048, 1900.0...2000.0)
        ]

        for (marketed, actualRange) in capacities {
            if actualRange.contains(actualGB) {
                return marketed
            }
        }

        // If no match, return actual value rounded to nearest integer
        return round(actualGB)
    }
}

// MARK: - Battery Information Model
struct BatteryInfo {
    let level: Float           // 0.0 - 1.0
    let state: UIDevice.BatteryState
    let isLowPowerModeEnabled: Bool
    let health: Int?           // Percentage (requires IOKit)
    let cycleCount: Int?       // Number of cycles (requires IOKit)
    let temperature: Double?   // Celsius (requires IOKit)

    var levelPercentage: Int {
        Int(level * 100)
    }

    var stateDescription: String {
        switch state {
        case .charging:
            return "充电中"
        case .full:
            return "已充满"
        case .unplugged:
            return "未充电"
        @unknown default:
            return "未知"
        }
    }
}

// MARK: - Display Information Model
struct DisplayInfo {
    let screenSize: Double     // inches
    let resolution: String     // "W x H"
    let ppi: Int               // pixels per inch
    let refreshRate: Double    // Hz
    let brightness: Double     // 0.0 - 1.0
    let isProMotion: Bool
    let hasHDR: Bool
    let colorDepth: Int        // bits

    var refreshRateDescription: String {
        isProMotion ? "\(Int(refreshRate))Hz ProMotion" : "\(Int(refreshRate))Hz"
    }
}

// MARK: - Camera Information Model
struct CameraInfo {
    let rearCameras: [CameraSpec]
    let frontCamera: CameraSpec
    let supportsProRAW: Bool
    let supportsProRes: Bool
    let maxVideoResolution: String

    var rearCameraDescription: String {
        rearCameras.map { "\($0.megapixels)MP \($0.type)" }.joined(separator: " | ")
    }
}

struct CameraSpec {
    let megapixels: Int
    let type: String          // "主摄", "超广角", "长焦"
    let aperture: String      // "f/1.78"
    let opticalZoom: Double?  // nil for non-zoom lenses

    var description: String {
        var desc = "\(megapixels)MP \(type) \(aperture)"
        if let zoom = opticalZoom {
            desc += " \(Int(zoom))x"
        }
        return desc
    }
}

// MARK: - Network Information Model
struct NetworkInfo {
    let carrierName: String?
    let networkType: String?   // "5G", "4G", "LTE", etc.
    let signalStrength: Int?   // 0-4 bars
    let wifiSSID: String?
    let wifiBSSID: String?
    let wifiRSSI: Int?         // signal strength in dBm
    let isConnectedToVPN: Bool

    var cellularDescription: String {
        guard let carrier = carrierName else {
            return "无SIM卡"
        }
        let type = networkType ?? "未知"
        return "\(carrier) - \(type)"
    }

    var wifiDescription: String {
        guard let ssid = wifiSSID else {
            return "未连接"
        }
        return ssid
    }
}

// MARK: - System Information Model
struct SystemInfo {
    let iOSVersion: String
    let buildNumber: String
    let kernelVersion: String
    let bootTime: Date?
    let uptime: TimeInterval
    let isJailbroken: Bool
    let deviceLanguage: String
    let timezone: String

    var uptimeDescription: String {
        let days = Int(uptime) / 86400
        let hours = (Int(uptime) % 86400) / 3600
        let minutes = (Int(uptime) % 3600) / 60

        if days > 0 {
            return "\(days)天 \(hours)小时"
        } else if hours > 0 {
            return "\(hours)小时 \(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
}
