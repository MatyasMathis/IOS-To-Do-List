//
//  HistoryView.swift
//  dailytodolist
//
//  Purpose: Display history of completed tasks with Whoop-inspired design
//  Design: Dark theme with section headers and card-based rows
//

import SwiftUI
import SwiftData

/// View for displaying completed tasks history with Whoop-inspired styling
///
/// Features:
/// - Dark theme background
/// - Styled section headers (Today, Yesterday, dates)
/// - Card-based completion rows
/// - Empty state with motivational message
struct HistoryView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - Queries

    @Query(sort: \TaskCompletion.completedAt, order: .reverse)
    private var completions: [TaskCompletion]

    // MARK: - Computed Properties

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

    private var sortedDates: [Date] {
        groupedCompletions.keys.sorted(by: >)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.brandBlack.ignoresSafeArea()

                if completions.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("History")
                        .font(.system(size: Typography.h3Size, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                        .fixedSize()
                }

                ToolbarItem(placement: .topBarTrailing) {
                    // Stats button placeholder for future feature
                    Button {
                        // Future: Show stats view
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "chart.bar.fill")
                            Text("Stats")
                        }
                        .font(.system(size: Typography.bodySize, weight: .medium))
                        .foregroundStyle(Color.mediumGray)
                    }
                }
            }
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Subviews

    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(sortedDates, id: \.self) { date in
                    Section {
                        VStack(spacing: Spacing.sm) {
                            if let dateCompletions = groupedCompletions[date] {
                                ForEach(dateCompletions) { completion in
                                    HistoryRow(completion: completion)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.lg)
                    } header: {
                        SectionHeader(title: formatDateHeader(date))
                    }
                }
            }
            .padding(.top, Spacing.sm)
        }
        .refreshable {
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
    }

    private var emptyStateView: some View {
        EmptyStateCard(
            icon: "trophy.fill",
            title: "No Wins Yet",
            subtitle: "Complete tasks to build your history and see your progress"
        )
    }

    // MARK: - Methods

    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.month(.abbreviated).day().year())
        }
    }
}

// MARK: - Preview

#Preview("With History") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

    let task1 = TodoTask(title: "Morning meditation", category: "Health", isRecurring: true)
    let task2 = TodoTask(title: "Buy groceries", category: "Shopping")
    container.mainContext.insert(task1)
    container.mainContext.insert(task2)

    let completion1 = TaskCompletion(task: task1, completedAt: Date())
    let completion2 = TaskCompletion(task: task2, completedAt: Date().addingTimeInterval(-3600))
    container.mainContext.insert(completion1)
    container.mainContext.insert(completion2)

    return HistoryView()
        .modelContainer(container)
}

#Preview("Empty State") {
    HistoryView()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
