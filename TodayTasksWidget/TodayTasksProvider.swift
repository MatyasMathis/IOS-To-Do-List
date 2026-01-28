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
}

// MARK: - Timeline Provider

struct TodayTasksProvider: TimelineProvider {

    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(
            date: Date(),
            tasks: [
                WidgetTask(id: UUID(), title: "Morning workout", category: "Health", isRecurring: true),
                WidgetTask(id: UUID(), title: "Review PRs", category: "Work", isRecurring: false),
                WidgetTask(id: UUID(), title: "Buy groceries", category: "Shopping", isRecurring: false)
            ],
            completedCount: 2,
            totalCount: 5
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

        var incompleteTasks: [TodoTask] = []
        var completedTodayCount = 0

        for task in allTasks {
            let isCompletedToday = task.isCompletedToday()

            if isCompletedToday {
                completedTodayCount += 1
            }

            if task.isRecurring {
                if !isCompletedToday {
                    incompleteTasks.append(task)
                }
            } else {
                let hasAnyCompletions = !(task.completions?.isEmpty ?? true)
                if !hasAnyCompletions {
                    incompleteTasks.append(task)
                }
            }
        }

        let widgetTasks = incompleteTasks.map { task in
            WidgetTask(
                id: task.id,
                title: task.title,
                category: task.category,
                isRecurring: task.isRecurring
            )
        }

        let totalCount = incompleteTasks.count + completedTodayCount

        return TaskEntry(
            date: Date(),
            tasks: widgetTasks,
            completedCount: completedTodayCount,
            totalCount: totalCount
        )
    }
}
