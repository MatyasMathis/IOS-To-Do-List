//
//  HistoryRow.swift
//  dailytodolist
//
//  Purpose: Individual row component for displaying completed tasks in history
//  Key responsibilities:
//  - Display completed task information
//  - Show completion time
//  - Indicate if task was recurring
//  - Show task category if present
//

import SwiftUI
import SwiftData

/// A row view displaying a single completion record in the history list
///
/// Shows the task that was completed along with metadata:
/// - Task title
/// - Completion time (formatted as hour:minute)
/// - Category badge (if the task had a category)
/// - Recurring badge (if the task is a recurring daily task)
///
/// The relationship between TaskCompletion and TodoTask allows us to
/// access the original task's properties for display.
struct HistoryRow: View {

    // MARK: - Properties

    /// The completion record to display
    let completion: TaskCompletion

    // MARK: - Computed Properties

    /// Formats the completion time for display
    ///
    /// Shows the time portion only (e.g., "2:30 PM") since the date
    /// is already shown in the section header.
    private var formattedTime: String {
        completion.completedAt.formatted(date: .omitted, time: .shortened)
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // MARK: Checkmark Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.green)

            // MARK: Task Info
            VStack(alignment: .leading, spacing: 4) {
                // Task title (from the related task)
                if let task = completion.task {
                    Text(task.title)
                        .font(.body)
                        .foregroundStyle(.primary)

                    // Badges row
                    HStack(spacing: 8) {
                        // Completion time
                        TimeBadge(time: formattedTime)

                        // Category badge (if present)
                        if let category = task.category, !category.isEmpty {
                            CategoryBadge(category: category)
                        }

                        // Recurring badge
                        if task.isRecurring {
                            RecurringBadge()
                        }
                    }
                } else {
                    // Fallback if task relationship is nil (shouldn't happen normally)
                    Text("Completed Task")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Supporting Views

/// Badge displaying the completion time
///
/// Shows when the task was completed on that day
private struct TimeBadge: View {
    let time: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.caption2)
            Text(time)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
    }
}

/// Badge displaying the task's category
///
/// Uses a subtle background color to make categories visually distinct
private struct CategoryBadge: View {
    let category: String

    var body: some View {
        Text(category)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.secondary.opacity(0.15))
            .clipShape(Capsule())
    }
}

/// Badge indicating a task repeats daily
///
/// Shows that this completion was for a recurring task
private struct RecurringBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "repeat")
                .font(.caption2)
            Text("Daily")
                .font(.caption)
        }
        .foregroundStyle(.blue)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Color.blue.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

    // Create sample task and completion
    let task = TodoTask(title: "Morning meditation", category: "Health", isRecurring: true)
    container.mainContext.insert(task)
    let completion = TaskCompletion(task: task)
    container.mainContext.insert(completion)

    return List {
        HistoryRow(completion: completion)
    }
    .modelContainer(container)
}
