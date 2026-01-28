//
//  TodoTask.swift
//  Shared
//
//  Purpose: Defines the TodoTask model for SwiftData persistence
//  Shared between main app and widget extension.
//

import Foundation
import SwiftData

/// Represents a task in the to-do list
///
/// Tasks can be either one-time (regular) or recurring daily.
/// - Regular tasks: Completed once and then removed from today's list permanently
/// - Recurring tasks: Reappear each day even after completion
@Model
final class TodoTask {

    // MARK: - Properties

    /// Unique identifier for the task
    var id: UUID

    /// The user-visible title of the task
    var title: String

    /// Optional category for organizing tasks
    var category: String?

    /// Flag indicating if this task repeats daily
    var isRecurring: Bool

    /// Date when the task was created
    var createdAt: Date

    /// Sort order for manual task reordering
    var sortOrder: Int

    /// Flag indicating if the task is active (not deleted)
    var isActive: Bool

    /// Relationship to completion records
    @Relationship(deleteRule: .cascade, inverse: \TaskCompletion.task)
    var completions: [TaskCompletion]?

    // MARK: - Initialization

    init(
        title: String,
        category: String? = nil,
        isRecurring: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.isRecurring = isRecurring
        self.createdAt = Date()
        self.sortOrder = sortOrder
        self.isActive = true
        self.completions = []
    }

    // MARK: - Methods

    /// Checks if the task has been completed today
    func isCompletedToday() -> Bool {
        guard let completions = completions else { return false }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return completions.contains { completion in
            calendar.startOfDay(for: completion.completedAt) == today
        }
    }
}
