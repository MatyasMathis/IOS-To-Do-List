//
//  ShareableCategoryCard.swift
//  Reps
//
//  Purpose: Branded shareable card for category completion wins
//  Design: Matches Whoop-inspired app theme — dark, athletic, SF Pro
//

import SwiftUI
import UIKit

/// Branded 1080x1920 card rendered offscreen via ImageRenderer.
///
/// Uses raw color values (not theme colors) since ImageRenderer
/// runs outside the view hierarchy.
struct ShareableCategoryCard: View {

    // MARK: - Properties

    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String
    let completedCount: Int
    let totalCount: Int
    let streak: Int
    let subtitle: String
    let backgroundImage: UIImage?

    // MARK: - Constants

    private let cardWidth: CGFloat = 1080
    private let cardHeight: CGFloat = 1920

    private var categoryColor: Color { Color(hex: categoryColorHex) }

    // Raw theme colors for ImageRenderer
    private let bgBlack = Color(red: 0.04, green: 0.04, blue: 0.04)      // brandBlack
    private let surfaceDark = Color(red: 0.10, green: 0.10, blue: 0.10)   // darkGray1
    private let surfaceMid = Color(red: 0.165, green: 0.165, blue: 0.165) // darkGray2
    private let textSecondary = Color(red: 0.50, green: 0.50, blue: 0.50) // mediumGray

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            if let image = backgroundImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()

                // Heavy overlay for readability
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.55),
                        Color.black.opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                // Gradient matching app's statsCardStyle
                LinearGradient(
                    colors: [surfaceDark, bgBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            // Content
            VStack(spacing: 0) {
                Spacer()

                // Category label
                HStack(spacing: 14) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 28, weight: .semibold))
                    Text(categoryName.uppercased())
                        .font(.system(size: 28, weight: .bold))
                        .tracking(3)
                }
                .foregroundStyle(categoryColor)
                .padding(.bottom, 48)

                // Big number
                Text("\(completedCount)/\(totalCount)")
                    .font(.system(size: 120, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.bottom, 16)

                // Subtitle
                Text(subtitle.uppercased())
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(textSecondary)
                    .tracking(2)
                    .padding(.bottom, 56)

                // Streak pill
                if streak > 1 {
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(Color(hex: "FF4444"))

                        Text("\(streak) day streak")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.08))
                            .overlay(
                                Capsule()
                                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.bottom, 56)
                }

                Spacer()
                    .frame(height: 40)

                // Branding — matches splash screen style
                Text("REPS")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(textSecondary.opacity(0.5))
                    .tracking(4)
                    .padding(.bottom, 100)
            }

            // Subtle border matching app card style
            if backgroundImage == nil {
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(
                        LinearGradient(
                            colors: [surfaceMid.opacity(0.4), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            }
        }
        .frame(width: cardWidth, height: cardHeight)
    }
}

// MARK: - Preview

#Preview("Card - No Photo") {
    ShareableCategoryCard(
        categoryName: "Health",
        categoryIcon: "heart.fill",
        categoryColorHex: "2DD881",
        completedCount: 4,
        totalCount: 4,
        streak: 7,
        subtitle: "completed today",
        backgroundImage: nil
    )
    .scaleEffect(0.25)
    .frame(width: 270, height: 480)
}
