//
//  StatsView.swift
//  dailytodolist
//
//  Purpose: Task-centric statistics view showing completion patterns
//  Design: Select a task to see its calendar and history
//

import SwiftUI
import SwiftData

/// Statistics view for viewing task completion history and patterns
struct StatsView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Queries

    @Query(filter: #Predicate<TodoTask> { $0.isActive }, sort: \TodoTask.title)
    private var allTasks: [TodoTask]

    // MARK: - State

    @State private var selectedTask: TodoTask?
    @State private var searchText: String = ""
    @State private var isDropdownExpanded: Bool = false
    @State private var displayedMonth: Date = Date()
    @State private var showEditSheet: Bool = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Task selector
                        TaskSearchDropdown(
                            tasks: allTasks,
                            selectedTask: $selectedTask,
                            searchText: $searchText,
                            isExpanded: $isDropdownExpanded
                        )
                        .zIndex(1) // Ensure dropdown appears above other content

                        if let task = selectedTask {
                            // Calendar
                            CompletionCalendar(
                                task: task,
                                displayedMonth: $displayedMonth
                            ) { date in
                                // Could scroll to date in history
                            }

                            // Stats bar
                            TaskStatsBar(task: task)

                            // Edit Task button
                            editTaskButton

                            // History list
                            CompletionHistoryList(task: task)

                        } else {
                            // Empty state - prompt to select a task
                            selectTaskPrompt
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
                    Text("Task Statistics")
                        .font(.system(size: Typography.h4Size, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                }
            }
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            // Auto-select first task if none selected and tasks exist
            if selectedTask == nil, let firstTask = allTasks.first {
                selectedTask = firstTask
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let task = selectedTask {
                EditTaskSheet(task: task) {
                    // On delete: clear selection
                    selectedTask = nil
                }
            }
        }
    }

    // MARK: - Subviews

    private var editTaskButton: some View {
        Button {
            showEditSheet = true
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .semibold))
                Text("Edit Task")
                    .font(.system(size: Typography.bodySize, weight: .medium))
            }
            .foregroundStyle(Color.pureWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.darkGray2)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
        }
    }

    private var selectTaskPrompt: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(Color.mediumGray)

            VStack(spacing: Spacing.sm) {
                Text("Select a Task")
                    .font(.system(size: Typography.h3Size, weight: .bold))
                    .foregroundStyle(Color.pureWhite)

                Text("Choose a task above to view its\ncompletion history and statistics")
                    .font(.system(size: Typography.bodySize, weight: .regular))
                    .foregroundStyle(Color.mediumGray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, Spacing.xxl * 2)
    }
}

// MARK: - Preview

#Preview("Stats View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

    // Create sample tasks
    let task1 = TodoTask(title: "Morning Exercise", category: "Health", recurrenceType: .daily)
    let task2 = TodoTask(title: "Buy groceries", category: "Shopping")
    let task3 = TodoTask(title: "Team standup", category: "Work", recurrenceType: .weekly, selectedWeekdays: [2, 3, 4, 5, 6])
    let task4 = TodoTask(title: "Read for 30 minutes", category: "Personal", recurrenceType: .daily)

    container.mainContext.insert(task1)
    container.mainContext.insert(task2)
    container.mainContext.insert(task3)
    container.mainContext.insert(task4)

    // Add completions
    let calendar = Calendar.current
    for daysAgo in [0, 1, 2, 3, 5, 6, 8, 10, 12, 15, 20] {
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()),
           let dateWithTime = calendar.date(bySettingHour: 9, minute: Int.random(in: 0...59), second: 0, of: date) {
            let completion = TaskCompletion(task: task1, completedAt: dateWithTime)
            container.mainContext.insert(completion)
        }
    }

    return StatsView()
        .modelContainer(container)
}

#Preview("Stats View - Empty") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

    return StatsView()
        .modelContainer(container)
}
