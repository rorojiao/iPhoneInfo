//
//  SettingsView.swift
//  iPhoneInfo
//
//  Settings view
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("testDuration") private var testDuration = 2.0
    @AppStorage("testResolution") private var testResolution = 0
    @AppStorage("enableCloudSync") private var enableCloudSync = false
    @AppStorage("anonymousUpload") private var anonymousUpload = true
    @AppStorage("useDarkMode") private var useDarkMode = 0

    var body: some View {
        NavigationView {
            List {
                // Test Configuration
                Section("测试配置") {
                    Picker("测试时长", selection: $testDuration) {
                        Text("1 分钟").tag(1.0)
                        Text("2 分钟").tag(2.0)
                        Text("5 分钟").tag(5.0)
                    }

                    Picker("测试分辨率", selection: $testResolution) {
                        Text("自动").tag(0)
                        Text("1080p").tag(1)
                        Text("原生").tag(2)
                    }
                }

                // Data & Privacy
                Section("数据与隐私") {
                    Toggle("云端同步", isOn: $enableCloudSync)
                    Toggle("匿名上传", isOn: $anonymousUpload)

                    NavigationLink("导出数据") {
                        DataExportView()
                    }

                    NavigationLink("清除历史") {
                        ClearHistoryView()
                    }
                }

                // Display
                Section("显示") {
                    Picker("外观模式", selection: $useDarkMode) {
                        Text("跟随系统").tag(0)
                        Text("浅色模式").tag(1)
                        Text("深色模式").tag(2)
                    }
                }

                // About
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    NavigationLink("用户协议") {
                        Text("用户协议内容")
                    }

                    NavigationLink("隐私政策") {
                        Text("隐私政策内容")
                    }

                    NavigationLink("开源协议") {
                        Text("开源协议内容")
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

// MARK: - Data Export View
struct DataExportView: View {
    var body: some View {
        List {
            Button("导出为 CSV") {
                // TODO: Implement CSV export
            }
            Button("导出为 JSON") {
                // TODO: Implement JSON export
            }
            Button("导出为 PDF") {
                // TODO: Implement PDF export
            }
        }
        .navigationTitle("导出数据")
    }
}

// MARK: - Clear History View
struct ClearHistoryView: View {
    @State private var showConfirmation = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trash.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("清除历史记录")
                .font(.title2)
                .fontWeight(.bold)

            Text("此操作将删除所有测试历史记录，无法恢复。")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("确认删除") {
                showConfirmation = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)

            Spacer()
        }
        .padding()
        .navigationTitle("清除历史")
        .alert("确认删除", isPresented: $showConfirmation) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                // TODO: Implement clear history
            }
        } message: {
            Text("确定要删除所有历史记录吗？此操作无法撤销。")
        }
    }
}

#Preview {
    SettingsView()
}
