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

        // Filter tasks that belong to today's list:
        // - Recurring tasks: always show (completed today or not)
        // - Non-recurring tasks: show if never completed OR completed today
        var todayTasks: [(task: TodoTask, isCompleted: Bool)] = []

        for task in allTasks {
            let isCompletedToday = task.isCompletedToday()

            if task.isRecurring {
                // Always include recurring tasks
                todayTasks.append((task, isCompletedToday))
            } else {
                let hasAnyCompletions = !(task.completions?.isEmpty ?? true)
                if !hasAnyCompletions {
                    // Never completed - include
                    todayTasks.append((task, false))
                } else if isCompletedToday {
                    // Has completions but completed today - include
                    todayTasks.append((task, true))
                }
                // If has completions but not today, exclude (finished non-recurring)
            }
        }

        // Sort: incomplete tasks first, then completed tasks at the end
        todayTasks.sort { item1, item2 in
            if item1.isCompleted == item2.isCompleted {
                return item1.task.sortOrder < item2.task.sortOrder
            }
            return !item1.isCompleted && item2.isCompleted
        }

        let completedCount = todayTasks.filter { $0.isCompleted }.count

        let widgetTasks = todayTasks.map { item in
            WidgetTask(
                id: item.task.id,
                title: item.task.title,
                category: item.task.category,
                isRecurring: item.task.isRecurring,
                isCompletedToday: item.isCompleted
            )
        }

        return TaskEntry(
            date: Date(),
            tasks: widgetTasks,
            completedCount: completedCount,
            totalCount: todayTasks.count
        )
    }
}
