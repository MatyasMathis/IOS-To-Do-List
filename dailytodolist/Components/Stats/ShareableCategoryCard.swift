//
//  ShareableCategoryCard.swift
//  Reps
//
//  Purpose: Strava-style shareable card shown when all tasks in a category are completed
//  Design: Story-sized (1080x1920) with user photo background, dark overlay, category stats
//

import SwiftUI

/// A Strava-style branded card for sharing category completion wins.
///
/// Rendered offscreen via ImageRenderer — uses raw color values, not theme colors.
struct ShareableCategoryCard: View {

    // MARK: - Properties

    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String
    let completedCount: Int
    let totalCount: Int
    let streak: Int
    let backgroundImage: UIImage?

    // MARK: - Constants

    private let cardWidth: CGFloat = 1080
    private let cardHeight: CGFloat = 1920

    /// Category color derived from hex
    private var categoryColor: Color {
        Color(hex: categoryColorHex)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Layer 1: Photo background or solid dark
            if let image = backgroundImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()
            } else {
                Color(red: 0.04, green: 0.04, blue: 0.04)
            }

            // Layer 2: Dark gradient overlay for text readability
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Layer 3: Content
            VStack(spacing: 0) {
                Spacer()

                // Category pill
                categoryPill
                    .padding(.bottom, 40)

                // Big completion count
                completionBlock
                    .padding(.bottom, 32)

                // "completed today" label
                Text("COMPLETED TODAY")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(3)
                    .padding(.bottom, 60)

                // Streak (if active)
                if streak > 0 {
                    streakRow
                        .padding(.bottom, 60)
                }

                Spacer()
                    .frame(height: 80)

                // Branding
                branding
                    .padding(.bottom, 120)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
    }

    // MARK: - Subviews

    private var categoryPill: some View {
        HStack(spacing: 12) {
            Image(systemName: categoryIcon)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(categoryColor)

            Text(categoryName.uppercased())
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(categoryColor)
                .tracking(2)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.5))
                .overlay(
                    Capsule()
                        .strokeBorder(categoryColor.opacity(0.4), lineWidth: 2)
                )
        )
    }

    private var completionBlock: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(completedCount)")
                .font(.system(size: 140, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("/\(totalCount)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var streakRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(red: 1.0, green: 0.27, blue: 0.27))

            Text("\(streak) day streak")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 18)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
        )
    }

    private var branding: some View {
        Text("reps.")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(.white.opacity(0.35))
            .tracking(2)
    }
}

// MARK: - Preview

#Preview("Category Card - With Photo") {
    ShareableCategoryCard(
        categoryName: "Health",
        categoryIcon: "heart.fill",
        categoryColorHex: "2DD881",
        completedCount: 4,
        totalCount: 4,
        streak: 7,
        backgroundImage: nil
    )
    .previewLayout(.fixed(width: 1080, height: 1920))
    .scaleEffect(0.3)
}
