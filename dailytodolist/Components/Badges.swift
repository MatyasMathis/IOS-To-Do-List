//
//  Badges.swift
//  dailytodolist
//
//  Purpose: Reusable badge components with Whoop styling
//

import SwiftUI

// MARK: - Category Badge

/// Badge displaying the task's category with Whoop-inspired styling
struct CategoryBadge: View {
    let category: String

    private var categoryColor: Color {
        Color.categoryColor(for: category)
    }

    var body: some View {
        Text(category.uppercased())
            .font(.system(size: Typography.captionSize, weight: .semibold))
            .foregroundStyle(categoryColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(categoryColor.opacity(0.2))
            .clipShape(Capsule())
    }
}

// MARK: - Recurring Badge

/// Badge indicating a task repeats daily with Whoop-inspired styling
struct RecurringBadge: View {
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "repeat")
                .font(.system(size: 10, weight: .bold))
            Text("DAILY")
                .font(.system(size: Typography.captionSize, weight: .semibold))
        }
        .foregroundStyle(Color.performancePurple)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color.performancePurple.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Time Badge

/// Badge displaying completion time
struct TimeBadge: View {
    let time: String

    var body: some View {
        Text(time)
            .font(.system(size: Typography.timeSize, weight: .medium, design: .monospaced))
            .foregroundStyle(Color.mediumGray)
    }
}

// MARK: - Streak Badge

/// Badge displaying the current streak count
struct StreakBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(
                    count >= 7 ? Color.strainRed :
                    count >= 3 ? Color.personalOrange :
                    Color.recoveryGreen
                )
            Text("\(count)")
                .font(.system(size: Typography.h4Size, weight: .bold))
                .foregroundStyle(Color.pureWhite)
        }
    }
}

// MARK: - Preview

#Preview("Badges") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        VStack(spacing: Spacing.lg) {
            HStack(spacing: Spacing.sm) {
                CategoryBadge(category: "Work")
                CategoryBadge(category: "Personal")
                CategoryBadge(category: "Health")
            }
            HStack(spacing: Spacing.sm) {
                CategoryBadge(category: "Shopping")
                CategoryBadge(category: "Other")
            }
            RecurringBadge()
            TimeBadge(time: "2:30 PM")
            HStack(spacing: Spacing.xl) {
                StreakBadge(count: 1)
                StreakBadge(count: 3)
                StreakBadge(count: 7)
            }
        }
    }
}
