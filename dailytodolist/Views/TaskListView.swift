//
//  TaskListView.swift
//  Reps
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
    @State private var taskToEdit: TodoTask?
    @State private var todayTasks: [TodoTask] = []
    @State private var editMode: EditMode = .inactive
    @State private var refreshID = UUID()

    // Celebration overlay state
    @State private var showCelebration = false
    @State private var celebrationMessage = ""

    // Year in Pixels sheet
    @State private var showYearInPixels = false

    // Category share sheet
    @State private var showCategoryShare = false
    @State private var completedCategoryName: String = ""
    @State private var completedCategoryIcon: String = ""
    @State private var completedCategoryColorHex: String = ""
    @State private var completedCategoryCount: Int = 0
    @State private var completedCategoryStreak: Int = 0

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

    @Query(sort: \CustomCategory.sortOrder)
    private var customCategories: [CustomCategory]

    // MARK: - Computed Properties

    /// Number of tasks completed today (from todayTasks list)
    private var completedTodayCount: Int {
        todayTasks.filter { $0.isCompletedToday() }.count
    }

    /// Total tasks for today (all tasks in todayTasks, both completed and incomplete)
    private var totalTodayCount: Int {
        todayTasks.count
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

                // Celebration overlay for task completion
                CelebrationOverlay(message: celebrationMessage, isShowing: $showCelebration)
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

                        // Streak badge — tappable to open Year in Pixels
                        if currentStreak > 0 {
                            Button {
                                showYearInPixels = true
                            } label: {
                                StreakBadge(count: currentStreak)
                            }
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
            .sheet(item: $taskToEdit, onDismiss: {
                // Refresh tasks after editing
                withAnimation {
                    updateTodayTasks()
                }
            }) { task in
                EditTaskSheet(task: task) {
                    // On delete callback
                    withAnimation {
                        updateTodayTasks()
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showYearInPixels) {
                YearInPixelsView()
            }
            .sheet(isPresented: $showCategoryShare) {
                CategoryShareSheet(
                    categoryName: completedCategoryName,
                    categoryIcon: completedCategoryIcon,
                    categoryColorHex: completedCategoryColorHex,
                    completedCount: completedCategoryCount,
                    totalCount: completedCategoryCount,
                    streak: completedCategoryStreak
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                OnboardingService.createStarterTasksIfNeeded(modelContext: modelContext)
                updateTodayTasks()
            }
            .onChange(of: allActiveTasks) {
                updateTodayTasks()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                // Refresh data when app comes to foreground (e.g., after widget interaction)
                if newPhase == .active {
                    // Force view refresh by changing the ID, which re-triggers @Query
                    refreshID = UUID()
                    refreshFromDatabase()
                }
            }
            .id(refreshID)
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

                // Task list with drag to reorder
                ReorderableTaskList(
                    tasks: $todayTasks,
                    onComplete: { task in
                        completeTask(task)
                    },
                    onDelete: { task in
                        deleteTask(task)
                    },
                    onReorder: { tasks in
                        reorderTasks(tasks)
                    },
                    onEdit: { task in
                        editTask(task)
                    }
                )
                .padding(.horizontal, Spacing.lg)

                // Bottom padding for FAB
                Color.clear.frame(height: 80)
            }
        }
        .refreshable {
            await refreshTasks()
        }
    }

    /// Empty state view with contextual nudge
    private var emptyStateView: some View {
        EmptyStateCard(
            icon: "checkmark.circle",
            title: "Nothing on the board.",
            subtitle: "Tap + to add your first task. Keep it simple.",
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
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // Check for streak milestone message first, then fall back to random
            let streak = calculateStreak()
            if let milestoneMsg = EncouragingMessages.milestoneMessage(for: streak) {
                celebrationMessage = milestoneMsg
            } else {
                celebrationMessage = EncouragingMessages.random()
            }
            showCelebration = true

            // Check if all tasks in this category are now completed
            checkCategoryCompletion(for: task)
        }

        // Update immediately - completed tasks stay in list but move to end
        withAnimation {
            updateTodayTasks()
        }
    }

    /// Checks if all today-tasks in the given task's category are completed.
    /// If so, triggers the share sheet after a short delay.
    private func checkCategoryCompletion(for task: TodoTask) {
        guard let category = task.category else { return }

        let categoryTasks = todayTasks.filter { $0.category == category }
        guard categoryTasks.count >= 2 else { return } // Only trigger for 2+ tasks

        let allDone = categoryTasks.allSatisfy { $0.isCompletedToday() }
        guard allDone else { return }

        // Populate share data
        completedCategoryName = category
        completedCategoryIcon = Color.categoryIcon(for: category, customCategories: customCategories)
        completedCategoryColorHex = categoryColorHex(for: category)
        completedCategoryCount = categoryTasks.count
        completedCategoryStreak = categoryStreak(for: category)

        // Delay so celebration overlay plays first
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            showCategoryShare = true
        }
    }

    /// Returns hex color string for a category
    private func categoryColorHex(for category: String) -> String {
        switch category.lowercased() {
        case "work": return "4A90E2"
        case "personal": return "F5A623"
        case "health": return "2DD881"
        case "shopping": return "BD10E0"
        default:
            if let custom = customCategories.first(where: { $0.name == category }) {
                return custom.colorHex
            }
            return "808080"
        }
    }

    /// Calculates category-specific streak (consecutive days with at least one completion in category)
    private func categoryStreak(for category: String) -> Int {
        let calendar = Calendar.current
        let categoryCompletions = allCompletions.filter { $0.task?.category == category }
        let dates = Set(categoryCompletions.map { calendar.startOfDay(for: $0.completedAt) })

        guard !dates.isEmpty else { return 0 }

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        if !dates.contains(checkDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            if !dates.contains(yesterday) { return 0 }
            checkDate = yesterday
        }

        while dates.contains(checkDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        return streak
    }

    private func refreshTasks() async {
        try? await Task.sleep(nanoseconds: 300_000_000)
        refreshFromDatabase()
    }

    /// Force refresh all data from the database (needed after widget updates)
    private func refreshFromDatabase() {
        // Force SwiftData to re-read from disk by invalidating cached data
        // This is needed because the widget writes directly to the shared database
        do {
            // Manually fetch fresh data from database
            let taskDescriptor = FetchDescriptor<TodoTask>(
                predicate: #Predicate { $0.isActive == true },
                sortBy: [SortDescriptor(\.sortOrder)]
            )
            let freshTasks = try modelContext.fetch(taskDescriptor)

            // Touch each task to ensure relationships are loaded fresh
            for task in freshTasks {
                _ = task.completions?.count
            }
        } catch {
            print("Error refreshing from database: \(error)")
        }

        updateTodayTasks()
    }

    private func updateTodayTasks() {
        // Filter tasks that belong to today's list based on recurrence pattern:
        // - One-time tasks: show if never completed OR completed today
        // - Daily tasks: always show (completed today or not)
        // - Weekly tasks: show only on selected weekdays
        // - Monthly tasks: show only on selected dates
        let filteredTasks = allActiveTasks.filter { task in
            if task.recurrenceType != .none {
                // Recurring tasks: show if scheduled for today OR already completed today
                // This handles the case where user edits recurrence after completing
                return task.shouldShowToday() || task.isCompletedToday()
            } else {
                // One-time tasks: must pass recurrence check (handles startDate)
                guard task.shouldShowToday() else { return false }
                // Show non-recurring if: never completed, or completed today
                guard let completions = task.completions, !completions.isEmpty else {
                    return true  // Never completed
                }
                // Has completions - only show if one is from today
                return task.isCompletedToday()
            }
        }

        // Sort: incomplete tasks first (by sortOrder), then completed tasks at the end
        todayTasks = filteredTasks.sorted { task1, task2 in
            let completed1 = task1.isCompletedToday()
            let completed2 = task2.isCompletedToday()

            if completed1 == completed2 {
                // Both same completion status - sort by sortOrder
                return task1.sortOrder < task2.sortOrder
            }
            // Incomplete tasks come first
            return !completed1 && completed2
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

    private func editTask(_ task: TodoTask) {
        taskToEdit = task
    }

    private func reorderTasks(_ tasks: [TodoTask]) {
        let taskService = TaskService(modelContext: modelContext)
        // Only update sortOrder for incomplete tasks
        let incompleteTasks = tasks.filter { !$0.isCompletedToday() }
        taskService.reorderTasks(incompleteTasks)
        try? modelContext.save()
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
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, CustomCategory.self, configurations: config)

    let task1 = TodoTask(title: "Morning Workout", category: "Health", sortOrder: 1)
    let task2 = TodoTask(title: "Team Meeting", category: "Work", recurrenceType: .daily, sortOrder: 2)
    let task3 = TodoTask(title: "Buy groceries", category: "Shopping", sortOrder: 3)
    container.mainContext.insert(task1)
    container.mainContext.insert(task2)
    container.mainContext.insert(task3)

    return TaskListView()
        .modelContainer(container)
}

#Preview("Empty State") {
    TaskListView()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self, CustomCategory.self], inMemory: true)
}
