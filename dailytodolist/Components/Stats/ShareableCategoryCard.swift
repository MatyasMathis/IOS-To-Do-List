//
//  ShareableCategoryCard.swift
//  Reps
//
//  Purpose: Branded shareable card for category completion wins
//  Design: Story-sized (1080x1920), Strava-inspired layout, splash-style branding
//

import SwiftUI

/// Branded 1080x1920 card rendered offscreen via ImageRenderer.
///
/// Layout inspired by Strava activity cards:
/// - Top: branding bar
/// - Center: big stats
/// - Bottom: category + streak context
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

    // Raw theme colors (ImageRenderer can't access theme extensions)
    private let bgBlack = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let surfaceDark = Color(red: 0.10, green: 0.10, blue: 0.10)
    private let surfaceMid = Color(red: 0.165, green: 0.165, blue: 0.165)
    private let textSecondary = Color(red: 0.50, green: 0.50, blue: 0.50)
    private let greenAccent = Color(red: 0.176, green: 0.847, blue: 0.506) // recoveryGreen

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            backgroundLayer

            // Content
            VStack(spacing: 0) {
                // Top: REPS branding (splash-screen style)
                topBranding
                    .padding(.top, 100)

                Spacer()

                // Center: Category label + big stat
                centerStats

                Spacer()

                // Bottom: streak + date context
                bottomContext
                    .padding(.bottom, 100)
            }
            .padding(.horizontal, 80)
        }
        .frame(width: cardWidth, height: cardHeight)
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundLayer: some View {
        if let image = backgroundImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: cardWidth, height: cardHeight)
                .clipped()

            // Gradient overlay — heavier at top and bottom for text
            ZStack {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.75)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        } else {
            bgBlack
        }
    }

    // MARK: - Top Branding (matches SplashView)

    private var topBranding: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("REPS")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(.white)

                Text("Lock in.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
        }
    }

    // MARK: - Center Stats

    private var centerStats: some View {
        VStack(spacing: 32) {
            // Category pill
            HStack(spacing: 14) {
                Image(systemName: categoryIcon)
                    .font(.system(size: 30, weight: .semibold))
                Text(categoryName.uppercased())
                    .font(.system(size: 30, weight: .bold))
                    .tracking(3)
            }
            .foregroundStyle(categoryColor)

            // Big completion number
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(completedCount)")
                    .font(.system(size: 160, weight: .black))
                    .foregroundStyle(.white)
                Text("/\(totalCount)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.white.opacity(0.35))
            }

            // Subtitle
            Text(subtitle.uppercased())
                .font(.system(size: 24, weight: .bold))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.45))
        }
    }

    // MARK: - Bottom Context

    private var bottomContext: some View {
        HStack {
            // Streak
            if streak > 1 {
                HStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hex: "FF4444"))

                    Text("\(streak) day streak")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            Spacer()

            // Date
            Text(currentDateString)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    // MARK: - Helpers

    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
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
