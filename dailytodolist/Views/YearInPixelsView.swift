//
//  YearInPixelsView.swift
//  Reps
//
//  Purpose: Annual progress heatmap showing completion consistency
//  Design: GitHub-contribution-style grid with intensity-based coloring
//

import SwiftUI
import SwiftData

/// Year in Pixels — a full-year heatmap of daily task completions
///
/// Each day is a small square colored by completion percentage:
/// - No completions: dark gray
/// - Some completions: light green
/// - All completions: vivid green
/// Tapping shows details for that day.
struct YearInPixelsView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Queries

    @Query(sort: \TaskCompletion.completedAt, order: .reverse)
    private var allCompletions: [TaskCompletion]

    // MARK: - State

    @State private var selectedYear: Int
    @State private var selectedDayInfo: DayInfo?

    // MARK: - Init

    init() {
        _selectedYear = State(initialValue: Calendar.current.component(.year, from: Date()))
    }

    // MARK: - Computed Properties

    /// Map of date -> completion count for the selected year
    private var completionsByDate: [Date: Int] {
        let calendar = Calendar.current
        var map: [Date: Int] = [:]

        for completion in allCompletions {
            let year = calendar.component(.year, from: completion.completedAt)
            guard year == selectedYear else { continue }
            let day = calendar.startOfDay(for: completion.completedAt)
            map[day, default: 0] += 1
        }

        return map
    }

    /// All days in the selected year organized into weeks (columns)
    private var yearGrid: [[DayInfo]] {
        let calendar = Calendar.current

        // Start from Jan 1 of selected year
        var components = DateComponents()
        components.year = selectedYear
        components.month = 1
        components.day = 1
        guard let yearStart = calendar.date(from: components) else { return [] }

        let today = calendar.startOfDay(for: Date())
        let isCurrentYear = selectedYear == calendar.component(.year, from: today)

        // End date: Dec 31 or today if current year
        components.month = 12
        components.day = 31
        guard let yearEnd = calendar.date(from: components) else { return [] }
        let endDate = isCurrentYear ? min(today, yearEnd) : yearEnd

        // Build day infos
        var allDays: [DayInfo] = []
        var currentDate = yearStart

        while currentDate <= endDate {
            let count = completionsByDate[currentDate] ?? 0
            let isFuture = currentDate > today

            allDays.append(DayInfo(
                date: currentDate,
                completionCount: count,
                isFuture: isFuture,
                isToday: currentDate == today
            ))

            guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = next
        }

        // Organize into weeks (7 rows, N columns)
        // Monday = row 0, Sunday = row 6
        var weeks: [[DayInfo]] = []
        var currentWeek: [DayInfo] = []

        // Add empty slots for days before Jan 1's weekday
        if let firstDay = allDays.first {
            let weekday = calendar.component(.weekday, from: firstDay.date)
            let mondayOffset = (weekday + 5) % 7 // Convert to Monday-based (0=Mon, 6=Sun)
            for _ in 0..<mondayOffset {
                currentWeek.append(DayInfo.empty)
            }
        }

        for day in allDays {
            currentWeek.append(day)
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }

        // Add remaining partial week
        if !currentWeek.isEmpty {
            weeks.append(currentWeek)
        }

        return weeks
    }

    /// Total completions this year
    private var totalCompletions: Int {
        completionsByDate.values.reduce(0, +)
    }

    /// Days with at least one completion
    private var activeDays: Int {
        completionsByDate.filter { $0.value > 0 }.count
    }

    /// Best single day
    private var bestDay: Int {
        completionsByDate.values.max() ?? 0
    }

    /// Current year streak
    private var longestStreak: Int {
        let calendar = Calendar.current
        let sortedDates = completionsByDate.keys.sorted()
        guard !sortedDates.isEmpty else { return 0 }

        var maxStreak = 1
        var currentStreakCount = 1

        for i in 1..<sortedDates.count {
            if let expected = calendar.date(byAdding: .day, value: 1, to: sortedDates[i - 1]),
               calendar.isDate(expected, inSameDayAs: sortedDates[i]) {
                currentStreakCount += 1
                maxStreak = max(maxStreak, currentStreakCount)
            } else {
                currentStreakCount = 1
            }
        }

        return maxStreak
    }

    // MARK: - Month labels

    private var monthLabels: [(String, Int)] {
        let calendar = Calendar.current
        var labels: [(String, Int)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        for month in 1...12 {
            var comps = DateComponents()
            comps.year = selectedYear
            comps.month = month
            comps.day = 1
            guard let date = calendar.date(from: comps) else { continue }

            // Calculate which week column this month starts in
            let startOfYear = calendar.date(from: DateComponents(year: selectedYear, month: 1, day: 1))!
            let dayOfYear = calendar.dateComponents([.day], from: startOfYear, to: date).day ?? 0
            let firstDayWeekday = (calendar.component(.weekday, from: startOfYear) + 5) % 7
            let weekIndex = (dayOfYear + firstDayWeekday) / 7

            labels.append((formatter.string(from: date), weekIndex))
        }

        return labels
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xxl) {
                        // Year selector
                        yearSelector

                        // Stats summary
                        statsSummary

                        // The pixel grid
                        pixelGrid

                        // Legend
                        legend

                        // Selected day detail
                        if let info = selectedDayInfo {
                            selectedDayDetail(info)
                        }

                        Color.clear.frame(height: 40)
                    }
                    .padding(.top, Spacing.lg)
                }
            }
            .navigationTitle("Year in Pixels")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.recoveryGreen)
                }
            }
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Subviews

    private var yearSelector: some View {
        HStack(spacing: Spacing.xl) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedYear -= 1
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.pureWhite)
                    .frame(width: 44, height: 44)
            }

            Text(String(selectedYear))
                .font(.system(size: Typography.h2Size, weight: .bold, design: .rounded))
                .foregroundStyle(Color.pureWhite)
                .frame(minWidth: 100)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedYear += 1
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(canGoNext ? Color.pureWhite : Color.darkGray2)
                    .frame(width: 44, height: 44)
            }
            .disabled(!canGoNext)
        }
    }

    private var canGoNext: Bool {
        selectedYear < Calendar.current.component(.year, from: Date())
    }

    private var statsSummary: some View {
        HStack(spacing: 0) {
            statItem(value: "\(totalCompletions)", label: "TOTAL REPS")
            statItem(value: "\(activeDays)", label: "ACTIVE DAYS")
            statItem(value: "\(longestStreak)", label: "BEST STREAK")
            statItem(value: "\(bestDay)", label: "BEST DAY")
        }
        .padding(.vertical, Spacing.lg)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .padding(.horizontal, Spacing.lg)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.system(size: Typography.h3Size, weight: .bold, design: .rounded))
                .foregroundStyle(Color.recoveryGreen)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.mediumGray)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    private var pixelGrid: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Month labels
            GeometryReader { geometry in
                let cellSize: CGFloat = 11
                let spacing: CGFloat = 3
                let totalCellWidth = cellSize + spacing

                ZStack(alignment: .leading) {
                    ForEach(monthLabels, id: \.1) { label, weekIndex in
                        Text(label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color.mediumGray)
                            .offset(x: CGFloat(weekIndex) * totalCellWidth)
                    }
                }
            }
            .frame(height: 16)

            // Day labels + grid
            HStack(alignment: .top, spacing: Spacing.xs) {
                // Weekday labels
                VStack(spacing: 3) {
                    ForEach(["M", "", "W", "", "F", "", "S"], id: \.self) { label in
                        Text(label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color.mediumGray)
                            .frame(width: 14, height: 11)
                    }
                }

                // Pixel grid
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 3) {
                        ForEach(Array(yearGrid.enumerated()), id: \.offset) { weekIndex, week in
                            VStack(spacing: 3) {
                                ForEach(Array(week.enumerated()), id: \.offset) { dayIndex, day in
                                    pixelCell(for: day)
                                }
                                // Fill remaining slots if week is incomplete
                                if week.count < 7 {
                                    ForEach(0..<(7 - week.count), id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.clear)
                                            .frame(width: 11, height: 11)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .padding(.horizontal, Spacing.lg)
    }

    private func pixelCell(for day: DayInfo) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(pixelColor(for: day))
            .frame(width: 11, height: 11)
            .overlay {
                if day.isToday {
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(Color.pureWhite, lineWidth: 1)
                }
            }
            .onTapGesture {
                if !day.isEmpty {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedDayInfo = day
                    }
                }
            }
    }

    private func pixelColor(for day: DayInfo) -> Color {
        if day.isEmpty { return Color.clear }
        if day.isFuture { return Color.clear }

        let count = day.completionCount
        if count == 0 {
            return Color.darkGray2
        }

        // Intensity levels based on completion count
        switch count {
        case 1:
            return Color.recoveryGreen.opacity(0.3)
        case 2:
            return Color.recoveryGreen.opacity(0.5)
        case 3...4:
            return Color.recoveryGreen.opacity(0.7)
        default:
            return Color.recoveryGreen
        }
    }

    private var legend: some View {
        HStack(spacing: Spacing.sm) {
            Text("Less")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.mediumGray)

            ForEach([0.0, 0.3, 0.5, 0.7, 1.0], id: \.self) { opacity in
                RoundedRectangle(cornerRadius: 2)
                    .fill(opacity == 0 ? Color.darkGray2 : Color.recoveryGreen.opacity(opacity))
                    .frame(width: 11, height: 11)
            }

            Text("More")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.mediumGray)
        }
    }

    private func selectedDayDetail(_ info: DayInfo) -> some View {
        VStack(spacing: Spacing.md) {
            Text(info.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                .font(.system(size: Typography.bodySize, weight: .semibold))
                .foregroundStyle(Color.pureWhite)

            HStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.xs) {
                    Text("\(info.completionCount)")
                        .font(.system(size: Typography.h2Size, weight: .bold, design: .rounded))
                        .foregroundStyle(info.completionCount > 0 ? Color.recoveryGreen : Color.mediumGray)
                    Text("COMPLETIONS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.mediumGray)
                        .tracking(0.5)
                }
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .padding(.horizontal, Spacing.lg)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

// MARK: - Day Info Model

struct DayInfo: Equatable {
    let date: Date
    let completionCount: Int
    let isFuture: Bool
    let isToday: Bool
    let isEmpty: Bool

    init(date: Date, completionCount: Int, isFuture: Bool = false, isToday: Bool = false) {
        self.date = date
        self.completionCount = completionCount
        self.isFuture = isFuture
        self.isToday = isToday
        self.isEmpty = false
    }

    private init() {
        self.date = Date()
        self.completionCount = 0
        self.isFuture = false
        self.isToday = false
        self.isEmpty = true
    }

    static let empty = DayInfo()
}

// MARK: - Preview

#Preview {
    YearInPixelsView()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self, CustomCategory.self], inMemory: true)
}
