//
//  CompletionHistoryList.swift
//  dailytodolist
//
//  Purpose: Grouped list of task completions by date
//

import SwiftUI
import SwiftData

/// Displays completion history for a task, grouped by date
struct CompletionHistoryList: View {

    // MARK: - Properties

    let task: TodoTask
    var scrollToDate: Date?

    // MARK: - Private Properties

    private let calendar = Calendar.current

    // MARK: - Computed Properties

    private var sortedCompletions: [TaskCompletion] {
        (task.completions ?? []).sorted { $0.completedAt > $1.completedAt }
    }

    private var groupedCompletions: [(key: String, completions: [TaskCompletion])] {
        let grouped = Dictionary(grouping: sortedCompletions) { completion in
            groupKey(for: completion.completedAt)
        }

        // Sort groups by most recent date first
        return grouped.map { (key: $0.key, completions: $0.value) }
            .sorted { group1, group2 in
                guard let date1 = group1.completions.first?.completedAt,
                      let date2 = group2.completions.first?.completedAt else {
                    return false
                }
                return date1 > date2
            }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Section header
            Text("HISTORY")
                .font(.system(size: Typography.labelSize, weight: .bold))
                .foregroundStyle(Color.mediumGray)
                .tracking(1.5)

            if sortedCompletions.isEmpty {
                emptyHistoryView
            } else {
                historyList
            }
        }
    }

    // MARK: - Subviews

    private var historyList: some View {
        VStack(spacing: Spacing.lg) {
            ForEach(groupedCompletions, id: \.key) { group in
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    // Group header
                    Text(group.key)
                        .font(.system(size: Typography.captionSize, weight: .semibold))
                        .foregroundStyle(Color.mediumGray)
                        .padding(.leading, Spacing.sm)

                    // Completion rows
                    VStack(spacing: 0) {
                        ForEach(Array(group.completions.enumerated()), id: \.element.id) { index, completion in
                            CompletionHistoryRow(
                                completion: completion,
                                showDate: !isRecentGroup(group.key)
                            )

                            if index < group.completions.count - 1 {
                                Divider()
                                    .background(Color.darkGray2)
                            }
                        }
                    }
                    .background(Color.darkGray1)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
                }
            }
        }
    }

    private var emptyHistoryView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color.mediumGray)

            Text("No completions yet")
                .font(.system(size: Typography.bodySize, weight: .medium))
                .foregroundStyle(Color.mediumGray)

            Text("Complete this task to start tracking")
                .font(.system(size: Typography.captionSize, weight: .regular))
                .foregroundStyle(Color.mediumGray.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
    }

    // MARK: - Helpers

    private func groupKey(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if isDateInThisWeek(date) {
            return "This Week"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
    }

    private func isDateInThisWeek(_ date: Date) -> Bool {
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else {
            return false
        }
        return date > weekAgo && !calendar.isDateInToday(date) && !calendar.isDateInYesterday(date)
    }

    private func isRecentGroup(_ key: String) -> Bool {
        key == "Today" || key == "Yesterday"
    }
}

// MARK: - Completion History Row

struct CompletionHistoryRow: View {
    let completion: TaskCompletion
    let showDate: Bool

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: completion.completedAt)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: completion.completedAt)
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Checkmark icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.recoveryGreen)

            // Date (if showing)
            if showDate {
                Text(dateString)
                    .font(.system(size: Typography.bodySize, weight: .medium))
                    .foregroundStyle(Color.pureWhite)

                Text("·")
                    .foregroundStyle(Color.mediumGray)
            }

            // Time
            Text(timeString)
                .font(.system(size: Typography.timeSize, weight: .medium, design: .monospaced))
                .foregroundStyle(showDate ? Color.mediumGray : Color.pureWhite)

            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - Preview

#Preview("Completion History List") {
    struct PreviewWrapper: View {
        var body: some View {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

            let task = TodoTask(title: "Morning Exercise", category: "Health", recurrenceType: .daily)
            container.mainContext.insert(task)

            // Add various completions
            let calendar = Calendar.current
            let times: [(Int, Int, Int)] = [
                (0, 9, 15),   // Today
                (0, 7, 30),   // Today earlier
                (1, 8, 45),   // Yesterday
                (2, 9, 0),    // 2 days ago
                (3, 7, 15),   // 3 days ago
                (5, 8, 30),   // 5 days ago
                (10, 9, 0),   // 10 days ago
                (15, 8, 0),   // 15 days ago
                (20, 7, 45),  // 20 days ago
            ]

            for (daysAgo, hour, minute) in times {
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()),
                   let dateWithTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) {
                    let completion = TaskCompletion(task: task, completedAt: dateWithTime)
                    container.mainContext.insert(completion)
                }
            }

            return ZStack {
                Color.brandBlack.ignoresSafeArea()
                ScrollView {
                    CompletionHistoryList(task: task)
                        .padding(Spacing.lg)
                }
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Empty History") {
    struct PreviewWrapper: View {
        var body: some View {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

            let task = TodoTask(title: "New Task", category: "Work")
            container.mainContext.insert(task)

            return ZStack {
                Color.brandBlack.ignoresSafeArea()
                CompletionHistoryList(task: task)
                    .padding(Spacing.lg)
            }
        }
    }

    return PreviewWrapper()
}
