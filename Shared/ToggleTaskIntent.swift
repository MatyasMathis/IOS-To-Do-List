//
//  ToggleTaskIntent.swift
//  dailytodolist
//
//  Purpose: App Intent for toggling task completion from the widget.
//

import AppIntents
import SwiftData
import WidgetKit

/// App Intent that toggles a task's completion status
struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Task Completion"
    static var description = IntentDescription("Marks a task as complete or incomplete")

    /// The ID of the task to toggle
    @Parameter(title: "Task ID")
    var taskId: String

    init() {}

    init(taskId: String) {
        self.taskId = taskId
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let container = SharedModelContainer.sharedModelContainer
        let context = container.mainContext

        // Find the task by ID
        guard let uuid = UUID(uuidString: taskId) else {
            return .result()
        }

        let descriptor = FetchDescriptor<TodoTask>(
            predicate: #Predicate { $0.id == uuid }
        )

        guard let task = try? context.fetch(descriptor).first else {
            return .result()
        }

        // Toggle completion
        if task.isCompletedToday() {
            // Uncomplete: remove today's completion
            if let completions = task.completions {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())

                if let todayCompletion = completions.first(where: { completion in
                    calendar.startOfDay(for: completion.completedAt) == today
                }) {
                    task.completions?.removeAll { $0.id == todayCompletion.id }
                    context.delete(todayCompletion)
                }
            }
        } else {
            // Complete: add completion record
            let completion = TaskCompletion(task: task)
            context.insert(completion)
            if task.completions == nil {
                task.completions = []
            }
            task.completions?.append(completion)
        }

        // Save and refresh widget
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}
