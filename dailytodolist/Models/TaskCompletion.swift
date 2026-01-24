//
//  TaskCompletion.swift
//  dailytodolist
//
//  Purpose: Tracks individual completion records for tasks
//  Key responsibilities:
//  - Record when a task was completed
//  - Enable history tracking across multiple days
//  - Support recurring tasks by tracking each day's completion separately
//

import Foundation
import SwiftData

/// Represents a single completion event for a task
///
/// Each TaskCompletion record represents one instance of completing a task.
/// This separation from the TodoTask model enables:
/// - Tracking completion history over time
/// - Recurring tasks to have multiple completion records (one per day)
/// - Displaying which tasks were done on which dates in the History view
///
/// The relationship to TodoTask is many-to-one: a TodoTask can have many completions,
/// but each completion belongs to exactly one TodoTask.
@Model
final class TaskCompletion {

    // MARK: - Properties

    /// Unique identifier for this completion record
    var id: UUID

    /// The exact date and time when the task was completed
    /// Used for displaying completion time in history
    /// For date comparisons, use Calendar.startOfDay(for:) to normalize
    var completedAt: Date

    /// Reference to the task that was completed
    /// This relationship is the inverse of TodoTask.completions
    var task: TodoTask?

    // MARK: - Initialization

    /// Creates a new completion record
    ///
    /// - Parameters:
    ///   - task: The task being completed
    ///   - completedAt: When the task was completed (defaults to now)
    init(task: TodoTask, completedAt: Date = Date()) {
        self.id = UUID()
        self.completedAt = completedAt
        self.task = task
    }
}
