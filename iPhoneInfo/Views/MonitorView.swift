//
//  MonitorView.swift
//  iPhoneInfo
//
//  Real-time system monitoring view
//

import SwiftUI

struct MonitorView: View {
    @StateObject private var monitor = SystemMonitor()
    @State private var selectedTab: MonitorTab = .all

    enum MonitorTab: String, CaseIterable {
        case all = "全部"
        case cpu = "CPU"
        case memory = "内存"
        case gpu = "GPU"
        case battery = "电池"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Tab Picker
                    Picker("Monitor Tab", selection: $selectedTab) {
                        ForEach(MonitorTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Monitor Cards
                    switch selectedTab {
                    case .all:
                        AllMonitorsView(monitor: monitor)
                    case .cpu:
                        CPUMonitorCard(cpuUsage: monitor.cpuUsage)
                    case .memory:
                        MemoryMonitorCard(memoryUsage: monitor.memoryUsage)
                    case .gpu:
                        GPUMonitorCard(gpuUsage: monitor.gpuUsage)
                    case .battery:
                        BatteryMonitorCard(batteryLevel: monitor.batteryLevel, temperature: monitor.temperature)
                    }

                    // Update Interval Info
                    Text("刷新间隔: 1 秒")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical)
            }
            .navigationTitle("实时监控")
            .onAppear {
                monitor.startMonitoring()
            }
            .onDisappear {
                monitor.stopMonitoring()
            }
        }
    }
}

// MARK: - All Monitors View
struct AllMonitorsView: View {
    @ObservedObject var monitor: SystemMonitor

    var body: some View {
        VStack(spacing: 16) {
            CPUMonitorCard(cpuUsage: monitor.cpuUsage)
            MemoryMonitorCard(memoryUsage: monitor.memoryUsage)
            GPUMonitorCard(gpuUsage: monitor.gpuUsage)
            BatteryMonitorCard(batteryLevel: monitor.batteryLevel, temperature: monitor.temperature)
        }
        .padding(.horizontal)
    }
}

// MARK: - CPU Monitor Card
struct CPUMonitorCard: View {
    let cpuUsage: Double

    var body: some View {
        MonitorCard(icon: "cpu", title: "CPU 使用率", color: .blue) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 12)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: cpuUsage / 100.0)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(), value: cpuUsage)

                    Text("\(Int(cpuUsage))%")
                        .font(.title)
                        .fontWeight(.bold)
                }

                MiniChart(data: generateDummyData())
                    .frame(height: 40)
            }
        }
    }

    private func generateDummyData() -> [Double] {
        (0..<20).map { _ in Double.random(in: 20...80) }
    }
}

// MARK: - Memory Monitor Card
struct MemoryMonitorCard: View {
    let memoryUsage: Double

    var body: some View {
        MonitorCard(icon: "memorychip", title: "内存使用率", color: .purple) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 12)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: memoryUsage / 100.0)
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(), value: memoryUsage)

                    Text("\(Int(memoryUsage))%")
                        .font(.title)
                        .fontWeight(.bold)
                }

                MiniChart(data: generateDummyData())
                    .frame(height: 40)
            }
        }
    }

    private func generateDummyData() -> [Double] {
        (0..<20).map { _ in Double.random(in: 40...70) }
    }
}

// MARK: - GPU Monitor Card
struct GPUMonitorCard: View {
    let gpuUsage: Double

    var body: some View {
        MonitorCard(icon: "cube", title: "GPU 使用率", color: .green) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 12)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: gpuUsage / 100.0)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(), value: gpuUsage)

                    Text("\(Int(gpuUsage))%")
                        .font(.title)
                        .fontWeight(.bold)
                }

                MiniChart(data: generateDummyData())
                    .frame(height: 40)
            }
        }
    }

    private func generateDummyData() -> [Double] {
        (0..<20).map { _ in Double.random(in: 10...50) }
    }
}

// MARK: - Battery Monitor Card
struct BatteryMonitorCard: View {
    let batteryLevel: Double
    let temperature: Double

    var body: some View {
        MonitorCard(icon: "battery.100percent", title: "电池状态", color: .orange) {
            VStack(spacing: 12) {
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text("\(Int(batteryLevel))%")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("电量")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack(spacing: 4) {
                        Text(String(format: "%.0f°C", temperature))
                            .font(.title)
                            .fontWeight(.bold)
                        Text("温度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                MiniChart(data: generateDummyData())
                    .frame(height: 40)
            }
        }
    }

    private func generateDummyData() -> [Double] {
        (0..<20).map { _ in Double.random(in: 30...40) }
    }
}

// MARK: - Monitor Card
struct MonitorCard<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: Content

    init(icon: String, title: String, color: Color, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.color = color
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                Spacer()
            }

            content
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Mini Chart
struct MiniChart: View {
    let data: [Double]

    var body: some View {
        GeometryReader { geometry in
            let max = data.max() ?? 1
            let min = data.min() ?? 0
            let range = max - min

            ZStack {
                // Chart line
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let step = width / CGFloat(data.count - 1)

                    var x: CGFloat = 0
                    path.move(to: CGPoint(x: 0, y: height))

                    for value in data {
                        let normalizedValue = range > 0 ? (value - min) / range : 0.5
                        let y = height - (CGFloat(normalizedValue) * height)
                        path.addLine(to: CGPoint(x: x, y: y))
                        x += step
                    }
                }
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
            }
        }
    }
}

// MARK: - System Monitor
class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0
    @Published var memoryUsage: Double = 0
    @Published var gpuUsage: Double = 0
    @Published var batteryLevel: Double = 82
    @Published var temperature: Double = 36

    private var timer: Timer?

    func startMonitoring() {
        updateMetrics()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateMetrics()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func updateMetrics() {
        // Simulate real-time data
        cpuUsage = Double.random(in: 20...60)
        memoryUsage = Double.random(in: 50...70)
        gpuUsage = Double.random(in: 10...40)
        batteryLevel = max(0, batteryLevel - Double.random(in: 0...0.1))
    }
}

#Preview {
    MonitorView()
}
