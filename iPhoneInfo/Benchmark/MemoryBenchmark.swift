//
//  MemoryBenchmark.swift
//  iPhoneInfo
//
//  Memory performance benchmark implementation
//

import Foundation

// MARK: - Memory Benchmark Result
struct MemoryBenchmarkResult {
    let sequentialReadSpeed: UInt64        // MB/s
    let sequentialWriteSpeed: UInt64       // MB/s
    let randomReadSpeed: UInt64            // MB/s
    let randomWriteSpeed: UInt64           // MB/s
    let copySpeed: UInt64                  // MB/s
    let allocationSpeed: UInt64            // allocations/sec
    let totalScore: Int

    var grade: String {
        switch totalScore {
        case 0..<5000: return "D"
        case 5000..<8000: return "C"
        case 8000..<12000: return "B"
        case 12000..<15000: return "A"
        case 15000...Int.max: return "S"
        default: return "D"
        }
    }

    var description: String {
        return """
        内存性能测试结果:

        顺序读取: \(formatSpeed(sequentialReadSpeed)) MB/s
        顺序写入: \(formatSpeed(sequentialWriteSpeed)) MB/s
        随机读取: \(formatSpeed(randomReadSpeed)) MB/s
        随机写入: \(formatSpeed(randomWriteSpeed)) MB/s
        内存复制: \(formatSpeed(copySpeed)) MB/s
        分配速度: \(formatSpeed(allocationSpeed)) 次/秒

        综合得分: \(totalScore)
        等级: \(grade)
        """
    }

    private func formatSpeed(_ value: UInt64) -> String {
        return String(format: "%.1f", Double(value) / 1024.0)
    }
}

// MARK: - Memory Benchmark
class MemoryBenchmark {

    // MARK: - Sequential Read Test
    func runSequentialReadTest() -> UInt64 {
        let testSize = 100 * 1024 * 1024  // 100MB
        let iterations = 10
        var totalBytes = UInt64(0)

        // Allocate test buffer
        guard let buffer = malloc(testSize) else {
            return 0
        }

        let startTime = Date()

        for _ in 0..<iterations {
            // Sequential read through memory
            let ptr = buffer.assumingMemoryBound(to: UInt8.self)
            var sum: UInt64 = 0

            for i in 0..<testSize {
                sum += UInt64(ptr[i])
            }

            totalBytes += UInt64(testSize)
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Prevent optimization
        if totalBytes == 0 {
            print("Read sum: \(totalBytes)")
        }

        free(buffer)

        let bytesPerSecond = elapsed > 0 ? UInt64(Double(totalBytes) / elapsed) : 0
        return bytesPerSecond / (1024 * 1024)  // Convert to MB/s
    }

    // MARK: - Sequential Write Test
    func runSequentialWriteTest() -> UInt64 {
        let testSize = 100 * 1024 * 1024  // 100MB
        let iterations = 10
        var totalBytes = UInt64(0)

        guard let buffer = malloc(testSize) else {
            return 0
        }

        let startTime = Date()

        for _ in 0..<iterations {
            let ptr = buffer.assumingMemoryBound(to: UInt8.self)

            // Sequential write through memory
            for i in 0..<testSize {
                ptr[i] = UInt8(i % 256)
            }

            totalBytes += UInt64(testSize)
        }

        let elapsed = Date().timeIntervalSince(startTime)

        free(buffer)

        let bytesPerSecond = elapsed > 0 ? UInt64(Double(totalBytes) / elapsed) : 0
        return bytesPerSecond / (1024 * 1024)
    }

    // MARK: - Random Read Test
    func runRandomReadTest() -> UInt64 {
        let testSize = 100 * 1024 * 1024  // 100MB
        let iterations = 10
        let accessCount = 1000000  // 1M random accesses per iteration
        var totalBytes = UInt64(0)

        guard let buffer = malloc(testSize) else {
            return 0
        }

        // Initialize buffer with pattern
        let ptr = buffer.assumingMemoryBound(to: UInt8.self)
        for i in 0..<testSize {
            ptr[i] = UInt8(i % 256)
        }

        let startTime = Date()

        for _ in 0..<iterations {
            var sum: UInt64 = 0

            // Random read accesses
            for _ in 0..<accessCount {
                let index = Int.random(in: 0..<testSize)
                sum += UInt64(ptr[index])
            }

            totalBytes += UInt64(accessCount)
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Prevent optimization
        if totalBytes == 0 {
            print("Random read sum: \(totalBytes)")
        }

        free(buffer)

        // Calculate accesses per second, convert to approximate MB/s
        let accessesPerSecond = elapsed > 0 ? UInt64(Double(totalBytes) / elapsed) : 0
        return accessesPerSecond / (1024 * 1024)
    }

    // MARK: - Random Write Test
    func runRandomWriteTest() -> UInt64 {
        let testSize = 100 * 1024 * 1024  // 100MB
        let iterations = 10
        let accessCount = 1000000  // 1M random accesses per iteration
        var totalBytes = UInt64(0)

        guard let buffer = malloc(testSize) else {
            return 0
        }

        let startTime = Date()

        for _ in 0..<iterations {
            // Random write accesses
            for _ in 0..<accessCount {
                let index = Int.random(in: 0..<testSize)
                let ptr = buffer.assumingMemoryBound(to: UInt8.self)
                ptr[index] = UInt8.random(in: 0...255)
            }

            totalBytes += UInt64(accessCount)
        }

        let elapsed = Date().timeIntervalSince(startTime)

        free(buffer)

        let accessesPerSecond = elapsed > 0 ? UInt64(Double(totalBytes) / elapsed) : 0
        return accessesPerSecond / (1024 * 1024)
    }

    // MARK: - Memory Copy Test
    func runMemoryCopyTest() -> UInt64 {
        let testSize = 50 * 1024 * 1024  // 50MB
        let iterations = 20
        var totalBytes = UInt64(0)

        guard let source = malloc(testSize), let dest = malloc(testSize) else {
            return 0
        }

        // Initialize source buffer
        let srcPtr = source.assumingMemoryBound(to: UInt8.self)
        for i in 0..<testSize {
            srcPtr[i] = UInt8(i % 256)
        }

        let startTime = Date()

        for _ in 0..<iterations {
            // Copy memory using memcpy
            memcpy(dest, source, testSize)
            totalBytes += UInt64(testSize)
        }

        let elapsed = Date().timeIntervalSince(startTime)

        free(source)
        free(dest)

        let bytesPerSecond = elapsed > 0 ? UInt64(Double(totalBytes) / elapsed) : 0
        return bytesPerSecond / (1024 * 1024)
    }

    // MARK: - Memory Allocation Test
    func runAllocationTest() -> UInt64 {
        let allocationSize = 1024  // 1KB
        let targetDuration: TimeInterval = 5.0  // 5 seconds
        var allocationCount = 0

        let startTime = Date()
        var allocations: [UnsafeMutableRawPointer] = []

        // Allocate for target duration
        while Date().timeIntervalSince(startTime) < targetDuration {
            if let ptr = malloc(allocationSize) {
                allocations.append(ptr)
                allocationCount += 1

                // Free allocations periodically to avoid memory exhaustion
                if allocationCount % 10000 == 0 {
                    for ptr in allocations {
                        free(ptr)
                    }
                    allocations.removeAll()
                }
            }
        }

        // Clean up remaining allocations
        for ptr in allocations {
            free(ptr)
        }

        let elapsed = Date().timeIntervalSince(startTime)
        let allocationsPerSecond = elapsed > 0 ? UInt64(Double(allocationCount) / elapsed) : 0

        return allocationsPerSecond
    }

    // MARK: - Quick Memory Test
    func runQuickTest() -> MemoryBenchmarkResult {
        // Simplified test with fewer iterations
        let sequentialRead = runSequentialReadTest() / 2
        let sequentialWrite = runSequentialWriteTest() / 2

        let totalScore = Int((Double(sequentialRead + sequentialWrite) / 2.0))

        return MemoryBenchmarkResult(
            sequentialReadSpeed: sequentialRead,
            sequentialWriteSpeed: sequentialWrite,
            randomReadSpeed: sequentialRead / 2,
            randomWriteSpeed: sequentialWrite / 2,
            copySpeed: sequentialRead,
            allocationSpeed: sequentialRead * 100,
            totalScore: totalScore
        )
    }

    // MARK: - Full Benchmark
    func runFullBenchmark() -> MemoryBenchmarkResult {
        let sequentialReadSpeed = runSequentialReadTest()
        let sequentialWriteSpeed = runSequentialWriteTest()
        let randomReadSpeed = runRandomReadTest()
        let randomWriteSpeed = runRandomWriteTest()
        let copySpeed = runMemoryCopyTest()
        let allocationSpeed = runAllocationTest()

        // Calculate weighted total score
        let totalScore = Int(
            Double(sequentialReadSpeed) * 0.25 +
            Double(sequentialWriteSpeed) * 0.25 +
            Double(randomReadSpeed) * 0.15 +
            Double(randomWriteSpeed) * 0.15 +
            Double(copySpeed) * 0.1 +
            Double(allocationSpeed) / 100.0 * 0.1
        )

        return MemoryBenchmarkResult(
            sequentialReadSpeed: sequentialReadSpeed,
            sequentialWriteSpeed: sequentialWriteSpeed,
            randomReadSpeed: randomReadSpeed,
            randomWriteSpeed: randomWriteSpeed,
            copySpeed: copySpeed,
            allocationSpeed: allocationSpeed,
            totalScore: totalScore
        )
    }

    // MARK: - Memory Stress Test
    func runStressTest() -> (peakMemoryUsage: UInt64, allocations: UInt64, deallocations: UInt64) {
        let targetDuration: TimeInterval = 10.0
        let chunkSize = 10 * 1024 * 1024  // 10MB chunks
        var allocations: [UnsafeMutableRawPointer] = []
        var allocationCount: UInt64 = 0
        var deallocationCount: UInt64 = 0
        var peakMemory: UInt64 = 0

        let startTime = Date()

        while Date().timeIntervalSince(startTime) < targetDuration {
            // Allocate chunks
            for _ in 0..<10 {
                if let ptr = malloc(chunkSize) {
                    allocations.append(ptr)
                    allocationCount += 1

                    // Fill with data to ensure actual memory allocation
                    let dataPtr = ptr.assumingMemoryBound(to: UInt8.self)
                    for i in 0..<chunkSize {
                        dataPtr[i] = UInt8(i % 256)
                    }
                }
            }

            // Track peak usage
            let currentUsage = UInt64(allocations.count) * UInt64(chunkSize)
            if currentUsage > peakMemory {
                peakMemory = currentUsage
            }

            // Free some chunks randomly
            if allocations.count > 50 && Int.random(in: 0..<10) < 3 {
                let index = Int.random(in: 0..<allocations.count)
                free(allocations[index])
                allocations.remove(at: index)
                deallocationCount += 1
            }

            // Small delay
            Thread.sleep(forTimeInterval: 0.01)
        }

        // Clean up
        for ptr in allocations {
            free(ptr)
            deallocationCount += 1
        }

        return (peakMemory, allocationCount, deallocationCount)
    }
}
