//
//  HistoryView.swift
//  dailytodolist
//
//  Purpose: Display history of completed tasks with notebook styling
//  Design: Paper background, calendar page headers, completed task rows
//

import SwiftUI
import SwiftData

/// View for displaying completed tasks history
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
                // Notebook paper background
                NotebookBackground(showBindingHoles: true, showMarginLine: true)
                    .ignoresSafeArea()

                if completions.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: Spacing.sm) {
                        // Binding holes visual
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { _ in
                                Circle()
                                    .fill(Color.leatherBrown.opacity(0.6))
                                    .frame(width: 6, height: 6)
                            }
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            Text("Completed Tasks")
                                .font(.handwrittenHeader)
                                .foregroundStyle(Color.inkBlack)

                            Text("Your achievements")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .italic()
                                .foregroundStyle(Color.pencilGray)
                        }
                    }
                }
            }
            .toolbarBackground(Color.paperCream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Subviews

    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(sortedDates, id: \.self) { date in
                    Section {
                        VStack(spacing: 0) {
                            if let dateCompletions = groupedCompletions[date] {
                                ForEach(dateCompletions) { completion in
                                    HistoryRow(completion: completion)
                                }
                            }
                        }
                    } header: {
                        CalendarPageHeader(title: formatDateHeader(date))
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.paperCream)
                    }
                }

                // Bottom padding
                Color.clear.frame(height: Spacing.xxxl)
            }
            .padding(.top, Spacing.sm)
        }
        .refreshable {
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "archivebox")
                .font(.system(size: 80))
                .foregroundStyle(Color.pencilGray.opacity(0.5))

            Text("Nothing Yet!")
                .font(.handwrittenTitle)
                .foregroundStyle(Color.inkBlack)

            Text("Completed tasks will appear here like memories")
                .font(.system(size: 16))
                .foregroundStyle(Color.pencilGray)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xxl)
    }

    // MARK: - Methods

    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            let formatted = date.formatted(.dateTime.month(.abbreviated).day())
            return "Today - \(formatted)"
        } else if calendar.isDateInYesterday(date) {
            let formatted = date.formatted(.dateTime.month(.abbreviated).day())
            return "Yesterday - \(formatted)"
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
