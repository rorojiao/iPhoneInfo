//
//  iPhoneInfoApp.swift
//  iPhoneInfo
//
//  Created on 2026-01-10.
//

import SwiftUI

@main
struct iPhoneInfoApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    setupApp()
                }
        }
    }

    private func setupApp() {
        // 启用电池监控
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
}

// 全局应用状态
class AppState: ObservableObject {
    @Published var currentTab: AppTab = .home
    @Published var isBenchmarking = false
    @Published var showSettings = false
}

enum AppTab: String, CaseIterable {
    case home = "首页"
    case benchmark = "测试"
    case monitor = "监控"
    case compare = "对比"
    case settings = "设置"
    case debug = "调试"

    var icon: String {
        switch self {
        case .home: return "info.circle.fill"
        case .benchmark: return "chart.bar.fill"
        case .monitor: return "gauge.with.dots.needle.67percent"
        case .compare: return "chart.xyaxis.line"
        case .settings: return "gearshape.fill"
        case .debug: return "ladybug.fill"
        }
    }
}
