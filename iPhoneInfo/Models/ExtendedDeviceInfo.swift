//
//  ExtendedDeviceInfo.swift
//  iPhoneInfo
//
//  Extended device information models for manufacturer details
//

import Foundation

// MARK: - Extended Device Information
struct ExtendedDeviceInfo {
    // Basic Info
    let deviceName: String
    let deviceModel: String          // e.g., "iPhone17,2"
    let deviceType: String           // e.g., "iPhone 16 Plus"
    let marketingName: String        // e.g., "iPhone 16 Plus 256GB 黑色"

    // Manufacturing Info
    let manufacturingDate: Date?
    let productionWeek: Int?
    let productionYear: Int?
    let factoryCode: String?

    // Serial Number Info
    let serialNumber: String?
    let activationLockStatus: Bool
    let warrantyStatus: WarrantyStatus
    let appleCareStatus: Bool

    // Color and Capacity
    let deviceColor: String
    let storageCapacity: String     // e.g., "256GB"
    let regionCode: String
    let modelNumber: String?        // e.g., "A2890"

    // Battery Details
    let batteryDesignCapacity: Int?     // mAh
    let batteryCurrentCapacity: Int?    // mAh
    let batteryCycleCount: Int?
    let batteryHealth: Int?             // percentage
    let batteryTemperature: Double?     // celsius

    // Screen Details
    let screenManufacturer: String?
    let screenModel: String?
    let screenSerialNumber: String?
    let brightness: Int?                // nits
    let contrastRatio: String?
    let HDRSupport: Bool
    let DolbyVision: Bool
    let TrueTone: Bool
    let P3WideColor: Bool

    // Network Info
    let wifiAddress: String?
    let bluetoothAddress: String?
    let carrierSettingsVersion: String?
    let imei: String?
    let meid: String?
    let iccid: String?
    let networkType: String?

    // Software Info
    let iosVersion: String
    let buildVersion: String
    let activationTime: Date?
    let timeZone: String

    // Security Info
    let jailbroken: Bool
    let developerMode: Bool
    let secureEnclaveVersion: String?
}

// MARK: - Warranty Status
enum WarrantyStatus {
    case valid
    case expired
    case unknown
    case replaced

    var description: String {
        switch self {
        case .valid: return "在保修期内"
        case .expired: return "已过保"
        case .unknown: return "未知"
        case .replaced: return "已更换"
        }
    }
}

// MARK: - Battery Health Info
struct BatteryHealthInfo {
    let designCapacity: Int         // mAh
    let currentCapacity: Int         // mAh
    let cycleCount: Int
    let healthPercentage: Int
    let temperature: Double?         // Celsius
    let voltage: Double?             // V
    let isCharging: Bool
    let chargeTimeRemaining: Int?    // minutes
    let isOptimized: Bool

    var healthStatus: String {
        switch healthPercentage {
        case 95...100: return "极佳"
        case 85...94: return "良好"
        case 75...84: return "正常"
        case 60...74: return "一般"
        case 40...59: return "较差"
        case 25...39: return "差"
        case 10...24: return "很差"
        default: return "需要更换"
        }
    }

    var healthColor: String {
        switch healthPercentage {
        case 80...100: return "green"
        case 60...79: return "orange"
        default: return "red"
        }
    }
}

// MARK: - Screen Details
struct ScreenDetails {
    let manufacturer: String         // e.g., "Samsung", "LG"
    let panelModel: String?
    let panelType: String            // e.g., "OLED", "LCD"
    let productionWeek: Int?
    let productionYear: Int?
    let maxBrightness: Int           // nits
    let typicalBrightness: Int       // nits
    let minBrightness: Int           // nits
    let contrastRatio: String        // e.g., "2000000:1"
    let hasHDR: Bool
    let hasDolbyVision: Bool
    let hasHLG: Bool
    let hasTrueTone: Bool
    let hasP3WideColor: Bool
    let colorGamut: String           // e.g., "P3"
    let colorDepth: Int              // bits
    let refreshRate: Int             // Hz
    let hasProMotion: Bool
    touchSampleRate: Int?            // Hz

    var description: String {
        var desc = "\(panelType) 面板"
        if let mfr = manufacturer {
            desc += " by \(mfr)"
        }
        desc += ", \(refreshRate)Hz"
        if hasProMotion {
            desc += " ProMotion"
        }
        return desc
    }
}

// MARK: - Camera Info
struct CameraInfo {
    let rearCameras: [CameraSpec]
    let frontCamera: CameraSpec
    let rearCameraModuleSerial: String?
    let frontCameraModuleSerial: String?
    let supportsProRAW: Bool
    let supportsProRes: Bool
    let maxVideoResolution: String
    let maxVideoFrameRate: Int
    let maxPhotoResolution: String
    let sensorShiftOIS: Bool
    let nightMode: Bool
    let deepFusion: Bool
    let smartHDR: Int
}

struct CameraSpec {
    let megapixels: Int
    let type: String          // "主摄", "超广角", "长焦", "潜望式长焦"
    let aperture: String      // "f/1.78"
    let sensorSize: String?   // e.g., "1/1.28\"", "1/1.7\""
    let opticalZoom: Double?  // nil for non-zoom lenses
    let digitalZoom: Int?     // maximum digital zoom
    let ois: Bool            // optical image stabilization
    let manufacturer: String?  // "Sony", "Samsung"
    let sensorModel: String?

    var description: String {
        var desc = "\(megapixels)MP \(type)"
        desc += " \(aperture)"
        if let size = sensorSize {
            desc += " \(size)"
        }
        if ois {
            desc += " OIS"
        }
        return desc
    }
}

// MARK: - Production Info
struct ProductionInfo {
    let factoryLocation: String?     // e.g., "China", "India", "Brazil"
    let factoryCode: String?         // e.g., "F", "G", "D"
    let productionYear: Int?
    let productionWeek: Int?
    let productionLine: String?
    let shift: String?

    var description: String {
        var desc = ""
        if let year = productionYear {
            desc += "\(year)年"
        }
        if let week = productionWeek {
            desc += "第\(week)周"
        }
        if let location = factoryLocation {
            desc += " \(location)"
        }
        return desc
    }
}

// MARK: - Security Info
struct SecurityInfo {
    let bootNonce: String?
    let generator: String?
    let sepVersion: String?
    let secureEnclaveVersion: String?
    let basebandVersion: String?
    let basebandChipset: String?
    let isJailbroken: Bool
    let jailbreakMethod: String?
    let developerModeEnabled: Bool
    let hasPassedSecurityCheck: Bool
    let integrityCheckPassed: Bool
}

// MARK: - Activation Info
struct ActivationInfo {
    let activationDate: Date?
    let activationTime: Date?
    let initialActivationCountry: String?
    let activationLockEnabled: Bool
    let findMyiPhoneEnabled: Bool
    let icloudAccountActive: Bool
    let appleID: String?

    var daysSinceActivation: Int? {
        guard let date = activationDate else { return nil }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day
    }
}

// MARK: - Network Info Extended
struct ExtendedNetworkInfo {
    let wifiAddress: String?
    let bluetoothAddress: String?
    let imei: String?
    let meid: String?
    let iccid: String?              // SIM card number
    let carrierName: String?
    let carrierCountry: String?
    let carrierSettingsVersion: String?
    let networkCode: String?         // MCC+MNC
    let signalStrength: Int?         // 0-4 bars or dBm
    let dataNetworkType: String?     // "5G", "4G", "LTE"
    let supports5G: Bool
    let supportsVoLTE: Bool
    let supportsWiFiCalling: Bool
    let vpnConnected: Bool
}
