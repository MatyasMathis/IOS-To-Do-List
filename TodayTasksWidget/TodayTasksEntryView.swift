//
//  TodayTasksEntryView.swift
//  TodayTasksWidget
//
//  Purpose: Routes to the appropriate widget view based on widget size.
//

import SwiftUI
import WidgetKit

struct TodayTasksEntryView: View {
    var entry: TaskEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
                .padding(16)
        case .systemMedium:
            MediumWidgetView(entry: entry)
                .padding(16)
        case .systemLarge:
            LargeWidgetView(entry: entry)
                .padding(16)
        default:
            SmallWidgetView(entry: entry)
                .padding(16)
        }
    }
}
