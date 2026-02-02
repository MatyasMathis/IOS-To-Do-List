//
//  HistoryCalendar.swift
//  dailytodolist
//
//  Purpose: Collapsible calendar for History view showing completion dates
//  Design: Allows quick navigation to specific dates in history
//

import SwiftUI
import SwiftData

/// Collapsible calendar showing all completion dates for quick navigation
struct HistoryCalendar: View {

    // MARK: - Properties

    /// All completion dates (as start of day)
    let completionDates: Set<Date>

    /// Currently displayed month
    @Binding var displayedMonth: Date

    /// Whether the calendar is expanded
    @Binding var isExpanded: Bool

    /// Callback when a date is tapped
    var onDateSelected: ((Date) -> Void)?

    // MARK: - Private Properties

    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]

    // MARK: - Computed Properties

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth).uppercased()
    }

    private var daysInMonth: [HistoryCalendarDay] {
        var days: [HistoryCalendarDay] = []

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
            days.append(HistoryCalendarDay(date: nil, dayNumber: 0))
        }

        // Add actual days
        let today = calendar.startOfDay(for: Date())
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                let startOfDate = calendar.startOfDay(for: date)
                let hasCompletions = completionDates.contains(startOfDate)
                let isToday = startOfDate == today
                let isFuture = startOfDate > today

                days.append(HistoryCalendarDay(
                    date: startOfDate,
                    dayNumber: day,
                    hasCompletions: hasCompletions,
                    isToday: isToday,
                    isFuture: isFuture
                ))
            }
        }

        return days
    }

    private var completionCountForMonth: Int {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart)!

        return completionDates.filter { $0 >= monthStart && $0 < nextMonth }.count
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header with toggle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.recoveryGreen)

                    Text("Jump to Date")
                        .font(.system(size: Typography.bodySize, weight: .medium))
                        .foregroundStyle(Color.pureWhite)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.mediumGray)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(Color.darkGray1)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
            }
            .buttonStyle(.plain)

            // Expanded calendar
            if isExpanded {
                VStack(spacing: Spacing.md) {
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
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.pureWhite)
                                .frame(width: 36, height: 36)
                        }

                        Spacer()

                        VStack(spacing: 2) {
                            Text(monthTitle)
                                .font(.system(size: Typography.captionSize, weight: .bold))
                                .foregroundStyle(Color.mediumGray)
                                .tracking(1.2)

                            Text("\(completionCountForMonth) completion\(completionCountForMonth == 1 ? "" : "s")")
                                .font(.system(size: Typography.captionSize, weight: .medium))
                                .foregroundStyle(Color.mediumGray.opacity(0.7))
                        }

                        Spacer()

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
                                    displayedMonth = nextMonth
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(canGoToNextMonth ? Color.pureWhite : Color.darkGray2)
                                .frame(width: 36, height: 36)
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
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(daysInMonth) { day in
                            HistoryCalendarDayCell(day: day) {
                                if let date = day.date, day.hasCompletions {
                                    onDateSelected?(date)
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isExpanded = false
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(Spacing.md)
                .background(Color.darkGray1)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
                .padding(.top, Spacing.xs)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
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

// MARK: - History Calendar Day Model

struct HistoryCalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    let dayNumber: Int
    var hasCompletions: Bool = false
    var isToday: Bool = false
    var isFuture: Bool = false
}

// MARK: - History Calendar Day Cell

struct HistoryCalendarDayCell: View {
    let day: HistoryCalendarDay
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background
                if day.date != nil {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 32, height: 32)

                    // Today outline
                    if day.isToday {
                        Circle()
                            .strokeBorder(Color.pureWhite, lineWidth: 2)
                            .frame(width: 32, height: 32)
                    }
                }

                // Day number
                if day.dayNumber > 0 {
                    Text("\(day.dayNumber)")
                        .font(.system(size: 14, weight: day.isToday ? .bold : .medium))
                        .foregroundStyle(textColor)
                }
            }
            .frame(height: 36)
        }
        .buttonStyle(.plain)
        .disabled(day.date == nil || day.isFuture || !day.hasCompletions)
    }

    private var backgroundColor: Color {
        if day.hasCompletions {
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
        } else if day.hasCompletions {
            return Color.brandBlack
        } else {
            return Color.mediumGray
        }
    }
}

// MARK: - Preview

#Preview("History Calendar") {
    struct PreviewWrapper: View {
        @State private var displayedMonth = Date()
        @State private var isExpanded = true

        var body: some View {
            let calendar = Calendar.current
            var dates: Set<Date> = []

            // Add some completion dates
            for daysAgo in [0, 1, 2, 3, 5, 8, 10, 15, 20, 25] {
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                    dates.insert(calendar.startOfDay(for: date))
                }
            }

            return ZStack {
                Color.brandBlack.ignoresSafeArea()
                VStack {
                    HistoryCalendar(
                        completionDates: dates,
                        displayedMonth: $displayedMonth,
                        isExpanded: $isExpanded
                    ) { date in
                        print("Selected: \(date)")
                    }
                    .padding(Spacing.lg)

                    Spacer()
                }
            }
        }
    }

    return PreviewWrapper()
}
