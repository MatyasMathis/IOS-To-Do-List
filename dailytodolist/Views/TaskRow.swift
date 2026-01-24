//
//  TaskRow.swift
//  dailytodolist
//
//  Purpose: Individual task row with notebook paper styling
//  Design: Hand-drawn checkbox, washi tape badges, ruled line separators
//

import SwiftUI
import SwiftData

/// A row view displaying a single task with notebook styling
struct TaskRow: View {

    // MARK: - Properties

    let task: TodoTask
    var onComplete: ((TodoTask) -> Void)?

    // MARK: - State

    @State private var isCompleted: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: Spacing.md) {
                // Hand-drawn checkbox
                HandDrawnCheckbox(isChecked: isCompleted) {
                    toggleCompletion()
                }
                .padding(.top, 2)

                // Task content
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // Task title
                    Text(task.title)
                        .font(.taskTitle)
                        .foregroundStyle(isCompleted ? Color.pencilGray : Color.inkBlack)
                        .strikethrough(isCompleted, color: Color.redPen)

                    // Badges row
                    if !isCompleted {
                        HStack(spacing: Spacing.sm) {
                            if let category = task.category, !category.isEmpty {
                                WashiTapeBadge(category: category)
                            }

                            if task.isRecurring {
                                RecurringWashiBadge()
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(.vertical, Spacing.taskRowPadding)
            .padding(.horizontal, Spacing.lg)

            // Ruled line separator
            Rectangle()
                .fill(Color.ruledLines)
                .frame(height: 1)
                .padding(.leading, Spacing.marginLineOffset + Spacing.lg)
        }
        .contentShape(Rectangle())
        .onAppear {
            updateCompletionStatus()
        }
    }

    // MARK: - Methods

    private func toggleCompletion() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        withAnimation(.easeInOut(duration: 0.3)) {
            isCompleted.toggle()
        }

        onComplete?(task)
    }

    private func updateCompletionStatus() {
        isCompleted = task.isCompletedToday()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        TaskRow(task: TodoTask(title: "Buy groceries", category: "Shopping"))
        TaskRow(task: TodoTask(title: "Morning meditation", category: "Health", isRecurring: true))
        TaskRow(task: TodoTask(title: "Simple task"))
        TaskRow(task: TodoTask(title: "Daily standup", category: "Work", isRecurring: true))
    }
    .background(Color.paperCream)
    .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
