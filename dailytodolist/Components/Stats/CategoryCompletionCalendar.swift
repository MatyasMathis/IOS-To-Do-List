//
//  CategoryCompletionCalendar.swift
//  Reps
//
//  Purpose: Monthly calendar showing completions for a category (or all tasks)
//  Design: Reuses the same visual language as CompletionCalendar but works with date sets
//

import SwiftUI

/// Monthly calendar showing completion dates from a set of dates
struct CategoryCompletionCalendar: View {

    // MARK: - Properties

    /// Set of dates that have completions
    let completionDates: Set<Date>

    /// Displayed month (bound to parent for navigation)
    @Binding var displayedMonth: Date

    /// Accent color for completion dots
    var accentColor: Color = .recoveryGreen

    // MARK: - Private Properties

    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]

    // MARK: - Computed Properties

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth).uppercased()
    }

    private var completionCountForMonth: Int {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        return completionDates.filter { $0 >= monthStart && $0 < nextMonth }.count
    }

    private var daysInMonth: [CalDay] {
        var days: [CalDay] = []

        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)),
              let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return days
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingEmptyDays = (firstWeekday + 5) % 7

        for _ in 0..<leadingEmptyDays {
            days.append(CalDay(date: nil, dayNumber: 0))
        }

        let today = calendar.startOfDay(for: Date())
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                let startOfDate = calendar.startOfDay(for: date)
                days.append(CalDay(
                    date: startOfDate,
                    dayNumber: day,
                    isCompleted: completionDates.contains(startOfDate),
                    isToday: startOfDate == today,
                    isFuture: startOfDate > today
                ))
            }
        }

        return days
    }

    private var canGoToNextMonth: Bool {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return false }
        let nextMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth))!
        return nextMonthStart <= calendar.startOfDay(for: Date())
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Month navigation
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if let prev = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
                            displayedMonth = prev
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.pureWhite)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(monthTitle)
                        .font(.system(size: Typography.captionSize, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                        .tracking(1.2)

                    Text("\(completionCountForMonth) completion\(completionCountForMonth == 1 ? "" : "s")")
                        .font(.system(size: Typography.captionSize, weight: .medium))
                        .foregroundStyle(Color.mediumGray)
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if let next = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
                            displayedMonth = next
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
                    CalDayCell(day: day, accentColor: accentColor)
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

// MARK: - Calendar Day Model

private struct CalDay: Identifiable {
    let id = UUID()
    let date: Date?
    let dayNumber: Int
    var isCompleted: Bool = false
    var isToday: Bool = false
    var isFuture: Bool = false
}

// MARK: - Calendar Day Cell

private struct CalDayCell: View {
    let day: CalDay
    var accentColor: Color = .recoveryGreen

    var body: some View {
        ZStack {
            if day.date != nil {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 36, height: 36)

                if day.isToday {
                    Circle()
                        .strokeBorder(Color.pureWhite, lineWidth: 2)
                        .frame(width: 36, height: 36)
                }
            }

            if day.dayNumber > 0 {
                Text("\(day.dayNumber)")
                    .font(.system(size: Typography.bodySize, weight: day.isToday ? .bold : .medium))
                    .foregroundStyle(textColor)
            }
        }
        .frame(height: 40)
    }

    private var backgroundColor: Color {
        if day.isCompleted { return accentColor }
        if day.isFuture { return Color.clear }
        return Color.darkGray2
    }

    private var textColor: Color {
        if day.isFuture { return Color.darkGray2 }
        if day.isCompleted { return Color.brandBlack }
        return Color.pureWhite
    }
}

// MARK: - Preview

#Preview("Category Completion Calendar") {
    struct PreviewWrapper: View {
        @State private var month = Date()

        var body: some View {
            let calendar = Calendar.current
            var dates: Set<Date> = []
            for daysAgo in [0, 1, 2, 3, 5, 8, 12, 15] {
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                    dates.insert(calendar.startOfDay(for: date))
                }
            }

            return ZStack {
                Color.brandBlack.ignoresSafeArea()
                CategoryCompletionCalendar(completionDates: dates, displayedMonth: $month)
                    .padding(Spacing.lg)
            }
        }
    }

    return PreviewWrapper()
}
