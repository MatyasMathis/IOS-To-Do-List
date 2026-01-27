//
//  TaskRow.swift
//  dailytodolist
//
//  Purpose: Individual task row component for the task list
//  Key responsibilities:
//  - Display task title and category
//  - Show recurring badge for recurring tasks
//  - Handle task completion via checkbox tap
//  - Provide visual feedback for completion state
//

import SwiftUI
import SwiftData

/// A row view displaying a single task in the task list
///
/// Shows a checkbox, task title, optional category badge, and a recurring
/// indicator if the task is set to repeat daily.
///
/// The checkbox allows users to complete tasks:
/// - Tapping completes the task (checkbox fills)
/// - The row animates briefly before the task disappears from the list
///
/// State Management:
/// - isCompleted is a @State property that tracks the visual completion state
/// - It's initialized from the task's actual completion status
/// - When toggled, it updates both the visual state and persists via onComplete callback
struct TaskRow: View {

    // MARK: - Properties

    /// The task to display
    let task: TodoTask

    /// Callback when task completion is toggled
    /// Returns the new completion state (true = completed)
    var onComplete: ((TodoTask) -> Void)?

    // MARK: - State

    /// Tracks whether the task appears completed in the UI
    ///
    /// This @State property allows for smooth animations when completing.
    /// It syncs with the task's actual completion status on appear,
    /// and updates the database when toggled by the user.
    @State private var isCompleted: Bool = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // MARK: Checkbox Button
            checkboxButton

            // MARK: Task Info
            VStack(alignment: .leading, spacing: 4) {
                // Task title with strikethrough when completed
                Text(task.title)
                    .font(.body)
                    .foregroundStyle(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted)

                // Category and recurring badges
                if !isCompleted {
                    HStack(spacing: 8) {
                        // Category badge (if present)
                        if let category = task.category, !category.isEmpty {
                            CategoryBadge(category: category)
                        }

                        // Recurring badge
                        if task.isRecurring {
                            RecurringBadge()
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onAppear {
            // Initialize completion state from task's actual status
            updateCompletionStatus()
        }
    }

    // MARK: - Subviews

    /// Checkbox button for completing/uncompleting the task
    ///
    /// Shows an empty circle when incomplete, filled checkmark when complete.
    /// Tapping triggers the completion toggle with animation.
    private var checkboxButton: some View {
        Button {
            toggleCompletion()
        } label: {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isCompleted ? .green : .secondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isCompleted ? "Mark as incomplete" : "Mark as complete")
    }

    // MARK: - Methods

    /// Toggles the task's completion status
    ///
    /// Updates the local @State for immediate visual feedback,
    /// then calls the onComplete callback to persist the change.
    /// The animation provides satisfying feedback to the user.
    private func toggleCompletion() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isCompleted.toggle()
        }

        // Notify parent to handle the completion in the database
        onComplete?(task)
    }

    /// Updates the local completion state from the task's actual status
    ///
    /// Called on appear to ensure the UI reflects the persisted state.
    /// This handles cases where the view is reused or recreated.
    private func updateCompletionStatus() {
        isCompleted = task.isCompletedToday()
    }
}

// MARK: - Supporting Views

/// Badge displaying the task's category
///
/// Uses a subtle background color to make categories visually distinct
/// without being too prominent.
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
/// Shows a small icon and "Daily" text to clearly communicate
/// that this task will reappear after completion.
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
    List {
        TaskRow(task: TodoTask(title: "Buy groceries", category: "Shopping"))
        TaskRow(task: TodoTask(title: "Morning meditation", category: "Health", isRecurring: true))
        TaskRow(task: TodoTask(title: "Simple task"))
        TaskRow(task: TodoTask(title: "Daily standup", isRecurring: true))
    }
    .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
