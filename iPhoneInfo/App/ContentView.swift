//
//  ContentView.swift
//  iPhoneInfo
//
//  Main tab-based navigation view
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(AppTab.home.rawValue, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)

            BenchmarkView()
                .tabItem {
                    Label(AppTab.benchmark.rawValue, systemImage: AppTab.benchmark.icon)
                }
                .tag(AppTab.benchmark)

            MonitorView()
                .tabItem {
                    Label(AppTab.monitor.rawValue, systemImage: AppTab.monitor.icon)
                }
                .tag(AppTab.monitor)

            CompareView()
                .tabItem {
                    Label(AppTab.compare.rawValue, systemImage: AppTab.compare.icon)
                }
                .tag(AppTab.compare)

            SettingsView()
                .tabItem {
                    Label(AppTab.settings.rawValue, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)

            DeviceDebugView()
                .tabItem {
                    Label(AppTab.debug.rawValue, systemImage: AppTab.debug.icon)
                }
                .tag(AppTab.debug)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
