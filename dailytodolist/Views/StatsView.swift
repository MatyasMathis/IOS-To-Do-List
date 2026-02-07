//
//  StatsView.swift
//  dailytodolist
//
//  Purpose: Category-centric statistics view showing completion patterns
//  Design: Category pill selector with overview stats, weekly rhythm, trends, and per-task breakdown
//

import SwiftUI
import SwiftData

/// Statistics view filtered by category
///
/// Features:
/// - Horizontal scrollable category pills (All + each category)
/// - Quick numbers bar (total reps, rate, streak, best streak)
/// - Weekly rhythm bar chart
/// - This month vs last month trend
/// - Per-task list with streaks and completion rates
/// - Monthly completion calendar
struct StatsView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Queries

    @Query(filter: #Predicate<TodoTask> { $0.isActive }, sort: \TodoTask.title)
    private var allTasks: [TodoTask]

    @Query(sort: \TaskCompletion.completedAt, order: .reverse)
    private var allCompletions: [TaskCompletion]

    @Query(sort: \CustomCategory.sortOrder)
    private var customCategories: [CustomCategory]

    // MARK: - State

    @State private var selectedCategory: String? = nil // nil means "All"
    @State private var displayedMonth: Date = Date()

    // MARK: - Computed Properties

    /// All unique categories from active tasks
    private var categories: [String] {
        let builtIn = ["Work", "Personal", "Health", "Shopping", "Other"]
        let custom = customCategories.map { $0.name }
        let all = builtIn + custom

        // Only return categories that have at least one task
        let taskCategories = Set(allTasks.compactMap { $0.category })
        return all.filter { taskCategories.contains($0) }
    }

    /// Tasks filtered by selected category
    private var filteredTasks: [TodoTask] {
        guard let category = selectedCategory else { return allTasks }
        return allTasks.filter { $0.category == category }
    }

    /// Completions filtered by selected category
    private var filteredCompletions: [TaskCompletion] {
        guard let category = selectedCategory else { return allCompletions }
        return allCompletions.filter { $0.task?.category == category }
    }

    /// Completion dates for the filtered set
    private var filteredCompletionDates: [Date] {
        filteredCompletions.map { $0.completedAt }
    }

    /// Unique completion dates for calendar
    private var filteredCompletionDateSet: Set<Date> {
        let calendar = Calendar.current
        return Set(filteredCompletions.map { calendar.startOfDay(for: $0.completedAt) })
    }

    /// Total completions count
    private var totalReps: Int {
        filteredCompletions.count
    }

    /// Overall completion rate for recurring tasks
    /// Accounts for recurrence schedule: weekly tasks only count scheduled days
    private var completionRate: Int? {
        let calendar = Calendar.current
        let recurringTasks = filteredTasks.filter { $0.recurrenceType != .none }
        guard !recurringTasks.isEmpty else { return nil }

        var totalScheduledDays = 0
        var totalCompletionDays = 0

        for task in recurringTasks {
            let scheduledDays = countScheduledDays(for: task, calendar: calendar)
            let completionDays = Set(task.completions?.map { calendar.startOfDay(for: $0.completedAt) } ?? []).count
            totalScheduledDays += scheduledDays
            totalCompletionDays += min(completionDays, scheduledDays)
        }

        guard totalScheduledDays > 0 else { return nil }
        return min(Int(Double(totalCompletionDays) / Double(totalScheduledDays) * 100), 100)
    }

    /// Counts scheduled days for a task based on its recurrence type
    private func countScheduledDays(for task: TodoTask, calendar: Calendar) -> Int {
        let startDate = calendar.startOfDay(for: task.createdAt)
        let today = calendar.startOfDay(for: Date())

        switch task.recurrenceType {
        case .daily:
            // +1 because creation day counts
            return max((calendar.dateComponents([.day], from: startDate, to: today).day ?? 0) + 1, 1)

        case .weekly:
            let selectedWeekdays = task.selectedWeekdays
            guard !selectedWeekdays.isEmpty else { return 1 }
            var count = 0
            var date = startDate
            while date <= today {
                let weekday = calendar.component(.weekday, from: date)
                if selectedWeekdays.contains(weekday) {
                    count += 1
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
                date = next
            }
            return max(count, 1)

        case .monthly:
            let selectedDays = task.selectedMonthDays
            guard !selectedDays.isEmpty else { return 1 }
            var count = 0
            var date = startDate
            while date <= today {
                let dayOfMonth = calendar.component(.day, from: date)
                if selectedDays.contains(dayOfMonth) {
                    count += 1
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
                date = next
            }
            return max(count, 1)

        case .none:
            return 1
        }
    }

    /// Current streak (consecutive days with at least one completion in filtered set)
    private var currentStreak: Int {
        guard !filteredCompletions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let completionDates = filteredCompletionDateSet
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

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

    /// Best streak ever for the filtered set
    private var bestStreak: Int {
        let calendar = Calendar.current
        let sortedDates = filteredCompletionDateSet.sorted()
        guard !sortedDates.isEmpty else { return 0 }

        var maxStreak = 1
        var current = 1

        for i in 1..<sortedDates.count {
            if let expected = calendar.date(byAdding: .day, value: 1, to: sortedDates[i - 1]),
               calendar.isDate(expected, inSameDayAs: sortedDates[i]) {
                current += 1
                maxStreak = max(maxStreak, current)
            } else {
                current = 1
            }
        }

        return maxStreak
    }

    /// Color for the selected category
    private var categoryColor: Color {
        guard let category = selectedCategory else { return .recoveryGreen }
        return Color.categoryColor(for: category, customCategories: customCategories)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Category pill selector
                        categoryPills

                        if filteredCompletions.isEmpty && filteredTasks.isEmpty {
                            emptyState
                        } else {
                            // Quick numbers
                            quickNumbers

                            // Weekly rhythm
                            if !filteredCompletions.isEmpty {
                                WeeklyRhythmChart(
                                    completions: filteredCompletionDates,
                                    accentColor: categoryColor
                                )
                            }

                            // Monthly trend
                            if !filteredCompletions.isEmpty {
                                MonthlyTrendCard(
                                    completions: filteredCompletionDates,
                                    accentColor: categoryColor
                                )
                            }

                            // Tasks in category
                            if !filteredTasks.isEmpty {
                                CategoryTasksList(tasks: filteredTasks)
                            }

                            // Completion calendar
                            CategoryCompletionCalendar(
                                completionDates: filteredCompletionDateSet,
                                displayedMonth: $displayedMonth,
                                accentColor: categoryColor
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.pureWhite)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Statistics")
                        .font(.system(size: Typography.h4Size, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                }
            }
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Subviews

    /// Horizontal scrollable category pills
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // "All" pill
                categoryPill(label: "All", category: nil, color: .recoveryGreen)

                // Category pills
                ForEach(categories, id: \.self) { category in
                    categoryPill(
                        label: category,
                        category: category,
                        color: Color.categoryColor(for: category, customCategories: customCategories)
                    )
                }
            }
            .padding(.horizontal, Spacing.xs)
        }
    }

    private func categoryPill(label: String, category: String?, color: Color) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        } label: {
            Text(label.uppercased())
                .font(.system(size: Typography.captionSize, weight: .bold))
                .foregroundStyle(isSelected ? Color.brandBlack : color)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
    }

    /// Quick numbers bar
    private var quickNumbers: some View {
        HStack(spacing: 0) {
            StatItem(
                label: "TOTAL REPS",
                value: "\(totalReps)",
                color: categoryColor
            )

            if let rate = completionRate {
                StatItem(
                    label: "RATE",
                    value: "\(rate)%",
                    color: rateColor(for: rate)
                )
            }

            StatItem(
                label: "STREAK",
                value: "\(currentStreak)",
                color: currentStreak > 0 ? categoryColor : .mediumGray
            )

            StatItem(
                label: "BEST",
                value: "\(bestStreak)",
                color: bestStreak > 0 ? categoryColor : .mediumGray
            )
        }
        .padding(.vertical, Spacing.md)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }

    /// Empty state
    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(Color.mediumGray)

            VStack(spacing: Spacing.sm) {
                Text("No data yet")
                    .font(.system(size: Typography.h3Size, weight: .bold))
                    .foregroundStyle(Color.pureWhite)

                Text("Complete tasks to see your stats here.")
                    .font(.system(size: Typography.bodySize, weight: .regular))
                    .foregroundStyle(Color.mediumGray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, Spacing.xxl * 2)
    }

    // MARK: - Helpers

    private func rateColor(for rate: Int) -> Color {
        if rate >= 80 { return .recoveryGreen }
        if rate >= 50 { return .personalOrange }
        return .strainRed
    }
}

// MARK: - Preview

#Preview("Stats View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, CustomCategory.self, configurations: config)

    let task1 = TodoTask(title: "Morning Exercise", category: "Health", recurrenceType: .daily)
    let task2 = TodoTask(title: "Evening Walk", category: "Health", recurrenceType: .daily)
    let task3 = TodoTask(title: "Team standup", category: "Work", recurrenceType: .weekly, selectedWeekdays: [2, 3, 4, 5, 6])
    let task4 = TodoTask(title: "Read for 30 minutes", category: "Personal", recurrenceType: .daily)
    let task5 = TodoTask(title: "Buy groceries", category: "Shopping")

    container.mainContext.insert(task1)
    container.mainContext.insert(task2)
    container.mainContext.insert(task3)
    container.mainContext.insert(task4)
    container.mainContext.insert(task5)

    let calendar = Calendar.current
    for daysAgo in [0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20] {
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()),
           let time = calendar.date(bySettingHour: 9, minute: Int.random(in: 0...59), second: 0, of: date) {
            container.mainContext.insert(TaskCompletion(task: task1, completedAt: time))
        }
    }
    for daysAgo in [0, 1, 2, 5, 8] {
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()),
           let time = calendar.date(bySettingHour: 18, minute: 30, second: 0, of: date) {
            container.mainContext.insert(TaskCompletion(task: task2, completedAt: time))
        }
    }
    for daysAgo in [0, 1, 3, 4, 7, 8] {
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()),
           let time = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date) {
            container.mainContext.insert(TaskCompletion(task: task3, completedAt: time))
        }
    }

    return StatsView()
        .modelContainer(container)
}

#Preview("Stats View - Empty") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, CustomCategory.self, configurations: config)

    return StatsView()
        .modelContainer(container)
}
