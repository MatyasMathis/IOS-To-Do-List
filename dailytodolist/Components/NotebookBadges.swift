//
//  NotebookBadges.swift
//  dailytodolist
//
//  Purpose: Washi tape style badges for categories and recurring tasks
//  Design: Colorful tape strips with torn edge effect
//

import SwiftUI

/// Category badge styled as washi tape
struct WashiTapeBadge: View {
    let category: String
    var showEmoji: Bool = true

    private var categoryColor: Color {
        Color.forCategory(category)
    }

    private var emoji: String {
        Color.emojiForCategory(category)
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            if showEmoji {
                Text(emoji)
                    .font(.system(size: 12))
            }
            Text(category)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(categoryColor)
        .padding(.horizontal, Spacing.badgeHorizontalPadding)
        .padding(.vertical, Spacing.badgeVerticalPadding)
        .background(
            WashiTapeShape()
                .fill(categoryColor.opacity(0.2))
        )
    }
}

/// Recurring task badge styled as blue washi tape
struct RecurringWashiBadge: View {
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text("Daily")
                .font(.caption)
                .fontWeight(.medium)
            Image(systemName: "repeat")
                .font(.caption2)
        }
        .foregroundStyle(Color.bluePen)
        .padding(.horizontal, Spacing.badgeHorizontalPadding)
        .padding(.vertical, Spacing.badgeVerticalPadding)
        .background(
            WashiTapeShape()
                .fill(Color.bluePen.opacity(0.15))
        )
    }
}

/// Time badge with handwritten circle effect
struct TimeBadge: View {
    let time: Date

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter.string(from: time).lowercased()
    }

    var body: some View {
        Text(formattedTime)
            .font(.timeDisplay)
            .foregroundStyle(Color.pencilGray)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                Capsule()
                    .stroke(Color.pencilGray.opacity(0.5), lineWidth: 1)
                    .background(
                        Capsule()
                            .fill(Color.highlightYellow.opacity(0.2))
                    )
            )
    }
}

/// Washi tape shape with slightly irregular edges
struct WashiTapeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Slightly irregular rectangle for torn tape effect
        let inset: CGFloat = 1

        path.move(to: CGPoint(x: inset, y: 0))
        path.addLine(to: CGPoint(x: rect.width - inset, y: inset))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - inset))
        path.addLine(to: CGPoint(x: inset, y: rect.height))
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        WashiTapeBadge(category: "Work")
        WashiTapeBadge(category: "Personal")
        WashiTapeBadge(category: "Health")
        WashiTapeBadge(category: "Shopping")
        WashiTapeBadge(category: "Other")

        Divider()

        RecurringWashiBadge()

        Divider()

        TimeBadge(time: Date())
    }
    .padding()
    .background(Color.paperCream)
}
