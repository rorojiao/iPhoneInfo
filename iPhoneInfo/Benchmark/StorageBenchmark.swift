//
//  StorageBenchmark.swift
//  iPhoneInfo
//
//  Storage I/O performance benchmark implementation
//

import Foundation

// MARK: - Storage Benchmark Result
struct StorageBenchmarkResult {
    let sequentialReadSpeed: UInt64        // MB/s
    let sequentialWriteSpeed: UInt64       // MB/s
    let randomReadSpeed: UInt64            // MB/s
    let randomWriteSpeed: UInt64           // MB/s
    let smallFileRW: UInt64                // MB/s
    let totalScore: Int
    let testDuration: TimeInterval

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
        存储性能测试结果:

        顺序读取: \(formatSpeed(sequentialReadSpeed)) MB/s
        顺序写入: \(formatSpeed(sequentialWriteSpeed)) MB/s
        随机读取: \(formatSpeed(randomReadSpeed)) MB/s
        随机写入: \(formatSpeed(randomWriteSpeed)) MB/s
        小文件读写: \(formatSpeed(smallFileRW)) MB/s

        综合得分: \(totalScore)
        等级: \(grade)
        测试耗时: \(String(format: "%.1f", testDuration)) 秒
        """
    }

    private func formatSpeed(_ value: UInt64) -> String {
        return String(format: "%.1f", Double(value) / 1024.0)
    }
}

// MARK: - Storage Benchmark
class StorageBenchmark {

    private let fileManager = FileManager.default
    private let testDirectory: URL

    init() {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        testDirectory = paths[0].appendingPathComponent("benchmark_test", isDirectory: true)

        // Create test directory if it doesn't exist
        if !fileManager.fileExists(atPath: testDirectory.path) {
            try? fileManager.createDirectory(at: testDirectory, withIntermediateDirectories: true)
        }
    }

    deinit {
        // Clean up test directory
        try? fileManager.removeItem(at: testDirectory)
    }

    // MARK: - Sequential Read Test
    func runSequentialReadTest(fileSize: UInt64 = 100 * 1024 * 1024) -> UInt64 {
        let testFile = testDirectory.appendingPathComponent("sequential_read_test.dat")

        // Create test file first
        guard createTestFile(at: testFile, size: fileSize) else {
            return 0
        }

        let iterations = 5
        var totalBytesRead = UInt64(0)

        let startTime = Date()

        for _ in 0..<iterations {
            do {
                let data = try Data(contentsOf: testFile)
                totalBytesRead += UInt64(data.count)

                // Prevent optimization
                if data.count == 0 {
                    print("Empty data")
                }
            } catch {
                print("Read error: \(error.localizedDescription)")
                break
            }
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Clean up
        try? fileManager.removeItem(at: testFile)

        let bytesPerSecond = elapsed > 0 ? UInt64(Double(totalBytesRead) / elapsed) : 0
        return bytesPerSecond / (1024 * 1024)
    }

    // MARK: - Sequential Write Test
    func runSequentialWriteTest(fileSize: UInt64 = 100 * 1024 * 1024) -> UInt64 {
        let testFile = testDirectory.appendingPathComponent("sequential_write_test.dat")
        let iterations = 5
        var totalBytesWritten = UInt64(0)

        // Create test data pattern
        let chunkSize = 1024 * 1024  // 1MB chunks
        let chunk = Data([UInt8](repeating: 0xAA, count: chunkSize))

        let startTime = Date()

        for _ in 0..<iterations {
            // Remove existing file
            try? fileManager.removeItem(at: testFile)

            do {
                let fileHandle = try FileHandle(forWritingTo: testFile)
                defer { fileHandle.closeFile() }

                var bytesWritten = UInt64(0)
                while bytesWritten < fileSize {
                    let bytesToWrite = min(UInt64(chunk.count), fileSize - bytesWritten)
                    fileHandle.write(chunk.prefix(Int(bytesToWrite)))
                    bytesWritten += bytesToWrite
                }

                fileHandle.synchronizeFile()
                totalBytesWritten += fileSize
            } catch {
                print("Write error: \(error.localizedDescription)")
                break
            }
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Clean up
        try? fileManager.removeItem(at: testFile)

        let bytesPerSecond = elapsed > 0 ? UInt64(Double(totalBytesWritten) / elapsed) : 0
        return bytesPerSecond / (1024 * 1024)
    }

    // MARK: - Random Read Test
    func runRandomReadTest(fileSize: UInt64 = 50 * 1024 * 1024, blockSize: Int = 4 * 1024) -> UInt64 {
        let testFile = testDirectory.appendingPathComponent("random_read_test.dat")

        guard createTestFile(at: testFile, size: fileSize) else {
            return 0
        }

        let iterations = 10000  // Number of random reads
        var totalBytesRead = UInt64(0)

        // Get file size
        guard let attrs = try? fileManager.attributesOfItem(atPath: testFile.path),
              let fileSizeActual = attrs[.size] as? UInt64 else {
            return 0
        }

        let startTime = Date()

        do {
            let fileHandle = try FileHandle(forReadingFrom: testFile)
            defer { fileHandle.closeFile() }

            for _ in 0..<iterations {
                let randomOffset = UInt64.random(in: 0..<fileSizeActual - UInt64(blockSize))
                fileHandle.seek(toFileOffset: randomOffset)

                let data = fileHandle.readData(ofLength: blockSize)
                totalBytesRead += UInt64(data.count)
            }
        } catch {
            print("Random read error: \(error.localizedDescription)")
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Clean up
        try? fileManager.removeItem(at: testFile)

        let bytesPerSecond = elapsed > 0 ? UInt64(Double(totalBytesRead) / elapsed) : 0
        return bytesPerSecond / (1024 * 1024)
    }

    // MARK: - Random Write Test
    func runRandomWriteTest(fileSize: UInt64 = 50 * 1024 * 1024, blockSize: Int = 4 * 1024) -> UInt64 {
        let testFile = testDirectory.appendingPathComponent("random_write_test.dat")

        // Create initial file
        guard createTestFile(at: testFile, size: fileSize) else {
            return 0
        }

        let iterations = 10000  // Number of random writes
        var totalBytesWritten = UInt64(0)

        let writeData = Data([UInt8](repeating: 0xBB, count: blockSize))

        let startTime = Date()

        do {
            let fileHandle = try FileHandle(forWritingTo: testFile)
            defer { fileHandle.closeFile() }

            for _ in 0..<iterations {
                let randomOffset = UInt64.random(in: 0..<fileSize - UInt64(blockSize))
                fileHandle.seek(toFileOffset: randomOffset)
                fileHandle.write(writeData)
                totalBytesWritten += UInt64(blockSize)
            }

            fileHandle.synchronizeFile()
        } catch {
            print("Random write error: \(error.localizedDescription)")
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Clean up
        try? fileManager.removeItem(at: testFile)

        let bytesPerSecond = elapsed > 0 ? UInt64(Double(totalBytesWritten) / elapsed) : 0
        return bytesPerSecond / (1024 * 1024)
    }

    // MARK: - Small File R/W Test
    func runSmallFileRWTest() -> UInt64 {
        let fileCount = 1000
        let fileSize = 4 * 1024  // 4KB files
        let testData = Data([UInt8](repeating: 0xCC, count: fileSize))
        var totalBytes = UInt64(0)

        let startTime = Date()

        // Write phase
        for i in 0..<fileCount {
            let fileURL = testDirectory.appendingPathComponent("small_file_\(i).dat")

            do {
                try testData.write(to: fileURL)
                totalBytes += UInt64(fileSize)
            } catch {
                print("Small file write error: \(error.localizedDescription)")
            }
        }

        // Read phase
        for i in 0..<fileCount {
            let fileURL = testDirectory.appendingPathComponent("small_file_\(i).dat")

            do {
                let data = try Data(contentsOf: fileURL)
                totalBytes += UInt64(data.count)
            } catch {
                print("Small file read error: \(error.localizedDescription)")
            }
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Clean up all small files
        for i in 0..<fileCount {
            let fileURL = testDirectory.appendingPathComponent("small_file_\(i).dat")
            try? fileManager.removeItem(at: fileURL)
        }

        let bytesPerSecond = elapsed > 0 ? UInt64(Double(totalBytes) / elapsed) : 0
        return bytesPerSecond / (1024 * 1024)
    }

    // MARK: - Quick Storage Test
    func runQuickTest() -> StorageBenchmarkResult {
        let startTime = Date()

        // Smaller files for quick test
        let sequentialRead = runSequentialReadTest(fileSize: 10 * 1024 * 1024)
        let sequentialWrite = runSequentialWriteTest(fileSize: 10 * 1024 * 1024)

        let elapsed = Date().timeIntervalSince(startTime)

        let totalScore = Int((Double(sequentialRead + sequentialWrite) / 2.0))

        return StorageBenchmarkResult(
            sequentialReadSpeed: sequentialRead,
            sequentialWriteSpeed: sequentialWrite,
            randomReadSpeed: sequentialRead / 2,
            randomWriteSpeed: sequentialWrite / 2,
            smallFileRW: sequentialRead,
            totalScore: totalScore,
            testDuration: elapsed
        )
    }

    // MARK: - Full Benchmark
    func runFullBenchmark() -> StorageBenchmarkResult {
        let startTime = Date()

        let sequentialReadSpeed = runSequentialReadTest()
        let sequentialWriteSpeed = runSequentialWriteTest()
        let randomReadSpeed = runRandomReadTest()
        let randomWriteSpeed = runRandomWriteTest()
        let smallFileRW = runSmallFileRWTest()

        let elapsed = Date().timeIntervalSince(startTime)

        // Calculate weighted total score
        let totalScore = Int(
            Double(sequentialReadSpeed) * 0.25 +
            Double(sequentialWriteSpeed) * 0.25 +
            Double(randomReadSpeed) * 0.15 +
            Double(randomWriteSpeed) * 0.15 +
            Double(smallFileRW) * 0.2
        )

        return StorageBenchmarkResult(
            sequentialReadSpeed: sequentialReadSpeed,
            sequentialWriteSpeed: sequentialWriteSpeed,
            randomReadSpeed: randomReadSpeed,
            randomWriteSpeed: randomWriteSpeed,
            smallFileRW: smallFileRW,
            totalScore: totalScore,
            testDuration: elapsed
        )
    }

    // MARK: - Helper Functions
    private func createTestFile(at url: URL, size: UInt64) -> Bool {
        // Remove existing file
        try? fileManager.removeItem(at: url)

        let chunkSize = 1024 * 1024  // 1MB chunks
        let chunk = Data([UInt8](repeating: 0xFF, count: chunkSize))

        do {
            let fileHandle = try FileHandle(forWritingTo: url)
            defer { fileHandle.closeFile() }

            var bytesWritten = UInt64(0)
            while bytesWritten < size {
                let bytesToWrite = min(UInt64(chunk.count), size - bytesWritten)
                fileHandle.write(chunk.prefix(Int(bytesToWrite)))
                bytesWritten += bytesToWrite
            }

            fileHandle.synchronizeFile()
            return true
        } catch {
            print("Error creating test file: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Storage Stress Test
    func runStressTest() -> (filesCreated: Int, totalData: UInt64, duration: TimeInterval) {
        let targetDuration: TimeInterval = 10.0
        let startTime = Date()
        var filesCreated = 0
        var totalData = UInt64(0)
        let fileSize = 1024 * 1024  // 1MB files
        let testData = Data([UInt8](repeating: 0xDD, count: fileSize))

        while Date().timeIntervalSince(startTime) < targetDuration {
            let fileURL = testDirectory.appendingPathComponent("stress_\(filesCreated).dat")

            do {
                try testData.write(to: fileURL)
                filesCreated += 1
                totalData += UInt64(fileSize)
            } catch {
                break
            }
        }

        let elapsed = Date().timeIntervalSince(startTime)

        // Clean up
        for i in 0..<filesCreated {
            let fileURL = testDirectory.appendingPathComponent("stress_\(i).dat")
            try? fileManager.removeItem(at: fileURL)
        }

        return (filesCreated, totalData, elapsed)
    }

    // MARK: - Clean Up
    func cleanup() {
        try? fileManager.removeItem(at: testDirectory)
    }
}
