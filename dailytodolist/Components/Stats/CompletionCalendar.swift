//
//  CompletionCalendar.swift
//  dailytodolist
//
//  Purpose: Monthly calendar grid showing task completion dates
//

import SwiftUI
import SwiftData

/// Monthly calendar showing completion dates for a task
struct CompletionCalendar: View {

    // MARK: - Properties

    let task: TodoTask
    @Binding var displayedMonth: Date
    var onDateTapped: ((Date) -> Void)?

    // MARK: - Private Properties

    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]

    // MARK: - Computed Properties

    private var completionDates: Set<Date> {
        guard let completions = task.completions else { return [] }
        return Set(completions.map { calendar.startOfDay(for: $0.completedAt) })
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth).uppercased()
    }

    private var daysInMonth: [StatsCalendarDay] {
        var days: [StatsCalendarDay] = []

        // Get the first day of the month
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)),
              let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return days
        }

        // Get the weekday of the first day (1 = Sunday, 2 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        // Convert to Monday-based (0 = Monday, 6 = Sunday)
        let leadingEmptyDays = (firstWeekday + 5) % 7

        // Add empty days for alignment
        for _ in 0..<leadingEmptyDays {
            days.append(StatsCalendarDay(date: nil, dayNumber: 0))
        }

        // Add actual days
        let today = calendar.startOfDay(for: Date())
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                let startOfDate = calendar.startOfDay(for: date)
                let isCompleted = completionDates.contains(startOfDate)
                let isToday = startOfDate == today
                let isFuture = startOfDate > today

                days.append(StatsCalendarDay(
                    date: startOfDate,
                    dayNumber: day,
                    isCompleted: isCompleted,
                    isToday: isToday,
                    isFuture: isFuture
                ))
            }
        }

        return days
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Month navigation
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
                            displayedMonth = previousMonth
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.pureWhite)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Text(monthTitle)
                    .font(.system(size: Typography.labelSize, weight: .bold))
                    .foregroundStyle(Color.mediumGray)
                    .tracking(1.5)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
                            displayedMonth = nextMonth
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(canGoToNextMonth ? Color.pureWhite : Color.darkGray2)
                        .frame(width: 44, height: 44)
                }
                .disabled(!canGoToNextMonth)
            }

            // Days of week header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: Typography.captionSize, weight: .semibold))
                        .foregroundStyle(Color.mediumGray)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.xs), count: 7)

            LazyVGrid(columns: columns, spacing: Spacing.sm) {
                ForEach(daysInMonth) { day in
                    StatsCalendarDayCell(day: day) {
                        if let date = day.date {
                            onDateTapped?(date)
                        }
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }

    // MARK: - Helpers

    private var canGoToNextMonth: Bool {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else {
            return false
        }
        let nextMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth))!
        let today = calendar.startOfDay(for: Date())
        return nextMonthStart <= today
    }
}

// MARK: - Calendar Day Model

private struct StatsCalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    let dayNumber: Int
    var isCompleted: Bool = false
    var isToday: Bool = false
    var isFuture: Bool = false
}

// MARK: - Calendar Day Cell

private struct StatsCalendarDayCell: View {
    let day: StatsCalendarDay
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background circle
                if day.date != nil {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 36, height: 36)

                    // Today outline
                    if day.isToday {
                        Circle()
                            .strokeBorder(Color.pureWhite, lineWidth: 2)
                            .frame(width: 36, height: 36)
                    }
                }

                // Day number
                if day.dayNumber > 0 {
                    Text("\(day.dayNumber)")
                        .font(.system(size: Typography.bodySize, weight: day.isToday ? .bold : .medium))
                        .foregroundStyle(textColor)
                }
            }
            .frame(height: 40)
        }
        .buttonStyle(.plain)
        .disabled(day.date == nil || day.isFuture)
    }

    private var backgroundColor: Color {
        if day.isCompleted {
            return Color.recoveryGreen
        } else if day.isFuture {
            return Color.clear
        } else {
            return Color.darkGray2
        }
    }

    private var textColor: Color {
        if day.isFuture {
            return Color.darkGray2
        } else if day.isCompleted {
            return Color.brandBlack
        } else {
            return Color.pureWhite
        }
    }
}

// MARK: - Preview

#Preview("Completion Calendar") {
    struct PreviewWrapper: View {
        @State private var displayedMonth = Date()

        var body: some View {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

            let task = TodoTask(title: "Morning Exercise", category: "Health", recurrenceType: .daily)
            container.mainContext.insert(task)

            // Add some completions
            let calendar = Calendar.current
            for daysAgo in [0, 1, 2, 3, 5, 6, 8, 10, 12, 15, 20] {
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                    let completion = TaskCompletion(task: task, completedAt: date)
                    container.mainContext.insert(completion)
                }
            }

            return ZStack {
                Color.brandBlack.ignoresSafeArea()
                VStack {
                    CompletionCalendar(
                        task: task,
                        displayedMonth: $displayedMonth
                    ) { _ in
                        // Handle date tap in preview
                    }
                    .padding(Spacing.lg)

                    Spacer()
                }
            }
        }
    }

    return PreviewWrapper()
}
