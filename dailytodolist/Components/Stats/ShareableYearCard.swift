//
//  ShareableYearCard.swift
//  Reps
//
//  Purpose: Renders a branded Year in Pixels card for social media sharing
//  Design: Story-sized (1080x1920) dark card with heatmap grid and stats
//

import SwiftUI

/// A standalone branded card that renders the Year in Pixels heatmap
/// for sharing to Instagram Stories, TikTok, iMessage, etc.
///
/// This view is never displayed on screen — it's rendered offscreen
/// via ImageRenderer to produce a UIImage for the share sheet.
struct ShareableYearCard: View {

    // MARK: - Properties

    let year: Int
    let monthRows: [[DayInfo]]
    let monthNames: [String]
    let totalReps: Int
    let activeDays: Int
    let bestStreak: Int

    // MARK: - Constants

    private let pixelSize: CGFloat = 14
    private let pixelSpacing: CGFloat = 2.5
    private let cardWidth: CGFloat = 1080
    private let cardHeight: CGFloat = 1920

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.04, green: 0.04, blue: 0.04)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 160)

                // Title
                Text("MY \(String(year))")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(4)

                Spacer()
                    .frame(height: 80)

                // Pixel grid
                heatmapGrid
                    .padding(.horizontal, 40)

                Spacer()
                    .frame(height: 60)

                // Legend
                legendRow

                Spacer()
                    .frame(height: 80)

                // Stats
                statsRow

                Spacer()

                // Branding
                branding

                Spacer()
                    .frame(height: 100)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
    }

    // MARK: - Subviews

    private var heatmapGrid: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Day number header
            HStack(spacing: 0) {
                Color.clear.frame(width: 56, height: 20)

                ForEach(1...31, id: \.self) { day in
                    if day == 1 || day % 5 == 0 {
                        Text("\(day)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.gray)
                            .frame(width: pixelSize + pixelSpacing, height: 20)
                    } else {
                        Color.clear
                            .frame(width: pixelSize + pixelSpacing, height: 20)
                    }
                }
            }

            // Month rows
            ForEach(Array(monthRows.enumerated()), id: \.offset) { monthIndex, days in
                HStack(spacing: 0) {
                    // Month label
                    Text(monthNames[monthIndex])
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.gray)
                        .frame(width: 50, alignment: .trailing)
                        .padding(.trailing, 6)

                    // Day pixels
                    ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(sharePixelColor(for: day))
                            .frame(width: pixelSize, height: pixelSize)
                            .padding(.trailing, pixelSpacing)
                            .padding(.bottom, pixelSpacing)
                    }

                    // Pad remaining cells
                    if days.count < 31 {
                        ForEach(0..<(31 - days.count), id: \.self) { _ in
                            Color.clear
                                .frame(width: pixelSize, height: pixelSize)
                                .padding(.trailing, pixelSpacing)
                                .padding(.bottom, pixelSpacing)
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.11, green: 0.11, blue: 0.11))
        )
    }

    private var legendRow: some View {
        HStack(spacing: 10) {
            Text("Less")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray)

            ForEach([0.0, 0.3, 0.5, 0.7, 1.0], id: \.self) { opacity in
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(opacity == 0 ? Color(red: 0.18, green: 0.18, blue: 0.18) : Color(red: 0.18, green: 0.85, blue: 0.51).opacity(opacity))
                    .frame(width: 14, height: 14)
            }

            Text("More")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 40) {
            shareStatItem(value: "\(totalReps)", label: "reps")
            shareStatItem(value: "\(activeDays)", label: "days")

            if bestStreak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 1.0, green: 0.27, blue: 0.27))
                    Text("\(bestStreak)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("best")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.gray)
                        .padding(.top, 10)
                }
            }
        }
    }

    private func shareStatItem(value: String, label: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.gray)
        }
    }

    private var branding: some View {
        Text("reps.")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.18, green: 0.85, blue: 0.51).opacity(0.6))
            .tracking(2)
    }

    // MARK: - Helpers

    /// Pixel colors using raw values (not theme colors) so ImageRenderer works offscreen
    private func sharePixelColor(for day: DayInfo) -> Color {
        if day.isEmpty || day.isFuture {
            return Color.clear
        }

        let count = day.completionCount
        if count == 0 {
            return Color(red: 0.18, green: 0.18, blue: 0.18)
        }

        let green = Color(red: 0.18, green: 0.85, blue: 0.51)
        switch count {
        case 1: return green.opacity(0.3)
        case 2: return green.opacity(0.5)
        case 3...4: return green.opacity(0.7)
        default: return green
        }
    }
}

// MARK: - Preview

#Preview("Shareable Year Card") {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: Date())

    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    let names = (1...12).compactMap { month -> String? in
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        guard let date = calendar.date(from: comps) else { return nil }
        return formatter.string(from: date)
    }

    let today = calendar.startOfDay(for: Date())
    let rows: [[DayInfo]] = (1...12).map { month in
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        guard let monthStart = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        return range.map { day in
            comps.day = day
            guard let date = calendar.date(from: comps) else { return DayInfo.empty }
            let d = calendar.startOfDay(for: date)
            let count = d <= today ? Int.random(in: 0...5) : 0
            return DayInfo(date: d, completionCount: count, isFuture: d > today, isToday: d == today)
        }
    }

    return ShareableYearCard(
        year: year,
        monthRows: rows,
        monthNames: names,
        totalReps: 143,
        activeDays: 87,
        bestStreak: 31
    )
    .previewLayout(.fixed(width: 1080, height: 1920))
    .scaleEffect(0.3)
}
