//
//  HistoryView.swift
//  dailytodolist
//
//  Purpose: Display history of completed tasks with Whoop-inspired design
//  Design: Dark theme with calendar navigation, section headers, and card-based rows
//

import SwiftUI
import SwiftData

/// View for displaying completed tasks history with Whoop-inspired styling
///
/// Features:
/// - Collapsible calendar for quick date navigation
/// - Dark theme background
/// - Styled section headers (Today, Yesterday, dates)
/// - Card-based completion rows
/// - Empty state with motivational message
struct HistoryView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - State

    @State private var refreshID = UUID()
    @State private var showStats = false
    @State private var calendarMonth = Date()
    @State private var isCalendarExpanded = false
    @State private var scrollTarget: Date?

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

    private var completionDatesSet: Set<Date> {
        Set(groupedCompletions.keys)
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
                    Button {
                        showStats = true
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "chart.bar.fill")
                            Text("Stats")
                        }
                        .font(.system(size: Typography.bodySize, weight: .medium))
                        .foregroundStyle(Color.recoveryGreen)
                    }
                }
            }
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                // Refresh data when app comes to foreground (e.g., after widget interaction)
                if newPhase == .active {
                    refreshID = UUID()
                }
            }
            .id(refreshID)
            .sheet(isPresented: $showStats) {
                StatsView()
            }
        }
    }

    // MARK: - Subviews

    private var historyListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // Calendar for date navigation
                    HistoryCalendar(
                        completionDates: completionDatesSet,
                        displayedMonth: $calendarMonth,
                        isExpanded: $isCalendarExpanded
                    ) { selectedDate in
                        scrollToDate(selectedDate, proxy: proxy)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.sm)

                    // History list
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
                            .id(date)
                        }
                    }
                }
            }
            .refreshable {
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
            .onChange(of: scrollTarget) { _, newTarget in
                if let target = newTarget {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(target, anchor: .top)
                    }
                    scrollTarget = nil
                }
            }
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

    private func scrollToDate(_ date: Date, proxy: ScrollViewProxy) {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)

        // Find the closest date in our sorted dates
        if sortedDates.contains(targetDate) {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(targetDate, anchor: .top)
            }
        } else {
            // Find the closest date after the selected date
            let closestDate = sortedDates.first { $0 <= targetDate }
            if let closest = closestDate {
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(closest, anchor: .top)
                }
            }
        }
    }

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
    let task3 = TodoTask(title: "Team meeting", category: "Work")
    container.mainContext.insert(task1)
    container.mainContext.insert(task2)
    container.mainContext.insert(task3)

    // Add completions for various dates
    let calendar = Calendar.current
    for daysAgo in [0, 0, 1, 1, 2, 3, 5, 8, 10, 15, 20] {
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()),
           let dateWithTime = calendar.date(bySettingHour: Int.random(in: 8...18), minute: Int.random(in: 0...59), second: 0, of: date) {
            let task = [task1, task2, task3].randomElement()!
            let completion = TaskCompletion(task: task, completedAt: dateWithTime)
            container.mainContext.insert(completion)
        }
    }

    return HistoryView()
        .modelContainer(container)
}

#Preview("Empty State") {
    HistoryView()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
