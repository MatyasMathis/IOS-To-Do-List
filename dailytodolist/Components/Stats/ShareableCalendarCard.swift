//
//  ShareableCalendarCard.swift
//  Reps
//
//  Purpose: Branded shareable card showing a category's monthly completion calendar
//  Design: Clean, minimal dark card optimized for social media sharing
//

import SwiftUI

/// Branded 1080x1920 card with monthly completion calendar rendered offscreen via ImageRenderer.
///
/// Uses raw color values (not theme colors) since ImageRenderer
/// runs outside the view hierarchy.
struct ShareableCalendarCard: View {

    // MARK: - Properties

    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String
    let completionDates: Set<Date>
    let displayedMonth: Date
    let streak: Int
    let completionCount: Int

    // MARK: - Constants

    private let cardWidth: CGFloat = 1080
    private let cardHeight: CGFloat = 1920

    private var categoryColor: Color { Color(hex: categoryColorHex) }

    // Raw theme colors for ImageRenderer
    private let bgBlack = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let surfaceDark = Color(red: 0.10, green: 0.10, blue: 0.10)
    private let surfaceMid = Color(red: 0.165, green: 0.165, blue: 0.165)
    private let textSecondary = Color(red: 0.50, green: 0.50, blue: 0.50)

    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]

    // MARK: - Computed Properties

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth).uppercased()
    }

    private var daysInMonth: [ShareCalDay] {
        var days: [ShareCalDay] = []

        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)),
              let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return days
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingEmptyDays = (firstWeekday + 5) % 7

        for _ in 0..<leadingEmptyDays {
            days.append(ShareCalDay(dayNumber: 0))
        }

        let today = calendar.startOfDay(for: Date())
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                let startOfDate = calendar.startOfDay(for: date)
                days.append(ShareCalDay(
                    dayNumber: day,
                    isCompleted: completionDates.contains(startOfDate),
                    isToday: startOfDate == today,
                    isFuture: startOfDate > today
                ))
            }
        }

        return days
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background — solid dark, no distracting gradients
            bgBlack

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 200)

                // Category label
                HStack(spacing: 16) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 32, weight: .semibold))
                    Text(categoryName.uppercased())
                        .font(.system(size: 32, weight: .bold))
                        .tracking(4)
                }
                .foregroundStyle(categoryColor)
                .padding(.bottom, 64)

                // Month title — large and prominent
                Text(monthTitle)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(3)
                    .padding(.bottom, 16)

                // Completion count
                Text("\(completionCount) DAY\(completionCount == 1 ? "" : "S") COMPLETED")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(textSecondary)
                    .tracking(2)
                    .padding(.bottom, 72)

                // Calendar grid — clean, spacious
                calendarGrid
                    .padding(.horizontal, 72)

                Spacer()

                // Streak pill
                if streak > 1 {
                    HStack(spacing: 12) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(Color(hex: "FF4444"))

                        Text("\(streak) DAY STREAK")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(1.5)
                    }
                    .padding(.horizontal, 36)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.06))
                            .overlay(
                                Capsule()
                                    .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .padding(.bottom, 48)
                }

                // Branding — matches splash screen style
                Text("REPS")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(textSecondary.opacity(0.5))
                    .tracking(4)
                    .padding(.bottom, 100)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(spacing: 24) {
            // Days of week header
            HStack(spacing: 0) {
                ForEach(Array(daysOfWeek.enumerated()), id: \.offset) { _, day in
                    Text(day)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)

            // Day cells — generous spacing for clean look
            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, day in
                    shareCalDayCell(day: day)
                }
            }
        }
    }

    @ViewBuilder
    private func shareCalDayCell(day: ShareCalDay) -> some View {
        ZStack {
            if day.dayNumber > 0 {
                RoundedRectangle(cornerRadius: 22)
                    .fill(dayCellBackground(day))
                    .frame(width: 100, height: 100)

                if day.isToday {
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(Color.white, lineWidth: 3)
                        .frame(width: 100, height: 100)
                }

                Text("\(day.dayNumber)")
                    .font(.system(size: 32, weight: day.isToday ? .bold : .semibold))
                    .foregroundStyle(dayCellTextColor(day))
            }
        }
        .frame(height: 104)
    }

    private func dayCellBackground(_ day: ShareCalDay) -> Color {
        if day.isCompleted { return categoryColor }
        if day.isFuture { return .clear }
        return surfaceDark
    }

    private func dayCellTextColor(_ day: ShareCalDay) -> Color {
        if day.isFuture { return surfaceDark }
        if day.isCompleted { return bgBlack }
        return .white.opacity(0.7)
    }
}

// MARK: - Share Calendar Day Model

private struct ShareCalDay {
    let dayNumber: Int
    var isCompleted: Bool = false
    var isToday: Bool = false
    var isFuture: Bool = false
}

// MARK: - Preview

#Preview("Calendar Card") {
    let calendar = Calendar.current
    var dates: Set<Date> = []
    for daysAgo in [0, 1, 2, 3, 5, 8, 10, 12, 15, 18, 20] {
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
            dates.insert(calendar.startOfDay(for: date))
        }
    }

    return ShareableCalendarCard(
        categoryName: "Health",
        categoryIcon: "heart.fill",
        categoryColorHex: "2DD881",
        completionDates: dates,
        displayedMonth: Date(),
        streak: 4,
        completionCount: 11
    )
    .scaleEffect(0.25)
    .frame(width: 270, height: 480)
}
