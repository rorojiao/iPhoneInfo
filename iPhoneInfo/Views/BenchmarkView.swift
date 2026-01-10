//
//  BenchmarkView.swift
//  iPhoneInfo
//
//  Performance benchmark testing view
//

import SwiftUI

struct BenchmarkView: View {
    @State private var selectedTestType: TestType = .quick
    @State private var isRunning = false
    @State private var progress: Double = 0

    enum TestType: String, CaseIterable {
        case quick = "快速测试"
        case full = "完整测试"
        case custom = "自定义"
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

                    // Test Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("测试项目")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            TestItemRow(icon: "cpu", name: "CPU 单核测试", duration: "~30秒")
                            Divider()
                            TestItemRow(icon: "cpu.fill", name: "CPU 多核测试", duration: "~30秒")
                            Divider()
                            TestItemRow(icon: "cube", name: "GPU Manhattan 3.0", duration: "~2.5分钟")
                            Divider()
                            TestItemRow(icon: "cube.fill", name: "GPU Aztec Ruins", duration: "~2.5分钟")
                            Divider()
                            TestItemRow(icon: "memorychip", name: "内存测试", duration: "~1分钟")
                            Divider()
                            TestItemRow(icon: "internaldrive", name: "存储测试", duration: "~1分钟")
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Device Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("设备状态")
                            .font(.headline)
                            .padding(.horizontal)

                        HStack(spacing: 30) {
                            StatusItem(icon: "battery.100percent", label: "电量", value: "82%")
                            StatusItem(icon: "thermometer", label: "温度", value: "36°C")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Start Button
                    Button(action: {
                        startBenchmark()
                    }) {
                        VStack(spacing: 8) {
                            if isRunning {
                                ProgressView()
                                    .tint(.white)
                                Text("测试中...")
                            } else {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                Text("开始测试")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRunning ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(isRunning)

                    // Test Info
                    VStack(alignment: .leading, spacing: 8) {
                        InfoBullet(text: "预计耗时: 约 \(estimatedTime)")
                        InfoBullet(text: "建议充电使用以获得最佳结果")
                        InfoBullet(text: "测试期间请保持屏幕常亮")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("性能测试")
        }
    }

    private var estimatedTime: String {
        switch selectedTestType {
        case .quick: return "2 分钟"
        case .full: return "10 分钟"
        case .custom: return "自定义"
        }
    }

    private func startBenchmark() {
        isRunning = true
        // TODO: Implement actual benchmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isRunning = false
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

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
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
