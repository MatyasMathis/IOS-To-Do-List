//
//  TickApp.swift
//  Tick
//
//  Created by Mathis Matyas-Istvan on 24.01.2026.
//
//  Purpose: Main entry point for the Tick app
//  Key responsibilities:
//  - Configure SwiftData model container for persistence (shared with widget)
//  - Set up the main app window with tab navigation
//  - Handle deep links from widget
//

import SwiftUI
import SwiftData

/// Notification posted when the app should navigate to the Tasks tab
extension Notification.Name {
    static let navigateToTasks = Notification.Name("navigateToTasks")
}

/// Main application entry point
///
/// Configures the SwiftData persistence layer and sets up the root view.
/// Uses SharedModelContainer to share data with the widget extension.
@main
struct TickApp: App {

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        // Use shared model container for widget data access
        .modelContainer(SharedModelContainer.sharedModelContainer)
    }

    /// Handles deep links from the widget
    ///
    /// URL scheme: tick://tasks
    /// Posts a notification to navigate to the tasks tab.
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "tick" else { return }

        switch url.host {
        case "tasks":
            NotificationCenter.default.post(
                name: .navigateToTasks,
                object: nil
            )
        default:
            break
        }
    }
}
