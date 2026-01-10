//
//  DeviceDebugView.swift
//  iPhoneInfo
//
//  调试页面 - 显示真实的设备信息
//

import SwiftUI
import UIKit

struct DeviceDebugView: View {
    @State private var deviceModel = ""
    @State private var machineName = ""
    @State private var allInfo: [String: String] = [:]

    var body: some View {
        NavigationView {
            List {
                Section("设备标识") {
                    Row(label: "Device Model", value: UIDevice.current.model)
                    Row(label: "Device Name", value: UIDevice.current.name)
                    Row(label: "System Name", value: UIDevice.current.systemName)
                    Row(label: "System Version", value: UIDevice.current.systemVersion)
                    Row(label: "Localized Model", value: UIDevice.current.localizedModel)
                }

                Section("hw.machine (真实型号)") {
                    Text(machineName)
                        .font(.system(.body, design: .monospaced))
                }

                Section("所有硬件信息") {
                    ForEach(Array(allInfo.keys.sorted()), id: \.self) { key in
                        HStack {
                            Text(key)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(allInfo[key] ?? "")
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                }

                Section("操作") {
                    Button("刷新信息") {
                        loadDeviceInfo()
                    }
                }
            }
            .navigationTitle("设备调试信息")
            .onAppear {
                loadDeviceInfo()
            }
        }
    }

    struct Row: View {
        let label: String
        let value: String

        var body: some View {
            HStack {
                Text(label)
                Spacer()
                Text(value)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func loadDeviceInfo() {
        // 获取 hw.machine
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        machineName = String(cString: machine)

        // 获取更多硬件信息
        let keys = [
            "hw.machine",
            "hw.model",
            "hw.ncpu",
            "hw.physicalcpu",
            "hw.logicalcpu",
            "hw.memsize",
            "hw.byteorder",
            "hw.targettype",
            "machdep.cpu.brand_string",
            "machdep.cpu.family",
            "machdep.cpu.model",
            "machdep.cpu.stepping",
            "machdep.cpu.vendor"
        ]

        for key in keys {
            size = 0
            sysctlbyname(key, nil, &size, nil, 0)
            if size > 0 {
                var value = [CChar](repeating: 0, count: size)
                sysctlbyname(key, &value, &size, nil, 0)
                let str = String(cString: value)
                allInfo[key] = str.isEmpty ? "\(size) bytes" : str
            }
        }
    }
}

#Preview {
    DeviceDebugView()
}
