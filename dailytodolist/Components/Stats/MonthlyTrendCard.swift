//
//  MonthlyTrendCard.swift
//  Reps
//
//  Purpose: Shows this month vs last month completion comparison
//  Design: Simple side-by-side with trend arrow
//

import SwiftUI

/// Compares this month's completions to last month
struct MonthlyTrendCard: View {

    // MARK: - Properties

    /// All completion dates to analyze
    let completions: [Date]

    /// Accent color (defaults to recovery green)
    var accentColor: Color = .recoveryGreen

    // MARK: - Computed Properties

    private let calendar = Calendar.current

    private var thisMonthCount: Int {
        let now = Date()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return 0 }
        return completions.filter { $0 >= monthStart }.count
    }

    private var lastMonthCount: Int {
        let now = Date()
        guard let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) else { return 0 }
        return completions.filter { $0 >= lastMonthStart && $0 < thisMonthStart }.count
    }

    private var trendPercentage: Int? {
        guard lastMonthCount > 0 else { return nil }
        let change = Double(thisMonthCount - lastMonthCount) / Double(lastMonthCount) * 100
        return Int(change)
    }

    private var isPositiveTrend: Bool {
        thisMonthCount >= lastMonthCount
    }

    private var thisMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: Date())
    }

    private var lastMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else { return "" }
        return formatter.string(from: lastMonth)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Section label
            Text("TREND")
                .font(.system(size: Typography.captionSize, weight: .bold))
                .foregroundStyle(Color.mediumGray)
                .tracking(1.0)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                // This month
                VStack(spacing: Spacing.xs) {
                    Text("\(thisMonthCount)")
                        .font(.system(size: Typography.h2Size, weight: .bold, design: .rounded))
                        .foregroundStyle(accentColor)
                    Text(thisMonthName.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.mediumGray)
                        .tracking(0.5)
                }
                .frame(maxWidth: .infinity)

                // Trend indicator
                VStack(spacing: Spacing.xs) {
                    Image(systemName: isPositiveTrend ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(isPositiveTrend ? Color.recoveryGreen : Color.strainRed)

                    if let pct = trendPercentage {
                        Text("\(abs(pct))%")
                            .font(.system(size: Typography.captionSize, weight: .bold))
                            .foregroundStyle(isPositiveTrend ? Color.recoveryGreen : Color.strainRed)
                    }
                }
                .frame(width: 60)

                // Last month
                VStack(spacing: Spacing.xs) {
                    Text("\(lastMonthCount)")
                        .font(.system(size: Typography.h2Size, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.mediumGray)
                    Text(lastMonthName.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.mediumGray)
                        .tracking(0.5)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(Spacing.lg)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}

// MARK: - Preview

#Preview("Monthly Trend Card") {
    let calendar = Calendar.current
    var dates: [Date] = []

    // This month: 15 completions
    for day in 1...15 {
        if let date = calendar.date(byAdding: .day, value: -day, to: Date()) {
            dates.append(date)
        }
    }

    // Last month: 10 completions
    if let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: Date()) {
        for day in 0..<10 {
            if let date = calendar.date(byAdding: .day, value: day, to: lastMonthStart) {
                dates.append(date)
            }
        }
    }

    return ZStack {
        Color.brandBlack.ignoresSafeArea()
        MonthlyTrendCard(completions: dates)
            .padding(Spacing.lg)
    }
}
