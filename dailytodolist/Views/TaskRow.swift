//
//  TaskRow.swift
//  dailytodolist
//
//  Purpose: Individual task row component with Whoop-inspired design
//  Design: Dark card styling with custom checkbox and category badges
//

import SwiftUI
import SwiftData

/// A row view displaying a single task with Whoop-inspired styling
///
/// Features:
/// - Custom circular checkbox with animation
/// - Dark card background with subtle shadow
/// - Category badge with color-coded styling
/// - Recurring badge with purple accent
/// - Strikethrough and opacity change when completed
/// - Tap row to edit task
struct TaskRow: View {

    // MARK: - Properties

    /// The task to display
    let task: TodoTask

    /// Callback when task completion is toggled
    var onComplete: ((TodoTask) -> Void)?

    /// Callback when task row is tapped for editing
    var onEdit: ((TodoTask) -> Void)?

    // MARK: - State

    /// Tracks whether the task appears completed in the UI
    @State private var isCompleted: Bool = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: Spacing.md) {
            // MARK: Checkbox
            CheckboxButton(isChecked: isCompleted) {
                toggleCompletion()
            }

            // MARK: Task Info (tappable for edit)
            Button {
                onEdit?(task)
            } label: {
                HStack(spacing: Spacing.md) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        // Task title
                        Text(task.title)
                            .font(.system(size: Typography.h4Size, weight: .medium))
                            .foregroundStyle(isCompleted ? Color.pureWhite.opacity(0.6) : Color.pureWhite)
                            .strikethrough(isCompleted, color: Color.pureWhite.opacity(0.4))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        // Badges row (only show when not completed)
                        if !isCompleted {
                            HStack(spacing: Spacing.sm) {
                                // Category badge
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

                    // Chevron indicator
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.mediumGray)
                        .opacity(isCompleted ? 0 : 0.5)
                }
            }
            .buttonStyle(.plain)
            .disabled(onEdit == nil)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, 14)
        .background(Color.darkGray2)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
        .shadowLevel1()
        .opacity(isCompleted ? 0.7 : 1.0)
        .onAppear {
            updateCompletionStatus()
        }
        .onChange(of: task.completions?.count) {
            updateCompletionStatus()
        }
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
    }

    // MARK: - Methods

    /// Toggles the task's completion status with animation and haptic feedback
    private func toggleCompletion() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCompleted.toggle()
        }

        // Success haptic for completion
        if isCompleted {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }

        // Notify parent to handle the completion in the database
        onComplete?(task)
    }

    /// Updates the local completion state from the task's actual status
    private func updateCompletionStatus() {
        isCompleted = task.isCompletedToday()
    }
}

// MARK: - Preview

#Preview("Task Rows") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        VStack(spacing: Spacing.sm) {
            TaskRow(
                task: TodoTask(title: "Morning Workout", category: "Health"),
                onEdit: { _ in print("Edit tapped") }
            )
            TaskRow(
                task: TodoTask(title: "Team Meeting", category: "Work", isRecurring: true),
                onEdit: { _ in print("Edit tapped") }
            )
            TaskRow(
                task: TodoTask(title: "Buy groceries", category: "Shopping"),
                onEdit: { _ in print("Edit tapped") }
            )
            TaskRow(
                task: TodoTask(title: "Simple task"),
                onEdit: { _ in print("Edit tapped") }
            )
        }
        .padding(Spacing.lg)
    }
    .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
