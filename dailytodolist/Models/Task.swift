//
//  Task.swift
//  dailytodolist
//
//  Purpose: Defines the TodoTask model for SwiftData persistence
//  Key responsibilities:
//  - Store task properties (title, category, recurring flag)
//  - Track task creation and ordering
//  - Determine if task is completed for the current day
//
//  Note: Named "TodoTask" instead of "Task" to avoid collision with
//  Swift's built-in Task type for concurrency.
//

import Foundation
import SwiftData

/// Represents a task in the to-do list
///
/// Tasks can be either one-time (regular) or recurring daily.
/// - Regular tasks: Completed once and then removed from today's list permanently
/// - Recurring tasks: Reappear each day even after completion
///
/// The TodoTask model serves as a template - actual completions are tracked
/// separately in TaskCompletion records to enable history tracking.
@Model
final class TodoTask {

    // MARK: - Properties

    /// Unique identifier for the task
    /// Generated automatically on creation
    var id: UUID

    /// The user-visible title of the task
    /// This is the main text displayed in the task list
    var title: String

    /// Optional category for organizing tasks
    /// Examples: "Work", "Personal", "Health", etc.
    var category: String?

    /// Flag indicating if this task repeats daily
    /// When true, task reappears every day even after completion
    /// When false, task is a one-time item that won't return after completion
    var isRecurring: Bool

    /// Date when the task was created
    /// Used for sorting and history purposes
    var createdAt: Date

    /// Sort order for manual task reordering
    /// Lower values appear first in the list
    /// Updated when user drags tasks to reorder
    var sortOrder: Int

    /// Flag indicating if the task is active (not deleted)
    /// Soft delete allows keeping history while hiding from active list
    var isActive: Bool

    /// Relationship to completion records
    /// Each completion represents one day the task was completed
    /// Inverse relationship defined in TaskCompletion
    @Relationship(deleteRule: .cascade, inverse: \TaskCompletion.task)
    var completions: [TaskCompletion]?

    // MARK: - Initialization

    /// Creates a new task with the specified properties
    ///
    /// - Parameters:
    ///   - title: The display title for the task
    ///   - category: Optional category for organization
    ///   - isRecurring: Whether the task repeats daily (default: false)
    ///   - sortOrder: Position in the task list (default: 0)
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
    ///
    /// Uses Calendar.current.startOfDay to compare dates, which properly
    /// handles timezone differences and daylight saving time transitions.
    ///
    /// - Returns: true if a completion record exists for today, false otherwise
    func isCompletedToday() -> Bool {
        guard let completions = completions else { return false }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return completions.contains { completion in
            calendar.startOfDay(for: completion.completedAt) == today
        }
    }
}
