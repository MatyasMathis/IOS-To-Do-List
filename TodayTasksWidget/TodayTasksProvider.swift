//
//  TodayTasksProvider.swift
//  TodayTasksWidget
//
//  Purpose: Provides timeline entries for the widget.
//  Fetches task data from the shared container.
//

import WidgetKit
import SwiftData

// MARK: - Timeline Entry

struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
    let completedCount: Int
    let totalCount: Int
}

struct WidgetTask: Identifiable {
    let id: UUID
    let title: String
    let category: String?
    let isRecurring: Bool
    let isCompletedToday: Bool
}

// MARK: - Timeline Provider

struct TodayTasksProvider: TimelineProvider {

    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(
            date: Date(),
            tasks: [
                WidgetTask(id: UUID(), title: "Morning workout", category: "Health", isRecurring: true, isCompletedToday: false),
                WidgetTask(id: UUID(), title: "Review PRs", category: "Work", isRecurring: false, isCompletedToday: false),
                WidgetTask(id: UUID(), title: "Buy groceries", category: "Shopping", isRecurring: false, isCompletedToday: true)
            ],
            completedCount: 1,
            totalCount: 3
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        Task { @MainActor in
            let entry = fetchEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        Task { @MainActor in
            let entry = fetchEntry()

            // Refresh at midnight or in 15 minutes, whichever is sooner
            let calendar = Calendar.current
            let midnight = calendar.startOfDay(
                for: calendar.date(byAdding: .day, value: 1, to: Date())!
            )
            let fifteenMinutesLater = calendar.date(byAdding: .minute, value: 15, to: Date())!
            let nextUpdate = min(midnight, fifteenMinutesLater)

            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    @MainActor
    private func fetchEntry() -> TaskEntry {
        let container = SharedModelContainer.sharedModelContainer
        let context = container.mainContext

        let descriptor = FetchDescriptor<TodoTask>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.sortOrder)]
        )

        let allTasks = (try? context.fetch(descriptor)) ?? []

        // Ensure completions relationship is loaded for each task
        for task in allTasks {
            _ = task.completions?.count
        }

        // Filter tasks that belong to today's list:
        // - Check shouldShowToday() for recurrence pattern (weekly/monthly filtering)
        // - Recurring tasks (daily/weekly/monthly): show if scheduled for today AND not completed
        // - Non-recurring tasks: show if never completed
        var todayTasks: [(task: TodoTask, isCompleted: Bool)] = []

        for task in allTasks {
            // First check if task should show today based on recurrence pattern
            guard task.shouldShowToday() else { continue }

            let isCompletedToday = task.isCompletedToday()

            if task.recurrenceType != .none {
                // Recurring task scheduled for today - only show if NOT completed today
                if !isCompletedToday {
                    todayTasks.append((task, false))
                }
            } else {
                // Non-recurring task
                let hasAnyCompletions = !(task.completions?.isEmpty ?? true)
                if !hasAnyCompletions {
                    // Never completed - include as incomplete
                    todayTasks.append((task, false))
                }
                // If has any completions, exclude (finished non-recurring task)
            }
        }

        // Sort by sortOrder
        todayTasks.sort { $0.task.sortOrder < $1.task.sortOrder }

        // For widget display: only show incomplete tasks
        // completedCount = 0 since we only show incomplete tasks
        // totalCount = number of incomplete tasks for today
        let widgetTasks = todayTasks.map { item in
            WidgetTask(
                id: item.task.id,
                title: item.task.title,
                category: item.task.category,
                isRecurring: item.task.recurrenceType != .none,
                isCompletedToday: item.isCompleted
            )
        }

        // Calculate actual completion stats from ALL tasks that should show today
        // (including completed ones for the progress calculation)
        var allTodayTaskCount = 0
        var completedTodayCount = 0

        for task in allTasks {
            guard task.shouldShowToday() else { continue }

            if task.recurrenceType != .none {
                // Recurring task scheduled for today
                allTodayTaskCount += 1
                if task.isCompletedToday() {
                    completedTodayCount += 1
                }
            } else {
                // Non-recurring: only count if never completed OR completed today
                let hasAnyCompletions = !(task.completions?.isEmpty ?? true)
                if !hasAnyCompletions {
                    allTodayTaskCount += 1
                } else if task.isCompletedToday() {
                    allTodayTaskCount += 1
                    completedTodayCount += 1
                }
            }
        }

        return TaskEntry(
            date: Date(),
            tasks: widgetTasks,
            completedCount: completedTodayCount,
            totalCount: allTodayTaskCount
        )
    }
}
