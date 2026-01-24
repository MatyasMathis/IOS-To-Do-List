//
//  TaskListView.swift
//  dailytodolist
//
//  Purpose: Main view displaying today's tasks with notebook styling
//  Design: Paper background, binding holes, progress card, floating pen button
//

import SwiftUI
import SwiftData

/// Main view for displaying and managing today's tasks
struct TaskListView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

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

    private var completedTodayCount: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        return allCompletions.filter { completion in
            calendar.isDate(completion.completedAt, inSameDayAs: startOfToday)
        }.count
    }

    private var totalTodayCount: Int {
        todayTasks.count + completedTodayCount
    }

    private var progressValue: Double {
        guard totalTodayCount > 0 else { return 0 }
        return Double(completedTodayCount) / Double(totalTodayCount)
    }

    private var formattedDate: String {
        Date().formatted(.dateTime.month(.abbreviated).day())
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Notebook paper background
                NotebookBackground(showBindingHoles: true, showMarginLine: true)
                    .ignoresSafeArea()

                // Content
                if todayTasks.isEmpty && completedTodayCount == 0 {
                    emptyStateView
                } else {
                    taskListContent
                }

                // Floating pen button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingPenButton {
                            isShowingAddSheet = true
                        }
                        .padding(.trailing, Spacing.xxl)
                        .padding(.bottom, Spacing.xxxl)
                    }
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

                        Text("Today's Tasks")
                            .font(.handwrittenHeader)
                            .foregroundStyle(Color.inkBlack)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Text(formattedDate)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.pencilGray)
                }
            }
            .toolbarBackground(Color.paperCream, for: .navigationBar)
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
            .environment(\.editMode, $editMode)
        }
    }

    // MARK: - Subviews

    private var taskListContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Progress card (index card style)
                IndexCard {
                    Text("Tasks Done: \(completedTodayCount)/\(totalTodayCount)")
                        .font(.handwrittenBody)
                        .foregroundStyle(Color.inkBlack)

                    // Hand-drawn style progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.ruledLines)
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.greenCheckmark)
                                .frame(width: geometry.size.width * progressValue, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.lg)

                // Task list
                ForEach(todayTasks) { task in
                    TaskRow(task: task) { completedTask in
                        completeTask(completedTask)
                    }
                }

                // Bottom padding for FAB
                Color.clear.frame(height: 100)
            }
        }
        .refreshable {
            await refreshTasks()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "book.pages")
                .font(.system(size: 80))
                .foregroundStyle(Color.pencilGray.opacity(0.5))

            Text("A Fresh Page Awaits")
                .font(.handwrittenTitle)
                .foregroundStyle(Color.inkBlack)

            Text("Grab your pen and jot down your first task")
                .font(.system(size: 16))
                .foregroundStyle(Color.pencilGray)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xxl)
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
