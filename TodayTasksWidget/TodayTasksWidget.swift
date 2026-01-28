//
//  TodayTasksWidget.swift
//  TodayTasksWidget
//
//  Purpose: Main widget configuration for Today's Tasks widget.
//

import WidgetKit
import SwiftUI

struct TodayTasksWidget: Widget {
    let kind: String = "TodayTasksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayTasksProvider()) { entry in
            TodayTasksEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: "0A0A0A")
                }
        }
        .configurationDisplayName("Today's Tasks")
        .description("View your tasks for today at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    TodayTasksWidget()
} timeline: {
    TaskEntry(
        date: Date(),
        tasks: [
            WidgetTask(id: UUID(), title: "Morning workout", category: "Health", isRecurring: true),
            WidgetTask(id: UUID(), title: "Review PRs", category: "Work", isRecurring: false)
        ],
        completedCount: 2,
        totalCount: 5
    )
}

#Preview(as: .systemMedium) {
    TodayTasksWidget()
} timeline: {
    TaskEntry(
        date: Date(),
        tasks: [
            WidgetTask(id: UUID(), title: "Morning workout", category: "Health", isRecurring: true),
            WidgetTask(id: UUID(), title: "Review PRs", category: "Work", isRecurring: true),
            WidgetTask(id: UUID(), title: "Buy groceries", category: "Shopping", isRecurring: false)
        ],
        completedCount: 2,
        totalCount: 5
    )
}

#Preview(as: .systemLarge) {
    TodayTasksWidget()
} timeline: {
    TaskEntry(
        date: Date(),
        tasks: [
            WidgetTask(id: UUID(), title: "Morning workout", category: "Health", isRecurring: true),
            WidgetTask(id: UUID(), title: "Review PRs", category: "Work", isRecurring: true),
            WidgetTask(id: UUID(), title: "Team standup", category: "Work", isRecurring: true),
            WidgetTask(id: UUID(), title: "Buy groceries", category: "Shopping", isRecurring: false),
            WidgetTask(id: UUID(), title: "Call mom", category: "Personal", isRecurring: false)
        ],
        completedCount: 2,
        totalCount: 7
    )
}
