//
//  dailytodolistApp.swift
//  dailytodolist
//
//  Created by Mathis Matyas-Istvan on 24.01.2026.
//
//  Purpose: Main entry point for the Daily To-Do List app
//  Key responsibilities:
//  - Configure SwiftData model container for persistence
//  - Set up the main app window with tab navigation
//

import SwiftUI
import SwiftData

/// Main application entry point
///
/// Configures the SwiftData persistence layer and sets up the root view.
/// The ModelContainer is created with both Task and TaskCompletion models,
/// enabling automatic data persistence and relationships between them.
@main
struct dailytodolistApp: App {

    /// SwiftData model container for persistence
    ///
    /// Contains the schema for Task and TaskCompletion models.
    /// SwiftData automatically handles:
    /// - Creating the SQLite database
    /// - Managing object relationships
    /// - Tracking changes and saving
    var sharedModelContainer: ModelContainer = {
        // Define the schema with all model types
        // Order matters for relationship resolution
        let schema = Schema([
            TodoTask.self,
            TaskCompletion.self
        ])

        // Configure model container with default settings
        // isStoredInMemoryOnly: false ensures data persists between app launches
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            // Fatal error if database cannot be created
            // This typically indicates a schema migration issue or disk space problem
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        // Inject the model container into the environment
        // All child views can access it via @Environment(\.modelContext)
        .modelContainer(sharedModelContainer)
    }
}
