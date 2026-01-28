//
//  TaskListView.swift
//  dailytodolist
//
//  Purpose: Main view displaying today's tasks with Whoop-inspired design
//  Design: Dark theme with Daily Progress Card, Streak Counter, and FAB
//

import SwiftUI
import SwiftData

/// Main view for displaying and managing today's tasks
///
/// Features:
/// - Daily Progress Card showing completion percentage
/// - Streak counter in navigation bar
/// - Floating Action Button for adding tasks
/// - Dark theme with card-based task list
/// - Swipe to delete and drag to reorder
struct TaskListView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - State

    @State private var isShowingAddSheet = false
    @State private var todayTasks: [TodoTask] = []
    @State private var editMode: EditMode = .inactive

    // MARK: - Queries

    @Query(
        filter: #Predicate<TodoTask> { task in
            task.isActive == true
        },
        sort: \TodoTask.sortOrder
    )
    private var allActiveTasks: [TodoTask]

    @Query(sort: \TaskCompletion.completedAt, order: .reverse)
    private var allCompletions: [TaskCompletion]

    // MARK: - Computed Properties

    /// Number of tasks completed today
    private var completedTodayCount: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        return allCompletions.filter { completion in
            calendar.isDate(completion.completedAt, inSameDayAs: startOfToday)
        }.count
    }

    /// Total tasks for today (active incomplete + completed today)
    private var totalTodayCount: Int {
        todayTasks.count + completedTodayCount
    }

    /// Current streak (consecutive days with completions)
    private var currentStreak: Int {
        calculateStreak()
    }

    /// Formatted current date
    private var formattedDate: String {
        Date().formatted(.dateTime.month(.abbreviated).day())
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.brandBlack.ignoresSafeArea()

                if todayTasks.isEmpty && completedTodayCount == 0 {
                    // Empty state
                    emptyStateView
                } else {
                    // Task list with progress card
                    taskListContent
                }

                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            isShowingAddSheet = true
                        }
                        .padding(.trailing, Spacing.xxl)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Today")
                        .font(.system(size: Typography.h3Size, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                        .fixedSize()
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: Spacing.md) {
                        // Date
                        Text(formattedDate)
                            .font(.system(size: Typography.bodySize, weight: .medium))
                            .foregroundStyle(Color.mediumGray)

                        // Streak badge
                        if currentStreak > 0 {
                            StreakBadge(count: currentStreak)
                        }
                    }
                }
            }
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $isShowingAddSheet) {
                AddTaskSheet()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                updateTodayTasks()
            }
            .onChange(of: allActiveTasks) {
                updateTodayTasks()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                // Refresh data when app comes to foreground (e.g., after widget interaction)
                if newPhase == .active {
                    modelContext.processPendingChanges()
                    updateTodayTasks()
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    // MARK: - Subviews

    /// Main content with progress card and task list
    private var taskListContent: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Daily Progress Card
                DailyProgressCard(
                    completed: completedTodayCount,
                    total: max(totalTodayCount, 1)
                )
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)

                // Task list
                VStack(spacing: Spacing.sm) {
                    ForEach(todayTasks) { task in
                        TaskRow(task: task) { completedTask in
                            completeTask(completedTask)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteTask(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)

                // Bottom padding for FAB
                Color.clear.frame(height: 80)
            }
        }
        .refreshable {
            await refreshTasks()
        }
    }

    /// Empty state view
    private var emptyStateView: some View {
        EmptyStateCard(
            icon: "checklist",
            title: "Ready to Crush Today?",
            subtitle: "Add your first task to start building your streak",
            actionTitle: "Add Task"
        ) {
            isShowingAddSheet = true
        }
    }

    // MARK: - Methods

    private func completeTask(_ task: TodoTask) {
        let taskService = TaskService(modelContext: modelContext)
        let isNowCompleted = taskService.toggleTaskCompletion(task)

        if isNowCompleted {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                updateTodayTasks()
            }
        }
    }

    private func refreshTasks() async {
        try? await Task.sleep(nanoseconds: 300_000_000)
        updateTodayTasks()
    }

    private func updateTodayTasks() {
        todayTasks = allActiveTasks.filter { task in
            if task.isRecurring {
                return !task.isCompletedToday()
            } else {
                return !hasEverBeenCompleted(task)
            }
        }
    }

    private func hasEverBeenCompleted(_ task: TodoTask) -> Bool {
        guard let completions = task.completions else { return false }
        return !completions.isEmpty
    }

    private func deleteTask(_ task: TodoTask) {
        withAnimation {
            modelContext.delete(task)
            updateTodayTasks()
        }
    }

    /// Calculates the current streak of consecutive days with completions
    private func calculateStreak() -> Int {
        guard !allCompletions.isEmpty else { return 0 }

        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Get unique completion dates
        let completionDates = Set(allCompletions.map { calendar.startOfDay(for: $0.completedAt) })

        // Check if there are completions today
        if !completionDates.contains(checkDate) {
            // Check yesterday - if no completions yesterday, streak is 0
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return 0
            }
            if !completionDates.contains(yesterday) {
                return 0
            }
            checkDate = yesterday
        }

        // Count consecutive days
        while completionDates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }
}

// MARK: - Preview

#Preview("With Tasks") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

    let task1 = TodoTask(title: "Morning Workout", category: "Health", sortOrder: 1)
    let task2 = TodoTask(title: "Team Meeting", category: "Work", isRecurring: true, sortOrder: 2)
    let task3 = TodoTask(title: "Buy groceries", category: "Shopping", sortOrder: 3)
    container.mainContext.insert(task1)
    container.mainContext.insert(task2)
    container.mainContext.insert(task3)

    return TaskListView()
        .modelContainer(container)
}

#Preview("Empty State") {
    TaskListView()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
