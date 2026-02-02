//
//  TaskStatsBar.swift
//  dailytodolist
//
//  Purpose: Compact stats bar showing key metrics for a task
//

import SwiftUI
import SwiftData

/// Displays key statistics for a task: total completions, current streak, completion rate
struct TaskStatsBar: View {

    // MARK: - Properties

    let task: TodoTask

    // MARK: - Private Properties

    private let calendar = Calendar.current

    // MARK: - Computed Properties

    private var totalCompletions: Int {
        task.completions?.count ?? 0
    }

    private var currentStreak: Int {
        calculateStreak()
    }

    private var completionRate: Double? {
        guard task.recurrenceType != .none else { return nil }

        let daysSinceCreation = calendar.dateComponents([.day], from: task.createdAt, to: Date()).day ?? 1
        guard daysSinceCreation > 0 else { return nil }

        let completionDays = Set(task.completions?.map { calendar.startOfDay(for: $0.completedAt) } ?? []).count
        return Double(completionDays) / Double(daysSinceCreation)
    }

    private var firstCompletionDate: Date? {
        task.completions?.min(by: { $0.completedAt < $1.completedAt })?.completedAt
    }

    // MARK: - Body

    var body: some View {
        if totalCompletions == 0 {
            noCompletionsView
        } else if task.recurrenceType != .none {
            recurringTaskStats
        } else {
            oneTimeTaskStats
        }
    }

    // MARK: - Subviews

    private var recurringTaskStats: some View {
        HStack(spacing: 0) {
            // Total
            StatItem(
                label: "TOTAL",
                value: "\(totalCompletions)",
                color: .pureWhite
            )

            Divider()
                .frame(height: 40)
                .background(Color.darkGray2)

            // Streak
            StatItem(
                label: "STREAK",
                value: currentStreak > 0 ? "\(currentStreak) day\(currentStreak == 1 ? "" : "s")" : "—",
                color: currentStreak > 0 ? .recoveryGreen : .mediumGray
            )

            Divider()
                .frame(height: 40)
                .background(Color.darkGray2)

            // Rate
            StatItem(
                label: "RATE",
                value: completionRate.map { "\(Int($0 * 100))%" } ?? "—",
                color: rateColor
            )
        }
        .padding(.vertical, Spacing.md)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
    }

    private var oneTimeTaskStats: some View {
        HStack(spacing: 0) {
            // Total
            StatItem(
                label: "TOTAL",
                value: "\(totalCompletions)",
                color: .pureWhite
            )

            Divider()
                .frame(height: 40)
                .background(Color.darkGray2)

            // Streak
            StatItem(
                label: "STREAK",
                value: currentStreak > 0 ? "\(currentStreak) day\(currentStreak == 1 ? "" : "s")" : "—",
                color: currentStreak > 0 ? .recoveryGreen : .mediumGray
            )

            Divider()
                .frame(height: 40)
                .background(Color.darkGray2)

            // First completed
            StatItem(
                label: "FIRST",
                value: firstCompletionDate.map { formatDate($0) } ?? "—",
                color: .mediumGray
            )
        }
        .padding(.vertical, Spacing.md)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
    }

    private var noCompletionsView: some View {
        HStack {
            Spacer()
            VStack(spacing: Spacing.xs) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.mediumGray)
                Text("No completions yet")
                    .font(.system(size: Typography.bodySize, weight: .medium))
                    .foregroundStyle(Color.mediumGray)
            }
            Spacer()
        }
        .padding(.vertical, Spacing.lg)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
    }

    // MARK: - Helpers

    private var rateColor: Color {
        guard let rate = completionRate else { return .mediumGray }
        if rate >= 0.8 {
            return .recoveryGreen
        } else if rate >= 0.5 {
            return .personalOrange
        } else {
            return .strainRed
        }
    }

    private func calculateStreak() -> Int {
        guard let completions = task.completions, !completions.isEmpty else { return 0 }

        let sortedDates = Set(completions.map { calendar.startOfDay(for: $0.completedAt) })
            .sorted(by: >)

        var streak = 0
        var expectedDate = calendar.startOfDay(for: Date())

        for date in sortedDates {
            if date == expectedDate {
                streak += 1
                if let previousDay = calendar.date(byAdding: .day, value: -1, to: expectedDate) {
                    expectedDate = previousDay
                }
            } else if date < expectedDate {
                // Allow for today not being completed yet - check if yesterday was completed
                if streak == 0 {
                    if let yesterday = calendar.date(byAdding: .day, value: -1, to: expectedDate),
                       date == yesterday {
                        streak += 1
                        expectedDate = calendar.date(byAdding: .day, value: -1, to: yesterday)!
                        continue
                    }
                }
                break
            }
        }
        return streak
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(label)
                .font(.system(size: Typography.captionSize, weight: .semibold))
                .foregroundStyle(Color.mediumGray)

            Text(value)
                .font(.system(size: Typography.h4Size, weight: .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("Task Stats Bar") {
    struct PreviewWrapper: View {
        var body: some View {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

            // Recurring task with good stats
            let recurringTask = TodoTask(title: "Morning Exercise", category: "Health", recurrenceType: .daily)
            container.mainContext.insert(recurringTask)

            // Add completions for streak
            let calendar = Calendar.current
            for daysAgo in [0, 1, 2, 3, 4] {
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                    let completion = TaskCompletion(task: recurringTask, completedAt: date)
                    container.mainContext.insert(completion)
                }
            }

            // One-time task
            let oneTimeTask = TodoTask(title: "Buy groceries", category: "Shopping")
            container.mainContext.insert(oneTimeTask)
            let completion = TaskCompletion(task: oneTimeTask, completedAt: Date().addingTimeInterval(-86400 * 5))
            container.mainContext.insert(completion)

            // Empty task
            let emptyTask = TodoTask(title: "New task", category: "Work")
            container.mainContext.insert(emptyTask)

            return ZStack {
                Color.brandBlack.ignoresSafeArea()
                VStack(spacing: Spacing.lg) {
                    TaskStatsBar(task: recurringTask)
                    TaskStatsBar(task: oneTimeTask)
                    TaskStatsBar(task: emptyTask)
                }
                .padding(Spacing.lg)
            }
        }
    }

    return PreviewWrapper()
}
