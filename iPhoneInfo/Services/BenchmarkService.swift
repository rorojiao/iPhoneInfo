//
//  BenchmarkService.swift
//  iPhoneInfo
//
//  性能基准测试服务
//

import Foundation
import Metal
import Combine

class BenchmarkService: ObservableObject {
    static let shared = BenchmarkService()

    @Published var isRunning = false
    @Published var currentTest: String = ""
    @Published var progress: Double = 0
    @Published var results: [BenchmarkResult] = []

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Benchmark Result
    struct BenchmarkResult {
        let name: String
        let score: Double
        let unit: String
        let duration: TimeInterval

        var formattedScore: String {
            if score >= 1000000 {
                return String(format: "%.2fM", score / 1000000)
            } else if score >= 1000 {
                return String(format: "%.2fK", score / 1000)
            } else {
                return String(format: "%.2f", score)
            }
        }
    }

    // MARK: - Run Benchmark
    func runBenchmark(type: BenchmarkType, completion: @escaping () -> Void) {
        guard !isRunning else { return }

        isRunning = true
        results = []
        progress = 0

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.executeTests(type: type, completion: completion)
        }
    }

    private func executeTests(type: BenchmarkType, completion: @escaping () -> Void) {
        let tests: [() async throws -> BenchmarkResult]

        switch type {
        case .quick:
            tests = [
                { try await self.cpuSingleCoreTest() },
                { try await self.memoryTest() }
            ]

        case .full:
            tests = [
                { try await self.cpuSingleCoreTest() },
                { try await self.cpuMultiCoreTest() },
                { try await self.gpuTest() },
                { try await self.memoryTest() },
                { try await self.storageTest() }
            ]
        }

        let totalTests = Double(tests.count)
        var completedTests = 0

        Task {
            for test in tests {
                await MainActor.run {
                    self.currentTest = "正在运行测试..."
                }

                do {
                    let result = try await test()
                    await MainActor.run {
                        self.results.append(result)
                        completedTests += 1
                        self.progress = Double(completedTests) / totalTests
                    }
                } catch {
                    print("Test failed: \(error)")
                }
            }

            await MainActor.run {
                self.isRunning = false
                self.currentTest = "测试完成"
                completion()
            }
        }
    }

    // MARK: - CPU Single Core Test
    private func cpuSingleCoreTest() async throws -> BenchmarkResult {
        await MainActor.run {
            self.currentTest = "CPU 单核测试"
        }

        let startTime = Date()
        var operations = 0
        let duration: TimeInterval = 10 // 运行10秒

        // 计算密集型任务：质数计算
        func isPrime(_ n: Int) -> Bool {
            if n < 2 { return false }
            if n == 2 { return true }
            if n % 2 == 0 { return false }
            let sqrtN = Int(Double(n).squareRoot())
            for i in stride(from: 3, through: sqrtN, by: 2) {
                if n % i == 0 { return false }
            }
            return true
        }

        var count = 0
        let number = 1000000

        while Date().timeIntervalSince(startTime) < duration {
            for i in 2...number {
                if isPrime(i) {
                    count += 1
                }
            }
            operations += 1
        }

        let actualDuration = Date().timeIntervalSince(startTime)
        let score = Double(count * operations) / actualDuration

        return BenchmarkResult(
            name: "CPU 单核",
            score: score,
            unit: "ops/s",
            duration: actualDuration
        )
    }

    // MARK: - CPU Multi Core Test
    private func cpuMultiCoreTest() async throws -> BenchmarkResult {
        await MainActor.run {
            self.currentTest = "CPU 多核测试"
        }

        let startTime = Date()
        let duration: TimeInterval = 10

        // 使用所有可用核心
        let processCount = ProcessInfo.processInfo.processorCount
        var scores: [Double] = []

        await withTaskGroup(of: Double.self) { group in
            for _ in 0..<processCount {
                group.addTask {
                    var count = 0
                    let number = 500000

                    for _ in 0..<5 {
                        for i in 2...number {
                            var isPrime = true
                            if i < 2 { isPrime = false }
                            if i == 2 { isPrime = true }
                            if i % 2 == 0 { isPrime = false }
                            let sqrtN = Int(Double(i).squareRoot())
                            for j in stride(from: 3, through: sqrtN, by: 2) {
                                if i % j == 0 { isPrime = false; break }
                            }
                            if isPrime { count += 1 }
                        }
                    }
                    return Double(count)
                }
            }

            for await result in group {
                scores.append(result)
            }
        }

        let actualDuration = Date().timeIntervalSince(startTime)
        let totalScore = scores.reduce(0, +) / actualDuration

        return BenchmarkResult(
            name: "CPU 多核",
            score: totalScore,
            unit: "ops/s",
            duration: actualDuration
        )
    }

    // MARK: - GPU Test
    private func gpuTest() async throws -> BenchmarkResult {
        await MainActor.run {
            self.currentTest = "GPU 测试"
        }

        guard let device = MTLCreateSystemDefaultDevice() else {
            throw BenchmarkError.noGPU
        }

        let startTime = Date()
        let duration: TimeInterval = 15

        // 简单的 GPU 计算
        let commandQueue = device.makeCommandQueue()
        var frameCount = 0

        while Date().timeIntervalSince(startTime) < duration {
            autoreleasepool {
                let commandBuffer = commandQueue?.makeCommandBuffer()
                let renderPassDescriptor = MTLRenderPassDescriptor()

                // 创建简单的渲染编码器（模拟）
                if let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                    encoder.endEncoding()
                }

                commandBuffer?.commit()
                commandBuffer?.waitUntilCompleted()

                frameCount += 1
            }
        }

        let actualDuration = Date().timeIntervalSince(startTime)
        let fps = Double(frameCount) / actualDuration

        return BenchmarkResult(
            name: "GPU",
            score: fps * 1000, // 转换为分数
            unit: "FPS",
            duration: actualDuration
        )
    }

    // MARK: - Memory Test
    private func memoryTest() async throws -> BenchmarkResult {
        await MainActor.run {
            self.currentTest = "内存测试"
        }

        let startTime = Date()
        let duration: TimeInterval = 10
        let blockSize = 1024 * 1024 // 1MB

        var totalBytes: UInt64 = 0

        while Date().timeIntervalSince(startTime) < duration {
            autoreleasepool {
                // 分配和写入内存
                if let memory = malloc(blockSize) {
                    memset(memory, 0xAA, blockSize)
                    // 读取验证
                    let ptr = memory.assumingMemoryBound(to: UInt8.self)
                    for i in 0..<blockSize {
                        if ptr[i] != 0xAA { break }
                    }
                    free(memory)
                    totalBytes += UInt64(blockSize)
                }
            }
        }

        let actualDuration = Date().timeIntervalSince(startTime)
        let bandwidth = Double(totalBytes) / actualDuration / (1024 * 1024 * 1024) // GB/s

        return BenchmarkResult(
            name: "内存",
            score: bandwidth * 1000,
            unit: "GB/s",
            duration: actualDuration
        )
    }

    // MARK: - Storage Test
    private func storageTest() async throws -> BenchmarkResult {
        await MainActor.run {
            self.currentTest = "存储测试"
        }

        let startTime = Date()
        let fileSize = 10 * 1024 * 1024 // 10MB
        let testData = Data(repeating: 0xAA, count: fileSize)

        // 写入测试
        let tempDir = FileManager.default.temporaryDirectory
        let testFile = tempDir.appendingPathComponent("benchmark_test.dat")

        do {
            try testData.write(to: testFile)

            // 读取测试
            let _ = try Data(contentsOf: testFile)

            // 删除测试文件
            try? FileManager.default.removeItem(at: testFile)
        } catch {
            throw BenchmarkError.storageFailed
        }

        let actualDuration = Date().timeIntervalSince(startTime)
        let speed = Double(fileSize * 2) / actualDuration / (1024 * 1024) // MB/s (write + read)

        return BenchmarkResult(
            name: "存储",
            score: speed,
            unit: "MB/s",
            duration: actualDuration
        )
    }

    // MARK: - Benchmark Type
    enum BenchmarkType {
        case quick
        case full
    }

    // MARK: - Errors
    enum BenchmarkError: Error {
        case noGPU
        case storageFailed
    }
}
