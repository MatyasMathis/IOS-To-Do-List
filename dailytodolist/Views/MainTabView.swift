//
//  MainTabView.swift
//  dailytodolist
//
//  Purpose: Root view providing tab-based navigation
//  Key responsibilities:
//  - Provide tab navigation between Today and History views
//  - Manage tab selection state
//  - Serve as the main entry point for the app UI
//

import SwiftUI
import SwiftData

/// Root view that provides tab-based navigation for the app
///
/// Contains two tabs:
/// 1. Today - Shows current day's tasks (TaskListView)
/// 2. History - Shows completed tasks history (HistoryView)
///
/// The tab selection persists during the app session but resets to
/// the Today tab when the app is relaunched.
struct MainTabView: View {

    // MARK: - State

    /// Currently selected tab
    /// Defaults to the Today tab (index 0)
    @State private var selectedTab: Int = 0

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: Today Tab
            TaskListView()
                .tabItem {
                    Label("Today", systemImage: "checkmark.circle")
                }
                .tag(0)

            // MARK: History Tab
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
