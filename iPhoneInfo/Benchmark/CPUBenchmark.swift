//
//  CPUBenchmark.swift
//  iPhoneInfo
//
//  CPU performance benchmark implementation
//

import Foundation

// MARK: - CPU Benchmark Result
struct CPUBenchmarkResult {
    let singleCoreScore: Int
    let multiCoreScore: Int
    let integerScore: Int
    let floatScore: Int
    let cryptoScore: Int
    let totalScore: Int

    var grade: String {
        switch totalScore {
        case 0..<3000: return "D"
        case 3000..<6000: return "C"
        case 6000..<10000: return "B"
        case 10000..<15000: return "A"
        case 15000...Int.max: return "S"
        default: return "D"
        }
    }

    var description: String {
        return """
        CPU 性能测试结果:

        单核得分: \(singleCoreScore)
        多核得分: \(multiCoreScore)
        整数运算: \(integerScore)
        浮点运算: \(floatScore)
        加密性能: \(cryptoScore)

        综合得分: \(totalScore)
        等级: \(grade)
        """
    }
}

// MARK: - CPU Benchmark
class CPUBenchmark {

    // MARK: - Single Core Test
    func runSingleCoreTest() -> Int {
        let operations = 10_000_000
        let startTime = Date()

        var count = 0
        for _ in 0..<operations {
            if isPrime(count) {
                // Count primes
            }
            count += 1
        }

        let elapsed = Date().timeIntervalSince(startTime)
        let score = Int(Double(operations) / elapsed)
        return score
    }

    // MARK: - Multi Core Test
    func runMultiCoreTest() -> Int {
        let processorCount = ProcessInfo.processInfo.processorCount
        let operationsPerCore = 5_000_000
        let startTime = Date()

        let group = DispatchGroup()
        var scores: [Int] = []

        for _ in 0..<processorCount {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                let score = self.runSingleCoreTestLimited(operationsPerCore)
                DispatchQueue.main.async {
                    scores.append(score)
                    group.leave()
                }
            }
        }

        group.wait()

        let totalScore = scores.reduce(0, +)
        let elapsed = Date().timeIntervalSince(startTime)

        return elapsed > 0 ? Int(Double(totalScore) / elapsed) : 0
    }

    private func runSingleCoreTestLimited(_ operations: Int) -> Int {
        var count = 0
        var primeCount = 0
        for _ in 0..<operations {
            if isPrime(count) {
                primeCount += 1
            }
            count += 1
        }
        return primeCount
    }

    // MARK: - Integer Operations Test
    func runIntegerTest() -> Int {
        let iterations = 1_000_000
        let startTime = Date()

        var result = 0
        for _ in 0..<iterations {
            // Bitwise operations
            result = result ^ 0xFFFFFFFF
            result = result & 0x12345678
            result = result | 0x87654321

            // Arithmetic operations
            result += 12345
            result *= 2
            result -= 6172
            result /= 3

            // Hash calculation
            result = Int(bitPattern: UInt32(result).hashValue)
        }

        let elapsed = Date().timeIntervalSince(startTime)
        return Int(Double(iterations * 10) / elapsed)
    }

    // MARK: - Floating Point Test
    func runFloatTest() -> Int {
        let iterations = 1_000_000
        let startTime = Date()

        var result: Double = 0.0
        for i in 0..<iterations {
            // Trigonometric functions
            result += sin(Double(i))
            result += cos(Double(i))
            result += tan(Double(i))

            // Square root
            result += sqrt(Double(i))

            // Logarithm
            if i > 0 {
                result += log(Double(i))
            }

            // Power
            result += pow(Double(i % 100), 2.0)
        }

        let elapsed = Date().timeIntervalSince(startTime)
        return Int(Double(iterations) / elapsed)
    }

    // MARK: - Cryptography Test
    func runCryptoTest() -> Int {
        let iterations = 100_000
        let startTime = Date()

        var totalBytes = 0
        for _ in 0..<iterations {
            let data = "TestStringForEncryption\(iterations)".data(using: .utf8)!

            // Simple hash simulation
            var hash: UInt32 = 0
            for byte in data {
                hash = hash &* 31 &+ byte
            }

            totalBytes += data.count
        }

        let elapsed = Date().timeIntervalSince(startTime)
        return Int(Double(totalBytes) / elapsed * 100)
    }

    // MARK: - Full Benchmark
    func runFullBenchmark() -> CPUBenchmarkResult {
        let singleCoreScore = runSingleCoreTest()
        let multiCoreScore = runMultiCoreTest()
        let integerScore = runIntegerTest()
        let floatScore = runFloatTest()
        let cryptoScore = runCryptoTest()

        // Calculate weighted total score
        let totalScore = Int(
            Double(singleCoreScore) * 0.2 +
            Double(multiCoreScore) * 0.3 +
            Double(integerScore) * 0.15 +
            Double(floatScore) * 0.25 +
            Double(cryptoScore) * 0.1
        )

        return CPUBenchmarkResult(
            singleCoreScore: singleCoreScore,
            multiCoreScore: multiCoreScore,
            integerScore: integerScore,
            floatScore: floatScore,
            cryptoScore: cryptoScore,
            totalScore: totalScore
        )
    }

    // MARK: - Quick Test
    func runQuickTest() -> CPUBenchmarkResult {
        let singleCoreScore = runSingleCoreTest()
        let multiCoreScore = runMultiCoreTest()

        // Simplified calculation for quick test
        let totalScore = (singleCoreScore + multiCoreScore) / 2

        return CPUBenchmarkResult(
            singleCoreScore: singleCoreScore,
            multiCoreScore: multiCoreScore,
            integerScore: totalScore,
            floatScore: totalScore,
            cryptoScore: totalScore,
            totalScore: totalScore
        )
    }

    // MARK: - Helper Functions
    private func isPrime(_ n: Int) -> Bool {
        if n <= 1 { return false }
        if n <= 3 { return true }
        if n % 2 == 0 || n % 3 == 0 { return false }

        var i = 5
        while i * i <= n {
            if n % i == 0 || n % (i + 2) == 0 {
                return false
            }
            i += 6
        }
        return true
    }
}
