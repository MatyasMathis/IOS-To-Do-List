//
//  SharedModelContainer.swift
//  Tick
//
//  Purpose: Provides a shared SwiftData container accessible by both
//  the main app and the widget extension via App Groups.
//

import SwiftData
import Foundation

/// Shared model container for cross-target data access
///
/// Uses an App Group container to store the SQLite database in a location
/// accessible by both the main app and the widget extension.
enum SharedModelContainer {
    /// The App Group identifier shared between app and widget
    static let appGroupIdentifier = "group.com.tick.shared"

    /// Shared model container using App Group storage
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TodoTask.self,
            TaskCompletion.self
        ])

        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            fatalError("Failed to get App Group container URL for \(appGroupIdentifier)")
        }

        let storeURL = containerURL.appendingPathComponent("tick.sqlite")

        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create shared ModelContainer: \(error)")
        }
    }()
}
