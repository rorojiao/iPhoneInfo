//
//  SystemMonitor.swift
//  iPhoneInfo
//
//  Real-time system monitoring service
//

import Foundation
import Combine
import UIKit

// MARK: - System Metrics
struct SystemMetrics {
    let cpuUsage: Double              // 0-100%
    let memoryUsage: Double           // 0-100%
    let memoryUsed: UInt64            // bytes
    let memoryTotal: UInt64           // bytes
    let gpuUsage: Double              // 0-100% (estimated)
    let diskUsage: Double             // 0-100%
    let diskUsed: UInt64              // bytes
    let diskTotal: UInt64             // bytes
    let networkActivity: NetworkActivity
    let batteryLevel: Float           // 0-1
    let batteryState: UIDevice.BatteryState
    let thermalState: ThermalState
    let timestamp: Date

    var isThrottling: Bool {
        return thermalState != .normal
    }
}

struct NetworkActivity {
    let wifiReceived: UInt64
    let wifiSent: UInt64
    let cellularReceived: UInt64
    let cellularSent: UInt64
    let totalReceived: UInt64
    let totalSent: UInt64
}

enum ThermalState {
    case normal
    case light
    case moderate
    case heavy
    case critical

    var description: String {
        switch self {
        case .normal: return "正常"
        case .light: return "轻度发热"
        case .moderate: return "中度发热"
        case .heavy: return "重度发热"
        case .critical: return "严重发热"
        }
    }

    var color: UIColor {
        switch self {
        case .normal: return .systemGreen
        case .light: return .systemYellow
        case .moderate: return .systemOrange
        case .heavy: return .systemRed
        case .critical: return .systemRed
        }
    }
}

// MARK: - System Monitor
class SystemMonitor: ObservableObject {
    static let shared = SystemMonitor()

    @Published var currentMetrics: SystemMetrics?
    @Published var isMonitoring = false
    @Published var updateInterval: TimeInterval = 1.0

    private var monitorTimer: Timer?
    private var previousNetworkData: (iface: String, received: UInt64, sent: UInt64)?

    private init() {
        // Initialize with current metrics
        updateMetrics()
    }

    // MARK: - Start/Stop Monitoring
    func startMonitoring(interval: TimeInterval = 1.0) {
        guard !isMonitoring else { return }

        updateInterval = interval
        isMonitoring = true

        monitorTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }

        updateMetrics()
    }

    func stopMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = nil
        isMonitoring = false
    }

    // MARK: - Update Metrics
    private func updateMetrics() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let cpuUsage = self.getCPUUsage()
            let (memoryUsed, memoryTotal) = self.getMemoryUsage()
            let memoryUsage = memoryTotal > 0 ? Double(memoryUsed) / Double(memoryTotal) * 100 : 0
            let gpuUsage = self.estimateGPUUsage()
            let (diskUsed, diskTotal) = self.getDiskUsage()
            let diskUsage = diskTotal > 0 ? Double(diskUsed) / Double(diskTotal) * 100 : 0
            let networkActivity = self.getNetworkActivity()
            let thermalState = self.getThermalState()

            DispatchQueue.main.async {
                UIDevice.current.isBatteryMonitoringEnabled = true
                let batteryLevel = UIDevice.current.batteryLevel
                let batteryState = UIDevice.current.batteryState

                self.currentMetrics = SystemMetrics(
                    cpuUsage: cpuUsage,
                    memoryUsage: memoryUsage,
                    memoryUsed: memoryUsed,
                    memoryTotal: memoryTotal,
                    gpuUsage: gpuUsage,
                    diskUsage: diskUsage,
                    diskUsed: diskUsed,
                    diskTotal: diskTotal,
                    networkActivity: networkActivity,
                    batteryLevel: batteryLevel >= 0 ? batteryLevel : 0,
                    batteryState: batteryState,
                    thermalState: thermalState,
                    timestamp: Date()
                )
            }
        }
    }

    // MARK: - CPU Usage
    private func getCPUUsage() -> Double {
        var totalUsageOfCPU: Double = 0.0
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

            vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        }

        return totalUsageOfCPU
    }

    // MARK: - Memory Usage
    private func getMemoryUsage() -> (used: UInt64, total: UInt64) {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return (0, 0)
        }

        let pageSize = vm_kernel_page_size

        let free = UInt64(stats.free_count) * UInt64(pageSize)
        let active = UInt64(stats.active_count) * UInt64(pageSize)
        let inactive = UInt64(stats.inactive_count) * UInt64(pageSize)
        let wired = UInt64(stats.wire_count) * UInt64(pageSize)
        let compressed = UInt64(stats.compressor_page_count) * UInt64(pageSize)

        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let usedMemory = active + inactive + wired + compressed

        return (usedMemory, totalMemory)
    }

    // MARK: - GPU Usage (Estimated)
    private func estimateGPUUsage() -> Double {
        // iOS doesn't provide direct GPU usage APIs
        // This is an estimation based on screen activity and device state
        // A more accurate implementation would use Metal performance counters

        var gpuLoad: Double = 0

        // Check if screen is on
        if UIScreen.main.brightness > 0 {
            gpuLoad += 20  // Base load for display
        }

        // Add load based on thermal state
        if ProcessInfo.processInfo.thermalState == .serious {
            gpuLoad += 30
        } else if ProcessInfo.processInfo.thermalState == .critical {
            gpuLoad += 50
        }

        // Check for high CPU usage (often correlated with GPU usage)
        if let metrics = currentMetrics, metrics.cpuUsage > 70 {
            gpuLoad += 20
        }

        // Check battery state
        if UIDevice.current.batteryState == .charging {
            gpuLoad += 10
        }

        return min(gpuLoad, 100)
    }

    // MARK: - Disk Usage
    private func getDiskUsage() -> (used: UInt64, total: UInt64) {
        var total: UInt64 = 0
        var available: UInt64 = 0

        // Use statfs for accurate disk information
        var stats = statfs()
        let path = NSHomeDirectory()

        if path.withCString({ cString in statfs(cString, &stats) }) == 0 {
            total = UInt64(stats.f_blocks) * UInt64(stats.f_bsize)
            available = UInt64(stats.f_bavail) * UInt64(stats.f_bsize)
        }

        // Fallback to URLResourceKey
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
            } catch {
                print("Error getting disk usage: \(error)")
            }
        }

        let used = total > available ? total - available : 0
        return (used, total)
    }

    // MARK: - Network Activity
    private func getNetworkActivity() -> NetworkActivity {
        // iOS doesn't provide direct network counter access
        // This is a placeholder implementation
        // Actual implementation would require reading from /proc/net/dev (not available on iOS)

        // Return simulated data
        return NetworkActivity(
            wifiReceived: 0,
            wifiSent: 0,
            cellularReceived: 0,
            cellularSent: 0,
            totalReceived: 0,
            totalSent: 0
        )
    }

    // MARK: - Thermal State
    private func getThermalState() -> ThermalState {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal:
            return .normal
        case .fair:
            return .light
        case .serious:
            return .moderate
        case .critical:
            return .heavy
        @unknown default:
            return .normal
        }
    }

    // MARK: - Process Info
    func getProcessInfo() -> ProcessInfo {
        let info = ProcessInfo.processInfo

        return info
    }

    // MARK: - Uptime
    func getSystemUptime() -> TimeInterval {
        return ProcessInfo.processInfo.systemUptime
    }

    // MARK: - Memory Pressure
    func getMemoryPressure() -> String {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return "未知"
        }

        let pageSize = vm_kernel_page_size
        let free = Double(stats.free_count) * Double(pageSize)
        let total = Double(ProcessInfo.processInfo.physicalMemory)
        let freePercent = (free / total) * 100

        if freePercent > 30 {
            return "正常"
        } else if freePercent > 15 {
            return "中等"
        } else {
            return "高"
        }
    }

    // MARK: - Battery Health Estimate
    func getBatteryHealthEstimate() -> String {
        UIDevice.current.isBatteryMonitoringEnabled = true

        let level = UIDevice.current.batteryLevel
        let state = UIDevice.current.batteryState

        // Simple health estimation based on behavior
        if level < 0.2 && state == .unplugged {
            return "低电量"
        } else if level < 0.5 {
            return "正常"
        } else if level < 0.8 {
            return "良好"
        } else {
            return "优秀"
        }
    }
}

// MARK: - Metrics History
class MetricsHistory: ObservableObject {
    @Published var cpuHistory: [Double] = []
    @Published var memoryHistory: [Double] = []
    @Published var gpuHistory: [Double] = []
    @Published var temperatureHistory: [ThermalState] = []

    private let maxHistoryLength = 60
    private let monitor = SystemMonitor.shared

    func startRecording() {
        monitor.startMonitoring(interval: 1.0)

        // Observe metrics changes
        monitor.$currentMetrics
            .compactMap { $0 }
            .sink { [weak self] metrics in
                self?.addMetrics(metrics)
            }
            .store(in: &cancellables)
    }

    func stopRecording() {
        monitor.stopMonitoring()
    }

    private func addMetrics(_ metrics: SystemMetrics) {
        cpuHistory.append(metrics.cpuUsage)
        memoryHistory.append(metrics.memoryUsage)
        gpuHistory.append(metrics.gpuUsage)
        temperatureHistory.append(metrics.thermalState)

        // Trim to max length
        if cpuHistory.count > maxHistoryLength {
            cpuHistory.removeFirst()
            memoryHistory.removeFirst()
            gpuHistory.removeFirst()
            temperatureHistory.removeFirst()
        }
    }

    func clearHistory() {
        cpuHistory.removeAll()
        memoryHistory.removeAll()
        gpuHistory.removeAll()
        temperatureHistory.removeAll()
    }

    private var cancellables = Set<AnyCancellable>()
}

import Combine
