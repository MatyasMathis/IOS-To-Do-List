//
//  HistoryView.swift
//  dailytodolist
//
//  Purpose: Display history of completed tasks
//  Key responsibilities:
//  - Show completed tasks grouped by date
//  - Display empty state when no history exists
//  - Allow viewing past completions for both recurring and one-time tasks
//

import SwiftUI
import SwiftData

/// View for displaying the history of completed tasks
///
/// Shows all task completions organized by date, with the most recent
/// completions appearing first. Recurring tasks can appear multiple times
/// (once for each day they were completed).
///
/// Data Flow:
/// 1. @Query fetches all completions sorted by date
/// 2. Completions are grouped by date using groupedCompletions computed property
/// 3. sortedDates provides dates in descending order for section headers
/// 4. Each section displays completions using HistoryRow components
struct HistoryView: View {

    // MARK: - Environment

    /// SwiftData model context for database operations
    @Environment(\.modelContext) private var modelContext

    // MARK: - Queries

    /// Fetches all completion records sorted by completion date (newest first)
    @Query(sort: \TaskCompletion.completedAt, order: .reverse)
    private var completions: [TaskCompletion]

    // MARK: - Computed Properties

    /// Groups completions by the date they were completed
    ///
    /// Uses Calendar.startOfDay to normalize dates, ensuring all completions
    /// on the same calendar day are grouped together regardless of time.
    ///
    /// - Returns: Dictionary mapping dates to arrays of completions
    private var groupedCompletions: [Date: [TaskCompletion]] {
        let calendar = Calendar.current
        var grouped: [Date: [TaskCompletion]] = [:]

        for completion in completions {
            let dayKey = calendar.startOfDay(for: completion.completedAt)
            if grouped[dayKey] == nil {
                grouped[dayKey] = []
            }
            grouped[dayKey]?.append(completion)
        }

        return grouped
    }

    /// Sorted array of dates with completions (newest first)
    ///
    /// Used to determine the order of sections in the history list.
    /// Dates are sorted in descending order so recent history appears first.
    private var sortedDates: [Date] {
        groupedCompletions.keys.sorted(by: >)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if completions.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationTitle("History")
        }
    }

    // MARK: - Subviews

    /// List view displaying completions grouped by date
    ///
    /// Each section represents a day, with its completions shown
    /// using HistoryRow components. Dates are formatted relative
    /// to today (e.g., "Today", "Yesterday", or full date).
    private var historyListView: some View {
        List {
            ForEach(sortedDates, id: \.self) { date in
                Section {
                    if let dateCompletions = groupedCompletions[date] {
                        ForEach(dateCompletions) { completion in
                            HistoryRow(completion: completion)
                        }
                    }
                } header: {
                    Text(formatDateHeader(date))
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            // Pull-to-refresh - the @Query automatically updates
            // Add brief delay for visual feedback
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
    }

    /// Empty state view shown when no completion history exists
    ///
    /// Provides visual feedback that no tasks have been completed yet
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No History Yet",
            systemImage: "clock.arrow.circlepath",
            description: Text("Completed tasks will appear here")
        )
    }

    // MARK: - Methods

    /// Formats a date for display as a section header
    ///
    /// Uses relative formatting for recent dates:
    /// - "Today" for the current day
    /// - "Yesterday" for the previous day
    /// - Full date format for older dates (e.g., "January 15, 2024")
    ///
    /// - Parameter date: The date to format
    /// - Returns: Formatted string for the section header
    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .long, time: .omitted)
        }
    }
}

// MARK: - Preview

#Preview("With History") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

    // Create sample tasks and completions
    let task1 = TodoTask(title: "Morning meditation", category: "Health", isRecurring: true)
    let task2 = TodoTask(title: "Buy groceries", category: "Shopping")
    let task3 = TodoTask(title: "Exercise", category: "Health", isRecurring: true)

    container.mainContext.insert(task1)
    container.mainContext.insert(task2)
    container.mainContext.insert(task3)

    // Create completions for today
    let completion1 = TaskCompletion(task: task1, completedAt: Date())
    let completion2 = TaskCompletion(task: task2, completedAt: Date().addingTimeInterval(-3600))

    // Create completion for yesterday
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let completion3 = TaskCompletion(task: task3, completedAt: yesterday)

    container.mainContext.insert(completion1)
    container.mainContext.insert(completion2)
    container.mainContext.insert(completion3)

    return HistoryView()
        .modelContainer(container)
}

#Preview("Empty State") {
    HistoryView()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
