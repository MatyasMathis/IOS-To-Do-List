//
//  HistoryRow.swift
//  dailytodolist
//
//  Purpose: History row showing completed task with notebook styling
//  Design: Always checked, time badge, washi tape category badges
//

import SwiftUI
import SwiftData

/// A row view for displaying a completed task in history
struct HistoryRow: View {

    // MARK: - Properties

    let completion: TaskCompletion

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: Spacing.md) {
                // Always checked checkbox (green)
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.greenCheckmark.opacity(0.2))
                        .frame(width: 22, height: 22)

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.greenCheckmark)
                }
                .padding(.top, 2)

                // Task content
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // Task title (no strikethrough in history - completed is normal)
                    Text(completion.task?.title ?? "Unknown Task")
                        .font(.taskTitle)
                        .foregroundStyle(Color.inkBlack)

                    // Badges row
                    HStack(spacing: Spacing.sm) {
                        if let category = completion.task?.category, !category.isEmpty {
                            WashiTapeBadge(category: category)
                        }

                        if completion.task?.isRecurring == true {
                            RecurringWashiBadge()
                        }
                    }
                }

                Spacer()

                // Time badge
                TimeBadge(time: completion.completedAt)
            }
            .padding(.vertical, Spacing.taskRowPadding)
            .padding(.horizontal, Spacing.lg)

            // Ruled line separator
            Rectangle()
                .fill(Color.ruledLines)
                .frame(height: 1)
                .padding(.leading, Spacing.marginLineOffset + Spacing.lg)
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

    let task = TodoTask(title: "Morning meditation", category: "Health", isRecurring: true)
    container.mainContext.insert(task)
    let completion = TaskCompletion(task: task, completedAt: Date())
    container.mainContext.insert(completion)

    return VStack(spacing: 0) {
        HistoryRow(completion: completion)
    }
    .background(Color.paperCream)
    .modelContainer(container)
}
