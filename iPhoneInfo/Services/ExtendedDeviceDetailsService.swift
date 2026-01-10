//
//  ExtendedDeviceDetailsService.swift
//  iPhoneInfo
//
//  Service for retrieving detailed manufacturer and device information
//

import Foundation
import UIKit
import Darwin

class ExtendedDeviceDetailsService {
    static let shared = ExtendedDeviceDetailsService()

    private init() {}

    // MARK: - Get Extended Device Info
    func getExtendedDeviceInfo() -> ExtendedDeviceInfo {
        let model = getDeviceModel()
        let deviceType = mapModelToDeviceName(model)
        let serialInfo = parseSerialNumber(getSerialNumber())

        return ExtendedDeviceInfo(
            deviceName: UIDevice.current.name,
            deviceModel: model,
            deviceType: deviceType,
            marketingName: getMarketingName(deviceType: deviceType, storage: getStorageSize(), color: getDeviceColor()),
            manufacturingDate: serialInfo.manufacturingDate,
            productionWeek: serialInfo.week,
            productionYear: serialInfo.year,
            factoryCode: serialInfo.factoryCode,
            serialNumber: getSerialNumber(),
            activationLockStatus: false, // Can't detect without network
            warrantyStatus: estimateWarrantyStatus(from: serialInfo),
            appleCareStatus: false,
            deviceColor: getDeviceColor(),
            storageCapacity: getStorageSize(),
            regionCode: serialInfo.region,
            modelNumber: getModelNumber(),
            batteryDesignCapacity: getBatteryDesignCapacity(for: model),
            batteryCurrentCapacity: nil,
            batteryCycleCount: nil,
            batteryHealth: nil,
            batteryTemperature: nil,
            screenManufacturer: getScreenManufacturer(),
            screenModel: nil,
            screenSerialNumber: nil,
            brightness: getScreenBrightnessNits(for: model),
            contrastRatio: getContrastRatio(for: model),
            HDRSupport: true,
            DolbyVision: supportsDolbyVision(for: model),
            TrueTone: true,
            P3WideColor: true,
            wifiAddress: getWiFiAddress(),
            bluetoothAddress: getBluetoothAddress(),
            carrierSettingsVersion: nil,
            imei: getIMEI(),
            meid: getMEID(),
            iccid: getICCID(),
            networkType: getNetworkType(),
            iosVersion: UIDevice.current.systemVersion,
            buildVersion: getBuildNumber(),
            activationTime: nil,
            timeZone: TimeZone.current.identifier,
            jailbroken: checkJailbreak(),
            developerMode: isDeveloperModeEnabled(),
            secureEnclaveVersion: nil
        )
    }

    // MARK: - Serial Number Parsing
    private func parseSerialNumber(_ serial: String) -> (year: Int?, week: Int?, factoryCode: String?, region: String?, manufacturingDate: Date?) {
        guard serial.count >= 12 else {
            return (nil, nil, nil, nil, nil)
        }

        // Apple serial number format (post-2010): XXYYWWXXX
        // XX = Factory location
        // YY = Year code
        // WW = Week
        // XXX = Unique identifier
        // Last character = Color, storage, region

        let factory = String(serial.prefix(2))
        let yearCode = String(serial.dropFirst(2).prefix(2))
        let week = String(serial.dropFirst(4).prefix(2))
        let region = String(serial.suffix(1))

        // Decode year (simplified - Apple uses a semi-random encoding)
        let currentYear = Calendar.current.component(.year, from: Date())
        let year: Int? = decodeYear(yearCode, currentYear: currentYear)
        let weekNum = Int(week)

        // Factory code mapping
        let factoryMap: [String: String] = [
            "DL": "China", "DN": "China", "C3": "China", "C7": "China", "DQ": "China",
            "F1": "India", "F2": "India", "G1": "India", "G6": "India", "VK": "India",
            "C8": "Brazil", "C9": "Brazil", "H1": "Brazil", "HC": "Brazil"
        ]

        let factoryLocation = factoryMap[factory] ?? factory

        // Region code mapping
        let regionMap: [String: String] = [
            "F": "USA/Canada", "C": "China", "P": "Pacific", "Y": "Europe",
            "D": "Germany", "J": "Japan", "K": "Korea", "B": "UK/Ireland",
            "N": "Latin America", "T": "Italy"
        ]

        let regionName = regionMap[region] ?? region

        // Create manufacturing date
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.weekOfYear = weekNum
        dateComponents.weekday = 1
        let manufacturingDate = Calendar.current.date(from: dateComponents)

        return (year, weekNum, factoryLocation, regionName, manufacturingDate)
    }

    private func decodeYear(_ code: String, currentYear: Int) -> Int? {
        // Simplified year decoding (actual encoding is more complex)
        let yearMap: [String: Int] = [
            "C0": 2010, "C1": 2011, "C2": 2012, "C3": 2013, "C4": 2014,
            "C5": 2015, "C6": 2016, "C7": 2017, "C8": 2018, "C9": 2019,
            "D0": 2020, "D1": 2021, "D2": 2022, "D3": 2023, "D4": 2024,
            "D5": 2025, "D6": 2026, "D7": 2027, "D8": 2028, "D9": 2029,
            "F0": 2030, "F1": 2031, "F2": 2032, "F3": 2033, "F4": 2034
        ]

        return yearMap[code]
    }

    // MARK: - Device Information
    private func getDeviceModel() -> String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    private func mapModelToDeviceName(_ model: String) -> String {
        let modelMap: [String: String] = [
            "iPhone17,1": "iPhone 16",
            "iPhone17,2": "iPhone 16 Plus",
            "iPhone17,3": "iPhone 16 Pro",
            "iPhone17,4": "iPhone 16 Pro Max",
            "iPhone16,1": "iPhone 15",
            "iPhone16,2": "iPhone 15 Plus",
            "iPhone16,3": "iPhone 15 Pro",
            "iPhone16,4": "iPhone 15 Pro Max",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus"
        ]
        return modelMap[model] ?? model
    }

    private func getMarketingName(deviceType: String, storage: String, color: String) -> String {
        return "\(deviceType) \(storage) \(color)"
    }

    private func getSerialNumber() -> String {
        var size: Int = 0
        sysctlbyname("hw.serial", nil, &size, nil, 0)
        if size > 0 {
            var serial = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.serial", &serial, &size, nil, 0)
            return String(cString: serial)
        }
        return "Unknown"
    }

    private func getModelNumber() -> String? {
        // Try to get model number from system
        // Model number is like A2890, A2891, etc.
        // This is not directly accessible via public API
        // Return based on device model
        let model = getDeviceModel()
        let modelNumbers: [String: String] = [
            "iPhone17,1": "A2890",
            "iPhone17,2": "A2891",
            "iPhone17,3": "A2892",
            "iPhone17,4": "A2893",
            "iPhone16,1": "A2848",
            "iPhone16,2": "A2849",
            "iPhone16,3": "A2847",
            "iPhone16,4": "A2846"
        ]
        return modelNumbers[model]
    }

    // MARK: - Storage and Color
    private func getStorageSize() -> String {
        // Get actual storage and convert to marketed size
        let (total, _) = getStorageCapacity()
        let gb = Double(total) / 1_073_741_824

        switch gb {
        case 56...65: return "64GB"
        case 115...125: return "128GB"
        case 230...250: return "256GB"
        case 460...500: return "512GB"
        case 930...1000: return "1TB"
        case 1900...2100: return "2TB"
        default: return "\(Int(gb))GB"
        }
    }

    private func getDeviceColor() -> String {
        // Color detection is not possible via API
        // Return based on common colors
        return "黑色钛金属" // Default or could be user-selectable
    }

    private func getStorageCapacity() -> (total: UInt64, available: UInt64) {
        var total: UInt64 = 0
        var available: UInt64 = 0

        var stats = statfs()
        let path = NSHomeDirectory()

        if path.withCString({ cString in statfs(cString, &stats) }) == 0 {
            total = UInt64(stats.f_blocks) * UInt64(stats.f_bsize)
            available = UInt64(stats.f_bavail) * UInt64(stats.f_bsize)
        }

        return (total, available)
    }

    // MARK: - Battery Info
    private func getBatteryDesignCapacity(for model: String) -> Int? {
        // Design capacity in mAh for various models
        let capacities: [String: Int] = [
            "iPhone17,1": 3561,    // iPhone 16
            "iPhone17,2": 4007,    // iPhone 16 Plus
            "iPhone17,3": 3582,    // iPhone 16 Pro
            "iPhone17,4": 4676,    // iPhone 16 Pro Max
            "iPhone16,1": 3349,    // iPhone 15
            "iPhone16,2": 4383,    // iPhone 15 Plus
            "iPhone16,3": 3274,    // iPhone 15 Pro
            "iPhone16,4": 4422,    // iPhone 15 Pro Max
            "iPhone15,2": 3200,    // iPhone 14 Pro
            "iPhone15,3": 4323,    // iPhone 14 Pro Max
            "iPhone14,7": 3279,    // iPhone 14
            "iPhone14,8": 4325     // iPhone 14 Plus
        ]
        return capacities[model]
    }

    // MARK: - Screen Info
    private func getScreenManufacturer() -> String? {
        // Cannot detect screen manufacturer via API
        // Modern iPhones use Samsung, LG, or BOE displays
        return "Samsung/LG/BOE"
    }

    private func getScreenBrightnessNits(for model: String) -> Int? {
        // Typical max brightness in nits
        if model.contains("Pro") {
            return 2000 // Pro models have higher peak brightness
        }
        return 1000 // Standard models
    }

    private func getContrastRatio(for model: String) -> String {
        if model.contains("Pro") || model.hasPrefix("iPhone15,") || model.hasPrefix("iPhone16,") || model.hasPrefix("iPhone17,") {
            return "2000000:1" // OLED
        }
        return "1400:1" // LCD
    }

    private func supportsDolbyVision(for model: String) -> Bool {
        return model.hasPrefix("iPhone12,") || model.hasPrefix("iPhone13,") ||
               model.hasPrefix("iPhone14,") || model.hasPrefix("iPhone15,") ||
               model.hasPrefix("iPhone16,") || model.hasPrefix("iPhone17,")
    }

    // MARK: - Network Info
    private func getWiFiAddress() -> String? {
        var size: Int = 0
        sysctlbyname("net.link.0.80211", nil, &size, nil, 0)
        // WiFi address retrieval is complex, returning nil for now
        return nil
    }

    private func getBluetoothAddress() -> String? {
        // Not directly accessible
        return nil
    }

    private func getIMEI() -> String? {
        // Not directly accessible via public API
        return nil
    }

    private func getMEID() -> String? {
        // Not directly accessible via public API
        return nil
    }

    private func getICCID() -> String? {
        // Requires Core Telephony
        return nil
    }

    private func getNetworkType() -> String? {
        // Requires Core Telephony
        return nil
    }

    // MARK: - Build Info
    private func getBuildNumber() -> String {
        var size = 0
        sysctlbyname("kern.osversion", nil, &size, nil, 0)
        var version = [CChar](repeating: 0, count: size)
        sysctlbyname("kern.osversion", &version, &size, nil, 0)
        return String(cString: version)
    }

    // MARK: - Warranty
    private func estimateWarrantyStatus(from serialInfo: (year: Int?, week: Int?, factoryCode: String?, region: String?, manufacturingDate: Date?)) -> WarrantyStatus {
        guard let manufactureDate = serialInfo.manufacturingDate else {
            return .unknown
        }

        // iPhones typically have 1 year warranty
        let warrantyPeriod: TimeInterval = 365 * 24 * 60 * 60
        let expirationDate = manufactureDate.addingTimeInterval(warrantyPeriod)

        if Date() > expirationDate {
            return .expired
        } else {
            return .valid
        }
    }

    // MARK: - Security
    private func checkJailbreak() -> Bool {
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/private/var/lib/apt/",
            "/bin/sh",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/jailbreak_test.txt"
        ]

        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        return false
    }

    private func isDeveloperModeEnabled() -> Bool {
        // Check for developer mode indicators
        let developerPaths = [
            "/Developer",
            "/Applications/Settings.app/Developer.plist"
        ]

        for path in developerPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        return false
    }
}
