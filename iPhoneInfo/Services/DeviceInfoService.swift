//
//  DeviceInfoService.swift
//  iPhoneInfo
//
//  Service for gathering device and system information
//

import Foundation
import UIKit

class DeviceInfoService: ObservableObject {
    static let shared = DeviceInfoService()

    @Published var deviceInfo: DeviceInfo?
    @Published var hardwareInfo: HardwareInfo?
    @Published var batteryInfo: BatteryInfo?
    @Published var displayInfo: DisplayInfo?
    @Published var networkInfo: NetworkInfo?
    @Published var systemInfo: SystemInfo?

    // Debug: Store raw values
    private(set) var rawModelString: String = ""

    private init() {
        loadAllInformation()
    }

    // MARK: - Load All Information
    func loadAllInformation() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadDeviceInfo()
            self.loadHardwareInfo()
            self.loadBatteryInfo()
            self.loadDisplayInfo()
            self.loadNetworkInfo()
            self.loadSystemInfo()
        }
    }

    // MARK: - Device Information
    private func loadDeviceInfo() {
        let device = UIDevice.current
        device.name // Ensure device is unlocked

        let rawModel = getDeviceModel()
        rawModelString = rawModel  // Store for debugging
        print("[DEBUG] Raw device model: \(rawModel)")

        let deviceType = mapModelToDeviceName(rawModel)
        print("[DEBUG] Mapped device type: \(deviceType)")

        let info = DeviceInfo(
            name: device.name,
            model: rawModel,
            systemVersion: device.systemVersion,
            buildNumber: getBuildNumber(),
            deviceType: deviceType,
            screenWidth: Int(UIScreen.main.bounds.width),
            screenHeight: Int(UIScreen.main.bounds.height),
            scale: Int(UIScreen.main.scale)
        )

        DispatchQueue.main.async {
            self.deviceInfo = info
        }
    }

    private func getDeviceModel() -> String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let model = String(cString: machine)
        print("[DEBUG] getDeviceModel returned: \(model)")
        return model
    }

    private func getBuildNumber() -> String {
        var size: Int = 0
        sysctlbyname("kern.osversion", nil, &size, nil, 0)
        var version = [CChar](repeating: 0, count: size)
        sysctlbyname("kern.osversion", &version, &size, nil, 0)
        return String(cString: version)
    }

    private func getDeviceType() -> String {
        // Use the same method as getDeviceModel() for consistency
        let model = getDeviceModel()
        let deviceType = mapModelToDeviceName(model)
        print("[DEBUG] getDeviceType - model: \(model) -> deviceType: \(deviceType)")
        return deviceType
    }

    private func mapModelToDeviceName(_ model: String) -> String {
        // Complete iPhone model mapping as of 2026
        let modelMap: [String: String] = [
            // iPhone 16 Series (2024) - 官方正确映射
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",

            // iPhone 15 Series (2023)
            "iPhone16,1": "iPhone 15",
            "iPhone16,2": "iPhone 15 Plus",
            "iPhone16,3": "iPhone 15 Pro",
            "iPhone16,4": "iPhone 15 Pro Max",

            // iPhone 14 Series (2022)
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",

            // iPhone 13 Series (2021)
            "iPhone14,5": "iPhone 13",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",

            // iPhone 12 Series (2020)
            "iPhone13,2": "iPhone 12",
            "iPhone13,1": "iPhone 12 mini",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",

            // iPhone 11 Series (2019)
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",

            // iPhone SE Series
            "iPhone14,6": "iPhone SE (3rd generation)",
            "iPhone12,8": "iPhone SE (2nd generation)",

            // iPhone XR, XS, XS Max (2018)
            "iPhone11,8": "iPhone XR",
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max",

            // iPhone X (2017)
            "iPhone10,3": "iPhone X",
            "iPhone10,6": "iPhone X",

            // iPhone 8 Series (2017)
            "iPhone10,1": "iPhone 8",
            "iPhone10,4": "iPhone 8",
            "iPhone10,2": "iPhone 8 Plus",
            "iPhone10,5": "iPhone 8 Plus",

            // iPhone 7 Series (2016)
            "iPhone9,1": "iPhone 7",
            "iPhone9,3": "iPhone 7",
            "iPhone9,2": "iPhone 7 Plus",
            "iPhone9,4": "iPhone 7 Plus",
        ]
        return modelMap[model] ?? model
    }

    // MARK: - Hardware Information
    private func loadHardwareInfo() {
        let cpuModel = getCPUModel()
        let cpuCores = ProcessInfo.processInfo.processorCount
        let totalMemory = getTotalMemory()
        let (totalStorage, availableStorage) = getStorageInfo()

        // Detect hardware capabilities
        let model = getDeviceModel()
        // LiDAR scanner available on Pro models from iPhone 12 Pro onwards
        let hasLiDAR = model == "iPhone13,4" || model == "iPhone13,3" || // iPhone 12 Pro Max, 12 Pro
                        model == "iPhone14,2" || model == "iPhone14,3" || // iPhone 13 Pro, 13 Pro Max
                        model == "iPhone14,8" || model == "iPhone14,5" || // iPhone 13 Pro (alt identifiers)
                        model == "iPhone15,2" || model == "iPhone15,3" || // iPhone 14 Pro, 14 Pro Max
                        model == "iPhone16,3" || model == "iPhone16,4" || // iPhone 15 Pro, 15 Pro Max
                        model == "iPhone17,3" || model == "iPhone17,2"    // iPhone 16 Pro, 16 Pro Max (修正)

        // ProMotion display (120Hz) on Pro models from iPhone 13 Pro onwards
        let hasProMotion = model == "iPhone14,2" || model == "iPhone14,3" || // iPhone 13 Pro
                          model == "iPhone15,2" || model == "iPhone15,3" || // iPhone 14 Pro
                          model == "iPhone16,3" || model == "iPhone16,4" || // iPhone 15 Pro
                          model == "iPhone17,3" || model == "iPhone17,2"    // iPhone 16 Pro, 16 Pro Max (修正)

        // Always-On Display from iPhone 14 Pro onwards
        let hasAlwaysOnDisplay = model == "iPhone15,2" || model == "iPhone15,3" || // iPhone 14 Pro
                                  model == "iPhone16,3" || model == "iPhone16,4" || // iPhone 15 Pro
                                  model == "iPhone17,3" || model == "iPhone17,2"    // iPhone 16 Pro, 16 Pro Max (修正)

        let info = HardwareInfo(
            cpuModel: cpuModel,
            cpuCores: cpuCores,
            gpuCores: getGPUCores(),
            neuralEngineCores: getNeuralEngineCores(),
            totalMemory: totalMemory,
            totalStorage: totalStorage,
            availableStorage: availableStorage,
            hasLiDAR: hasLiDAR,
            hasProMotion: hasProMotion,
            hasAlwaysOnDisplay: hasAlwaysOnDisplay
        )

        DispatchQueue.main.async {
            self.hardwareInfo = info
        }
    }

    private func getCPUModel() -> String {
        let model = getDeviceModel()
        // iPhone 16 Series (2024) - A18 chip - 官方正确映射
        if model.hasPrefix("iPhone17,") {
            if model.contains("iPhone17,1") || model.contains("iPhone17,2") {
                return "A18 Pro"  // iPhone 16 Pro/Pro Max
            }
            return "A18"  // iPhone 16/Plus
        }
        // iPhone 15 Series (2023) - A17 Pro/A16
        if model.hasPrefix("iPhone16,") {
            if model.contains("iPhone16,3") || model.contains("iPhone16,4") {
                return "A17 Pro"  // iPhone 15 Pro/Pro Max
            }
            return "A16 Bionic"  // iPhone 15/Plus
        }
        // iPhone 14 Series (2022)
        if model.hasPrefix("iPhone15,") { return "A16 Bionic" }
        if model.hasPrefix("iPhone14,") { return "A15 Bionic" }
        // iPhone 13 Series (2021)
        if model.hasPrefix("iPhone13,") { return "A15 Bionic" }
        // iPhone 12 Series (2020)
        if model.hasPrefix("iPhone12,") { return "A14 Bionic" }
        // iPhone 11 Series (2019)
        if model.hasPrefix("iPhone11,") { return "A13 Bionic" }
        return "Apple Silicon"
    }

    private func getGPUCores() -> Int {
        let model = getDeviceModel()
        // iPhone 16 Pro series - 6 cores GPU
        if model == "iPhone17,1" || model == "iPhone17,2" { return 6 }
        // iPhone 16 standard - 5 cores GPU
        if model == "iPhone17,3" || model == "iPhone17,4" { return 5 }
        // iPhone 15 Pro series - 6 cores
        if model == "iPhone16,3" || model == "iPhone16,4" { return 6 }
        // iPhone 15 standard - 5 cores
        if model.hasPrefix("iPhone16,") { return 5 }
        // iPhone 14 Pro series - 5 cores
        if model.hasPrefix("iPhone15,") { return 5 }
        // iPhone 14 standard - 5 cores
        if model.hasPrefix("iPhone14,") { return 5 }
        // iPhone 13 series - 4 cores for standard, 5 for Pro
        if model == "iPhone14,2" || model == "iPhone14,3" { return 5 }
        if model.hasPrefix("iPhone14,") { return 4 }
        // iPhone 12 series - 4 cores
        if model.hasPrefix("iPhone13,") { return 4 }
        // iPhone 11 series - 4 cores for standard, 4 for Pro
        if model.hasPrefix("iPhone12,") { return 4 }
        return 4
    }

    private func getNeuralEngineCores() -> Int {
        let model = getDeviceModel()
        // A18 Pro - 16 cores
        if model == "iPhone17,3" || model == "iPhone17,4" { return 16 }
        // A18 - 16 cores
        if model.hasPrefix("iPhone17,") { return 16 }
        // A17 Pro - 16 cores
        if model == "iPhone16,3" || model == "iPhone16,4" { return 16 }
        // A16 - 16 cores
        if model.hasPrefix("iPhone16,") || model.hasPrefix("iPhone15,") { return 16 }
        // A15 - 16 cores
        if model.hasPrefix("iPhone14,") { return 16 }
        // A14 - 16 cores
        if model.hasPrefix("iPhone13,") { return 16 }
        // A13 - 16 cores
        if model.hasPrefix("iPhone12,") { return 16 }
        // A12 - 8 cores
        if model.hasPrefix("iPhone11,") { return 8 }
        return 16
    }

    private func getTotalMemory() -> UInt64 {
        var size: Int = 0
        sysctlbyname("hw.memsize", nil, &size, nil, 0)
        var memsize: UInt64 = 0
        sysctlbyname("hw.memsize", &memsize, &size, nil, 0)
        return memsize
    }

    private func getStorageInfo() -> (total: UInt64, available: UInt64) {
        var total: UInt64 = 0
        var available: UInt64 = 0

        // Method 1: Try statfs
        var stats = statfs()
        let path = NSHomeDirectory()

        if path.withCString({ cString in statfs(cString, &stats) }) == 0 {
            // Total blocks * block size
            total = UInt64(stats.f_blocks) * UInt64(stats.f_bsize)
            // Available blocks * block size
            available = UInt64(stats.f_bavail) * UInt64(stats.f_bsize)

            print("[DEBUG Storage] statfs - Total: \(total) bytes (\(Double(total)/1.0e9) GB), Available: \(available) bytes (\(Double(available)/1.0e9) GB)")
        }

        // Method 2: Try URLResourceKey as backup
        if total == 0 {
            do {
                let fileURL = URL(fileURLWithPath: NSHomeDirectory())
                let keys: Set<URLResourceKey> = [
                    .volumeTotalCapacityKey,
                    .volumeAvailableCapacityKey
                ]
                let values = try fileURL.resourceValues(forKeys: keys)

                if let totalCapacity = values.volumeTotalCapacity {
                    total = UInt64(totalCapacity)
                }
                if let availableCapacity = values.volumeAvailableCapacity {
                    available = UInt64(availableCapacity)
                }

                print("[DEBUG Storage] URLResourceKey - Total: \(total) bytes, Available: \(available) bytes")
            } catch {
                print("[DEBUG Storage] Error getting storage info: \(error)")
            }
        }

        // If we got a total capacity, don't round it - use the actual value
        // The actual capacity will be slightly less than marketed size due to:
        // - Decimal vs binary gigabytes (1000 vs 1024)
        // - System partition and formatting overhead
        if total > 0 {
            // Don't round - use actual capacity
            // For a 256GB device, actual capacity is typically around 238GB
            // For a 512GB device, actual capacity is typically around 477GB
            print("[DEBUG Storage] Final - Total: \(total) bytes (\(String(format: "%.1f", Double(total)/1.0e9)) GB), Available: \(available) bytes (\(String(format: "%.1f", Double(available)/1.0e9)) GB)")
            return (total, available)
        }

        // Fallback
        print("[DEBUG Storage] Using fallback values")
        return (256 * 1024 * 1024 * 1024, 128 * 1024 * 1024 * 1024)
    }

    // MARK: - Battery Information
    private func loadBatteryInfo() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let device = UIDevice.current

        let info = BatteryInfo(
            level: device.batteryLevel,
            state: device.batteryState,
            isLowPowerModeEnabled: ProcessInfo.processInfo.isLowPowerModeEnabled,
            health: nil,  // Requires IOKit - will implement separately
            cycleCount: nil,
            temperature: nil
        )

        DispatchQueue.main.async {
            self.batteryInfo = info
        }
    }

    // MARK: - Display Information
    private func loadDisplayInfo() {
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale

        let width = bounds.size.width
        let height = bounds.size.height

        // Calculate PPI
        let ppi = calculatePPI(for: getDeviceModel())

        let maxFPS = Int(screen.maximumFramesPerSecond)

        let info = DisplayInfo(
            screenSize: getScreenSize(),
            resolution: "\(Int(width * scale)) x \(Int(height * scale))",
            ppi: ppi,
            refreshRate: maxFPS == 120 ? 120.0 : 60.0,
            brightness: screen.brightness,
            isProMotion: maxFPS == 120,
            hasHDR: true,  // Modern iPhones support HDR
            colorDepth: 8
        )

        DispatchQueue.main.async {
            self.displayInfo = info
        }
    }

    private func getScreenSize() -> Double {
        let model = getDeviceModel()
        // iPhone 16 Series - 官方正确映射
        if model == "iPhone17,1" { return 6.3 }  // iPhone 16 Pro
        if model == "iPhone17,2" { return 6.9 }  // iPhone 16 Pro Max
        if model == "iPhone17,3" { return 6.1 }  // iPhone 16
        if model == "iPhone17,4" { return 6.7 }  // iPhone 16 Plus

        // iPhone 15 Series
        if model == "iPhone16,1" { return 6.1 }  // iPhone 15
        if model == "iPhone16,2" { return 6.7 }  // iPhone 15 Plus
        if model == "iPhone16,3" { return 6.1 }  // iPhone 15 Pro
        if model == "iPhone16,4" { return 6.7 }  // iPhone 15 Pro Max

        // iPhone 14 Series
        if model == "iPhone14,7" { return 6.1 }  // iPhone 14
        if model == "iPhone14,8" { return 6.7 }  // iPhone 14 Plus
        if model == "iPhone15,2" { return 6.1 }  // iPhone 14 Pro
        if model == "iPhone15,3" { return 6.7 }  // iPhone 14 Pro Max

        // iPhone 13 Series
        if model == "iPhone14,5" { return 6.1 }  // iPhone 13
        if model == "iPhone14,4" { return 5.4 }  // iPhone 13 mini
        if model == "iPhone14,2" { return 6.1 }  // iPhone 13 Pro
        if model == "iPhone14,3" { return 6.7 }  // iPhone 13 Pro Max

        // iPhone 12 Series
        if model == "iPhone13,2" { return 6.1 }  // iPhone 12
        if model == "iPhone13,1" { return 5.4 }  // iPhone 12 mini
        if model == "iPhone13,3" { return 6.1 }  // iPhone 12 Pro
        if model == "iPhone13,4" { return 6.7 }  // iPhone 12 Pro Max

        // iPhone 11 Series
        if model == "iPhone12,1" { return 6.1 }  // iPhone 11
        if model == "iPhone12,3" { return 5.8 }  // iPhone 11 Pro
        if model == "iPhone12,5" { return 6.5 }  // iPhone 11 Pro Max

        // iPhone SE
        if model == "iPhone14,6" || model == "iPhone12,8" { return 4.7 }

        // Default
        return 6.1
    }

    private func calculatePPI(for model: String) -> Int {
        // iPhone PPI values - modern iPhones use 460 or 476 PPI (Pro models)
        // iPhone 16 Pro series uses newer display technology
        if model == "iPhone17,3" || model == "iPhone17,4" { return 460 }  // iPhone 16 Pro - 460 PPI
        if model.hasPrefix("iPhone17,") { return 460 }  // iPhone 16 - 460 PPI
        if model.hasPrefix("iPhone16,") { return 460 }  // iPhone 15 - 460 PPI
        if model.hasPrefix("iPhone15,") { return 460 }  // iPhone 14 Pro - 460 PPI
        if model.hasPrefix("iPhone14,") { return 460 }  // iPhone 14 - 460 PPI
        if model.hasPrefix("iPhone13,") { return 460 }  // iPhone 13 - 460 PPI
        if model.hasPrefix("iPhone12,") { return 460 }  // iPhone 12 - 460 PPI
        if model.hasPrefix("iPhone11,") { return 458 }  // iPhone 11 Pro - 458 PPI
        return 326  // Older iPhones or SE
    }

    // MARK: - Network Information
    private func loadNetworkInfo() {
        let info = NetworkInfo(
            carrierName: getCarrierName(),
            networkType: getNetworkType(),
            signalStrength: nil,  // Requires Core Telephony
            wifiSSID: getWiFiSSID(),
            wifiBSSID: nil,
            wifiRSSI: nil,
            isConnectedToVPN: false
        )

        DispatchQueue.main.async {
            self.networkInfo = info
        }
    }

    private func getCarrierName() -> String? {
        // Would need Core Telephony framework
        // For now, return nil
        return nil
    }

    private func getNetworkType() -> String? {
        // Would need Core Telephony framework
        return nil
    }

    private func getWiFiSSID() -> String? {
        // Requires NEHotspotNetwork - requires special entitlement
        return nil
    }

    // MARK: - System Information
    private func loadSystemInfo() {
        let device = UIDevice.current

        let info = SystemInfo(
            iOSVersion: device.systemVersion,
            buildNumber: getBuildNumber(),
            kernelVersion: getKernelVersion(),
            bootTime: getBootTime(),
            uptime: getUptime(),
            isJailbroken: checkJailbreak(),
            deviceLanguage: Locale.current.language.languageCode?.identifier ?? "Unknown",
            timezone: TimeZone.current.identifier
        )

        DispatchQueue.main.async {
            self.systemInfo = info
        }
    }

    private func getKernelVersion() -> String {
        var size = 0
        sysctlbyname("kern.version", nil, &size, nil, 0)
        var version = [CChar](repeating: 0, count: size)
        sysctlbyname("kern.version", &version, &size, nil, 0)
        return String(cString: version)
    }

    private func getBootTime() -> Date? {
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var bootTime = timeval()
        var size = MemoryLayout<timeval>.stride

        sysctl(&mib, u_int(mib.count), &bootTime, &size, nil, 0)
        return Date(timeIntervalSince1970: TimeInterval(bootTime.tv_sec))
    }

    private func getUptime() -> TimeInterval {
        if let bootTime = getBootTime() {
            return Date().timeIntervalSince(bootTime)
        }
        return 0
    }

    private func checkJailbreak() -> Bool {
        // Common jailbreak indicators
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/private/var/lib/apt/",
            "/bin/sh",
            "/usr/sbin/sshd",
            "/etc/apt"
        ]

        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        // Check if we can write outside our sandbox
        let string = "Jailbreak test"
        do {
            try string.write(toFile: "/private/jailbreak_test.txt", atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: "/private/jailbreak_test.txt")
            return true
        } catch {
            return false
        }
    }
}
