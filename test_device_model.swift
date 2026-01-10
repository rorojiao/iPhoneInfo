import Foundation

func getDeviceModel() -> String {
    var size: Int = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0, count: size)
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String(cString: machine)
}

func getStorageInfo() -> (total: UInt64, available: UInt64) {
    do {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory())

        // Method 1: Try using volumeTotalCapacity
        let keys: Set<URLResourceKey> = [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey
        ]

        let values = try fileURL.resourceValues(forKeys: keys)

        var total: UInt64 = 0
        var available: UInt64 = 0

        if let totalCapacity = values.volumeTotalCapacity {
            total = UInt64(totalCapacity)
        }

        if let availableCapacity = values.volumeAvailableCapacity {
            available = UInt64(availableCapacity)
        }

        print("Raw total capacity: \(total) bytes = \(Double(total) / 1.0e9) GB")
        print("Raw available capacity: \(available) bytes = \(Double(available) / 1.0e9) GB")

        return (total, available)
    } catch {
        print("Error: \(error)")
        return (0, 0)
    }
}

print("Device Model: \(getDeviceModel())")
let (total, available) = getStorageInfo()
print("Total: \(total) GB")
print("Available: \(available) GB")
