//
//  TaskListView.swift
//  dailytodolist
//
//  Purpose: Main view displaying today's tasks
//  Key responsibilities:
//  - Show list of tasks for the current day
//  - Display empty state when no tasks exist
//  - Provide entry point for adding new tasks
//  - Handle task completion, deletion, and reordering
//

import SwiftUI
import SwiftData

/// Main view for displaying and managing today's tasks
///
/// This view shows all active tasks that should appear on the current day:
/// - Non-recurring tasks that haven't been completed yet
/// - Recurring tasks that haven't been completed today
///
/// Features:
/// - List display with TaskRow components
/// - Checkbox completion with visual feedback and haptics
/// - Add task button in toolbar
/// - Edit mode for drag-and-drop reordering
/// - Swipe to delete functionality
/// - Pull-to-refresh
struct TaskListView: View {

    // MARK: - Environment

    /// SwiftData model context for database operations
    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    /// Controls the presentation of the add task sheet
    @State private var isShowingAddSheet = false

    /// Computed list of tasks filtered for today
    /// Using @State to allow filtering logic and reordering
    @State private var todayTasks: [TodoTask] = []

    /// Edit mode state for reordering
    @State private var editMode: EditMode = .inactive

    // MARK: - Queries

    /// Fetches all active tasks sorted by sort order
    /// We fetch all active tasks and then filter in-memory for today's tasks
    /// to properly handle the recurring vs non-recurring logic
    @Query(
        filter: #Predicate<TodoTask> { task in
            task.isActive == true
        },
        sort: \TodoTask.sortOrder
    )
    private var allActiveTasks: [TodoTask]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if todayTasks.isEmpty {
                    emptyStateView
                } else {
                    taskListView
                }
            }
            .navigationTitle("Today")
            .toolbar {
                // MARK: Edit Button (left side)
                ToolbarItem(placement: .topBarLeading) {
                    if !todayTasks.isEmpty {
                        EditButton()
                    }
                }

                // MARK: Add Task Button (right side)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Task")
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddTaskSheet()
            }
            .onAppear {
                updateTodayTasks()
            }
            .onChange(of: allActiveTasks) {
                updateTodayTasks()
            }
            .environment(\.editMode, $editMode)
        }
    }

    // MARK: - Subviews

    /// List view displaying today's tasks
    ///
    /// Each task is displayed using TaskRow component with completion handling.
    /// Supports:
    /// - Swipe to delete
    /// - Drag to reorder (in edit mode)
    /// - Pull to refresh
    private var taskListView: some View {
        List {
            ForEach(todayTasks) { task in
                TaskRow(task: task) { completedTask in
                    completeTask(completedTask)
                }
            }
            .onDelete(perform: deleteTasks)
            .onMove(perform: moveTasks)
        }
        .listStyle(.plain)
        .animation(.default, value: todayTasks.map { $0.id })
        .refreshable {
            await refreshTasks()
        }
    }

    /// Empty state view shown when no tasks exist
    ///
    /// Provides visual feedback that the list is empty
    /// and hints at how to add tasks
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Tasks Yet",
            systemImage: "checklist",
            description: Text("Tap + to add your first task")
        )
    }

    // MARK: - Methods

    /// Handles task completion from TaskRow
    ///
    /// Uses TaskService to toggle the completion status, then updates
    /// the today tasks list after a brief delay to allow the checkbox
    /// animation to complete before the task disappears.
    /// Triggers haptic feedback on completion.
    ///
    /// - Parameter task: The task that was completed/uncompleted
    private func completeTask(_ task: TodoTask) {
        let taskService = TaskService(modelContext: modelContext)
        let isNowCompleted = taskService.toggleTaskCompletion(task)

        // Trigger haptic feedback
        if isNowCompleted {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }

        // Delay the list update to allow the completion animation to play
        // This gives users visual feedback before the task disappears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                updateTodayTasks()
            }
        }
    }

    /// Refreshes the task list (pull-to-refresh)
    ///
    /// Re-fetches and filters tasks from the database.
    /// Uses async/await for compatibility with .refreshable modifier.
    private func refreshTasks() async {
        // Brief delay for visual feedback
        try? await Task.sleep(nanoseconds: 300_000_000)
        updateTodayTasks()
    }

    /// Updates the list of tasks shown for today
    ///
    /// Applies the filtering logic:
    /// - Recurring tasks: Show if NOT completed today
    /// - Non-recurring tasks: Show if NEVER completed
    private func updateTodayTasks() {
        todayTasks = allActiveTasks.filter { task in
            if task.isRecurring {
                // Recurring: show if not completed today
                return !task.isCompletedToday()
            } else {
                // Non-recurring: show if never completed
                return !hasEverBeenCompleted(task)
            }
        }
    }

    /// Checks if a task has ever been completed
    ///
    /// - Parameter task: The task to check
    /// - Returns: true if the task has at least one completion record
    private func hasEverBeenCompleted(_ task: TodoTask) -> Bool {
        guard let completions = task.completions else { return false }
        return !completions.isEmpty
    }

    /// Moves tasks from source indices to a destination index
    ///
    /// Called when user drags tasks to reorder in edit mode.
    /// Updates both the local array and persists new sort order.
    /// Triggers haptic feedback for the move action.
    ///
    /// - Parameters:
    ///   - source: Index set of items being moved
    ///   - destination: Target index for the moved items
    private func moveTasks(from source: IndexSet, to destination: Int) {
        // Trigger haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Update the local array
        todayTasks.move(fromOffsets: source, toOffset: destination)

        // Persist the new order using TaskService
        let taskService = TaskService(modelContext: modelContext)
        taskService.reorderTasks(todayTasks)
    }

    /// Deletes tasks at the specified offsets
    ///
    /// Called when user swipes to delete a task row.
    /// Performs a hard delete, removing the task and all its
    /// completion records from the database.
    ///
    /// - Parameter offsets: The index set of tasks to delete
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = todayTasks[index]
            modelContext.delete(task)
        }
    }
}

// MARK: - Preview

#Preview("With Tasks") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

    // Add sample tasks
    let task1 = TodoTask(title: "Buy groceries", category: "Shopping", sortOrder: 1)
    let task2 = TodoTask(title: "Morning meditation", category: "Health", isRecurring: true, sortOrder: 2)
    let task3 = TodoTask(title: "Finish project report", category: "Work", sortOrder: 3)
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
