//
//  BenchmarkView.swift
//  iPhoneInfo
//
//  Performance benchmark testing view
//

import SwiftUI

struct BenchmarkView: View {
    @StateObject private var benchmarkService = BenchmarkService.shared
    @State private var selectedTestType: TestType = .quick
    @State private var showingResults = false

    enum TestType: String, CaseIterable {
        case quick = "快速测试"
        case full = "完整测试"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Test Type Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("选择测试类型")
                            .font(.headline)
                            .padding(.horizontal)

                        Picker("Test Type", selection: $selectedTestType) {
                            ForEach(TestType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }

                    // Progress Section
                    if benchmarkService.isRunning {
                        VStack(spacing: 16) {
                            Text(benchmarkService.currentTest)
                                .font(.title3)
                                .fontWeight(.medium)

                            ProgressView(value: benchmarkService.progress)
                                .progressViewStyle(.linear)

                            Text("\(Int(benchmarkService.progress * 100))%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Results Section
                    if !benchmarkService.results.isEmpty && !benchmarkService.isRunning {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("测试结果")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                ForEach(benchmarkService.results.indices, id: \.self) { index in
                                    let result = benchmarkService.results[index]

                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(result.name)
                                                .font(.subheadline)
                                            Text("\(Int(result.duration))秒")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(result.formattedScore)
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.blue)
                                            Text(result.unit)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()

                                    if index < benchmarkService.results.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }

                    // Test Items (Info Only)
                    if !benchmarkService.isRunning && benchmarkService.results.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("测试项目")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                TestItemRow(icon: "cpu", name: "CPU 单核测试", duration: selectedTestType == .quick ? "10秒" : "10秒")
                                if selectedTestType == .full {
                                    Divider()
                                    TestItemRow(icon: "cpu.fill", name: "CPU 多核测试", duration: "10秒")
                                    Divider()
                                    TestItemRow(icon: "cube", name: "GPU 渲染测试", duration: "15秒")
                                }
                                Divider()
                                TestItemRow(icon: "memorychip", name: "内存读写测试", duration: "10秒")
                                if selectedTestType == .full {
                                    Divider()
                                    TestItemRow(icon: "internaldrive", name: "存储读写测试", duration: "~5秒")
                                }
                            }
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }

                    // Device Status
                    if !benchmarkService.isRunning {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("设备状态")
                                .font(.headline)
                                .padding(.horizontal)

                            HStack(spacing: 30) {
                                StatusItem(icon: "battery.100", label: "电量", value: "\(Int(UIDevice.current.batteryLevel * 100))%")
                                StatusItem(icon: "thermometer", label: "温度", value: "\(Int(ThermalService.shared.currentTemperature))°C")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }

                    // Start Button
                    if !benchmarkService.isRunning {
                        Button(action: {
                            startBenchmark()
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                Text("开始测试")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }

                    // Test Info
                    if benchmarkService.results.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            InfoBullet(text: "预计耗时: \(estimatedTime)")
                            InfoBullet(text: "建议充电使用以获得最佳结果")
                            InfoBullet(text: "测试期间请保持屏幕常亮")
                            InfoBullet(text: "测试将真实运行计算密集型任务")
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("性能测试")
        }
    }

    private var estimatedTime: String {
        switch selectedTestType {
        case .quick: return "约 30 秒"
        case .full: return "约 1 分钟"
        }
    }

    private func startBenchmark() {
        let type: BenchmarkService.BenchmarkType = selectedTestType == .quick ? .quick : .full
        benchmarkService.runBenchmark(type: type) {
            // 测试完成
        }
    }
}

struct TestItemRow: View {
    let icon: String
    let name: String
    let duration: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                Text(duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "clock")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .contentShape(Rectangle())
    }
}

struct StatusItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}

struct InfoBullet: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    BenchmarkView()
}
