import Foundation
import Network

final class NetworkLatencyService: ObservableObject {
    static let shared = NetworkLatencyService()

    struct Target: Equatable {
        let host: String
        let port: UInt16

        static let `default` = Target(host: "www.apple.com", port: 443)
    }

    struct Sample: Identifiable {
        let id = UUID()
        let timestamp: Date
        let latencyMs: Double
    }

    struct Summary {
        let latencyMs: Double?
        let jitterMs: Double?
        let lossPercent: Double?
        let samplesCount: Int
    }

    @Published var isMonitoring: Bool = false
    @Published var target: Target = .default

    @Published var latestLatencyMs: Double?
    @Published var jitterMs: Double?
    @Published var lossPercent: Double?
    @Published var statusText: String = "等待检测"

    @Published var recentSamples: [Sample] = []

    private let queue = DispatchQueue(label: "NetworkLatencyService.queue")
    private var timer: DispatchSourceTimer?

    private var totalAttempts: Int = 0
    private var totalFailures: Int = 0

    private init() {}

    func startMonitoring(target: Target = .default, interval: TimeInterval = 1.5, maxSamples: Int = 30) {
        guard !isMonitoring else { return }

        self.target = target
        isMonitoring = true
        statusText = "检测中..."

        totalAttempts = 0
        totalFailures = 0
        recentSamples.removeAll()

        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: interval)
        timer.setEventHandler { [weak self] in
            self?.takeSample(maxSamples: maxSamples)
        }
        self.timer = timer
        timer.resume()
    }

    func stopMonitoring() {
        timer?.cancel()
        timer = nil

        DispatchQueue.main.async {
            self.isMonitoring = false
            self.statusText = "已停止"
        }
    }

    func currentSummary() -> Summary {
        let samples = recentSamples.map { $0.latencyMs }
        let latency = samples.last
        let jitter = computeJitterMs(samples)

        let loss: Double? = {
            guard totalAttempts > 0 else { return nil }
            return Double(totalFailures) / Double(totalAttempts) * 100.0
        }()

        return Summary(latencyMs: latency, jitterMs: jitter, lossPercent: loss, samplesCount: samples.count)
    }

    private func takeSample(maxSamples: Int) {
        totalAttempts += 1

        let start = Date()
        let endpointHost = NWEndpoint.Host(target.host)
        let endpointPort = NWEndpoint.Port(rawValue: target.port) ?? 443

        let connection = NWConnection(host: endpointHost, port: endpointPort, using: .tcp)

        var completed = false

        func finishFailure(reason: String) {
            guard !completed else { return }
            completed = true
            totalFailures += 1
            connection.cancel()

            DispatchQueue.main.async {
                self.latestLatencyMs = nil
                self.statusText = reason
                self.recomputeDerivedMetrics()
            }
        }

        func finishSuccess(latencyMs: Double) {
            guard !completed else { return }
            completed = true
            connection.cancel()

            DispatchQueue.main.async {
                self.latestLatencyMs = latencyMs
                self.statusText = "稳定"
                self.recentSamples.append(Sample(timestamp: Date(), latencyMs: latencyMs))
                if self.recentSamples.count > maxSamples {
                    self.recentSamples.removeFirst(self.recentSamples.count - maxSamples)
                }
                self.recomputeDerivedMetrics()
            }
        }

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                let elapsed = Date().timeIntervalSince(start) * 1000.0
                finishSuccess(latencyMs: elapsed)
            case .failed:
                finishFailure(reason: "连接失败")
            case .waiting:
                finishFailure(reason: "网络不可用")
            case .cancelled:
                break
            default:
                break
            }
        }

        connection.start(queue: queue)

        queue.asyncAfter(deadline: .now() + 2.5) {
            finishFailure(reason: "超时")
        }
    }

    private func recomputeDerivedMetrics() {
        let samples = recentSamples.map { $0.latencyMs }
        jitterMs = computeJitterMs(samples)

        if totalAttempts > 0 {
            lossPercent = Double(totalFailures) / Double(totalAttempts) * 100.0
        } else {
            lossPercent = nil
        }
    }

    private func computeJitterMs(_ samples: [Double]) -> Double? {
        guard samples.count >= 2 else { return nil }
        var diffs: [Double] = []
        diffs.reserveCapacity(samples.count - 1)
        for i in 1..<samples.count {
            diffs.append(abs(samples[i] - samples[i - 1]))
        }
        return diffs.reduce(0, +) / Double(diffs.count)
    }
}
