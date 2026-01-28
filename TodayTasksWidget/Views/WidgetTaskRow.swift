//
//  WidgetTaskRow.swift
//  TodayTasksWidget
//
//  Purpose: Task row component for widget views with category and recurring badges.
//

import SwiftUI

struct WidgetTaskRow: View {
    let task: WidgetTask
    let compact: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Empty checkbox circle
            Circle()
                .stroke(Color.widgetMediumGray, lineWidth: 2)
                .frame(width: compact ? 18 : 22, height: compact ? 18 : 22)

            // Task title
            Text(task.title)
                .font(.system(size: compact ? 14 : 16, weight: .medium))
                .foregroundStyle(Color.widgetPureWhite)
                .lineLimit(1)

            Spacer()

            // Badges
            HStack(spacing: 4) {
                if let category = task.category, !category.isEmpty {
                    WidgetCategoryBadge(category: category, compact: compact)
                }

                if task.isRecurring {
                    WidgetRecurringBadge(compact: compact)
                }
            }
        }
        .padding(.horizontal, compact ? 10 : 12)
        .padding(.vertical, compact ? 8 : 10)
        .background(Color.widgetDarkGray2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Category Badge

struct WidgetCategoryBadge: View {
    let category: String
    let compact: Bool

    var body: some View {
        Text(category.uppercased())
            .font(.system(size: compact ? 9 : 10, weight: .semibold))
            .foregroundStyle(Color.widgetCategoryColor(for: category))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.widgetCategoryColor(for: category).opacity(0.2))
            .clipShape(Capsule())
    }
}

// MARK: - Recurring Badge

struct WidgetRecurringBadge: View {
    let compact: Bool

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "repeat")
                .font(.system(size: compact ? 8 : 9, weight: .bold))
            if !compact {
                Text("DAILY")
                    .font(.system(size: 9, weight: .semibold))
            }
        }
        .foregroundStyle(Color.widgetPerformancePurple)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.widgetPerformancePurple.opacity(0.15))
        .clipShape(Capsule())
    }
}
