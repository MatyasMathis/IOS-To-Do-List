//
//  CategoryTasksList.swift
//  Reps
//
//  Purpose: Shows tasks within a category with per-task streaks and rates
//  Design: Compact list with inline streak badges and progress indicators
//

import SwiftUI
import SwiftData

/// Displays tasks within a category, each with its own streak and completion rate
struct CategoryTasksList: View {

    // MARK: - Properties

    let tasks: [TodoTask]

    // MARK: - Computed Properties

    /// Tasks sorted by completion rate (best first), then by title
    private var sortedTasks: [TodoTask] {
        let rates = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, completionRate(for: $0)) })
        return tasks.sorted { task1, task2 in
            let rate1 = rates[task1.id] ?? 0
            let rate2 = rates[task2.id] ?? 0
            if rate1 != rate2 { return rate1 > rate2 }
            return task1.title < task2.title
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Section label
            Text("TASKS")
                .font(.system(size: Typography.captionSize, weight: .bold))
                .foregroundStyle(Color.mediumGray)
                .tracking(1.0)
                .frame(maxWidth: .infinity, alignment: .leading)

            if sortedTasks.isEmpty {
                emptyView
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sortedTasks.enumerated()), id: \.element.id) { index, task in
                        CategoryTaskRow(
                            task: task,
                            streak: taskStreak(for: task),
                            rate: completionRate(for: task)
                        )

                        if index < sortedTasks.count - 1 {
                            Divider()
                                .background(Color.darkGray2)
                        }
                    }
                }
                .background(Color.darkGray1)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            }
        }
    }

    // MARK: - Subviews

    private var emptyView: some View {
        HStack {
            Spacer()
            Text("No tasks in this category")
                .font(.system(size: Typography.bodySize, weight: .medium))
                .foregroundStyle(Color.mediumGray)
            Spacer()
        }
        .padding(.vertical, Spacing.lg)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }

    // MARK: - Helpers

    /// Calculates consecutive days of completion for a specific task
    private func taskStreak(for task: TodoTask) -> Int {
        guard let completions = task.completions, !completions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let completionDates = Set(completions.map { calendar.startOfDay(for: $0.completedAt) })

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // If no completion today, check yesterday
        if !completionDates.contains(checkDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            if !completionDates.contains(yesterday) { return 0 }
            checkDate = yesterday
        }

        while completionDates.contains(checkDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        return streak
    }

    /// Calculates completion rate for recurring tasks, or total for one-time
    /// Accounts for recurrence schedule: weekly tasks only count scheduled days
    private func completionRate(for task: TodoTask) -> Double {
        guard let completions = task.completions, !completions.isEmpty else { return 0 }
        guard task.recurrenceType != .none else {
            // For one-time tasks, return 1.0 if completed, 0 otherwise
            return completions.isEmpty ? 0 : 1.0
        }

        let calendar = Calendar.current
        let scheduledDays = countScheduledDays(for: task, calendar: calendar)
        let completionDays = Set(completions.map { calendar.startOfDay(for: $0.completedAt) }).count
        return min(Double(completionDays) / Double(scheduledDays), 1.0)
    }

    /// Counts scheduled days for a task based on its recurrence type
    private func countScheduledDays(for task: TodoTask, calendar: Calendar) -> Int {
        let startDate = calendar.startOfDay(for: task.createdAt)
        let today = calendar.startOfDay(for: Date())

        switch task.recurrenceType {
        case .daily:
            return max((calendar.dateComponents([.day], from: startDate, to: today).day ?? 0) + 1, 1)

        case .weekly:
            let weekdaySet = Set(task.selectedWeekdays)
            guard !weekdaySet.isEmpty else { return 1 }
            let totalDays = max((calendar.dateComponents([.day], from: startDate, to: today).day ?? 0) + 1, 1)
            let fullWeeks = totalDays / 7
            let remainingDays = totalDays % 7
            var count = fullWeeks * weekdaySet.count
            let startWeekday = calendar.component(.weekday, from: startDate)
            for i in 0..<remainingDays {
                let wd = ((startWeekday - 1 + i) % 7) + 1
                if weekdaySet.contains(wd) { count += 1 }
            }
            return max(count, 1)

        case .monthly:
            let daySet = Set(task.selectedMonthDays)
            guard !daySet.isEmpty else { return 1 }
            var count = 0
            var current = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate)) ?? startDate
            let todayMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
            while current <= todayMonth {
                let daysInMonth = calendar.range(of: .day, in: .month, for: current)?.count ?? 30
                for day in daySet {
                    guard day <= daysInMonth else { continue }
                    if let date = calendar.date(bySetting: .day, value: day, of: current),
                       calendar.startOfDay(for: date) >= startDate && calendar.startOfDay(for: date) <= today {
                        count += 1
                    }
                }
                guard let next = calendar.date(byAdding: .month, value: 1, to: current) else { break }
                current = next
            }
            return max(count, 1)

        case .none:
            return 1
        }
    }
}

// MARK: - Category Task Row

struct CategoryTaskRow: View {

    let task: TodoTask
    let streak: Int
    let rate: Double

    private var rateColor: Color {
        if rate >= 0.8 { return .recoveryGreen }
        if rate >= 0.5 { return .personalOrange }
        return .strainRed
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Task title
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: Typography.bodySize, weight: .medium))
                    .foregroundStyle(Color.pureWhite)
                    .lineLimit(1)

                if task.recurrenceType != .none {
                    Text(task.recurrenceDisplayString)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.mediumGray)
                }
            }

            Spacer()

            // Streak (if active)
            if streak > 0 {
                HStack(spacing: 3) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(
                            streak >= 7 ? Color.strainRed :
                            streak >= 3 ? Color.personalOrange :
                            Color.recoveryGreen
                        )
                    Text("\(streak)")
                        .font(.system(size: Typography.captionSize, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                }
            }

            // Rate bar
            if task.recurrenceType != .none {
                HStack(spacing: Spacing.xs) {
                    // Mini progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.darkGray2)
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(rateColor)
                                .frame(width: geometry.size.width * rate, height: 4)
                        }
                    }
                    .frame(width: 32, height: 4)

                    Text("\(Int(rate * 100))%")
                        .font(.system(size: Typography.captionSize, weight: .bold))
                        .foregroundStyle(rateColor)
                        .frame(width: 32, alignment: .trailing)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - Preview

#Preview("Category Tasks List") {
    struct PreviewWrapper: View {
        var body: some View {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, CustomCategory.self, configurations: config)

            let task1 = TodoTask(title: "Morning Workout", category: "Health", recurrenceType: .daily)
            let task2 = TodoTask(title: "Evening Walk", category: "Health", recurrenceType: .daily)
            let task3 = TodoTask(title: "Take Vitamins", category: "Health", recurrenceType: .daily)

            container.mainContext.insert(task1)
            container.mainContext.insert(task2)
            container.mainContext.insert(task3)

            let calendar = Calendar.current
            for daysAgo in 0..<8 {
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                    container.mainContext.insert(TaskCompletion(task: task1, completedAt: date))
                }
            }
            for daysAgo in 0..<3 {
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                    container.mainContext.insert(TaskCompletion(task: task2, completedAt: date))
                }
            }

            return ZStack {
                Color.brandBlack.ignoresSafeArea()
                CategoryTasksList(tasks: [task1, task2, task3])
                    .padding(Spacing.lg)
            }
        }
    }

    return PreviewWrapper()
}
