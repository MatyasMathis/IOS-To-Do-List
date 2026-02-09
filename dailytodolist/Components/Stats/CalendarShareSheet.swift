//
//  CalendarShareSheet.swift
//  Reps
//
//  Purpose: Share sheet for category calendar cards
//  Design: Minimal preview with share button, matching existing share sheet pattern
//

import SwiftUI

/// Sheet for previewing and sharing a category's monthly completion calendar.
///
/// Shows a scaled-down preview of the shareable card and a share button
/// that renders the full-size card and presents the system share sheet.
struct CalendarShareSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String
    let completionDates: Set<Date>
    let displayedMonth: Date
    let streak: Int
    let completionCount: Int

    // MARK: - Computed

    private var categoryColor: Color { Color(hex: categoryColorHex) }

    private var cardView: ShareableCalendarCard {
        ShareableCalendarCard(
            categoryName: categoryName,
            categoryIcon: categoryIcon,
            categoryColorHex: categoryColorHex,
            completionDates: completionDates,
            displayedMonth: displayedMonth,
            streak: streak,
            completionCount: completionCount
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Card preview
                    cardPreview
                        .padding(.top, Spacing.lg)

                    Spacer()

                    // Share button
                    shareButton
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: Typography.bodySize, weight: .semibold))
                            .foregroundStyle(Color.mediumGray)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Share Calendar")
                        .font(.system(size: Typography.h4Size, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                }
            }
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Subviews

    private var cardPreview: some View {
        cardView
            .frame(width: 1080, height: 1920)
            .scaleEffect(0.22)
            .frame(width: 1080 * 0.22, height: 1920 * 0.22)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadowLevel1()
    }

    private var shareButton: some View {
        Button {
            ShareService.renderAndShare(
                view: cardView,
                size: CGSize(width: 1080, height: 1920)
            )
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .bold))
                Text("Share")
                    .font(.system(size: Typography.bodySize, weight: .bold))
            }
            .foregroundStyle(Color.brandBlack)
            .frame(maxWidth: .infinity)
            .frame(height: ComponentSize.buttonHeight)
            .background(categoryColor)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
        }
    }
}

// MARK: - Preview

#Preview {
    let calendar = Calendar.current
    var dates: Set<Date> = []
    for daysAgo in [0, 1, 2, 3, 5, 8, 10, 12, 15, 18, 20] {
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
            dates.insert(calendar.startOfDay(for: date))
        }
    }

    return CalendarShareSheet(
        categoryName: "Health",
        categoryIcon: "heart.fill",
        categoryColorHex: "2DD881",
        completionDates: dates,
        displayedMonth: Date(),
        streak: 4,
        completionCount: 11
    )
}
