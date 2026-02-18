//
//  ShareToastBanner.swift
//  Reps
//
//  Purpose: Non-intrusive toast banner prompting user to share a category win
//  Design: Matches app's dark card style, auto-dismisses, tappable
//

import SwiftUI

/// A small banner that slides up from the bottom when the user
/// completes all tasks in a category. Tapping opens the share sheet.
/// Swipe down or wait 5s to dismiss — zero friction.
struct ShareToastBanner: View {

    let categoryName: String
    let categoryColorHex: String
    let categoryIcon: String
    let onTap: () -> Void
    let onDismiss: () -> Void

    @ObservedObject private var store = StoreKitService.shared

    private var categoryColor: Color { Color(hex: categoryColorHex) }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Category icon in color
                Image(systemName: categoryIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(categoryColor)

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Spacing.xs) {
                        Text("\(categoryName) complete")
                            .font(.system(size: Typography.h4Size, weight: .bold))
                            .foregroundStyle(Color.pureWhite)

                        if !store.isProUnlocked {
                            ProBadge()
                        }
                    }

                    Text(store.isProUnlocked ? "Tap to share your win" : "Unlock Pro to share your wins")
                        .font(.system(size: Typography.captionSize, weight: .medium))
                        .foregroundStyle(Color.mediumGray)
                }

                Spacer()

                // Share icon (or lock when not pro)
                Image(systemName: store.isProUnlocked ? "square.and.arrow.up" : "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(store.isProUnlocked ? categoryColor : Color.recoveryGreen)

                // Dismiss X
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.mediumGray)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.darkGray1)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.standard)
                    .strokeBorder(categoryColor.opacity(0.2), lineWidth: 1)
            )
            .shadowLevel1()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.brandBlack.ignoresSafeArea()

        VStack {
            Spacer()
            ShareToastBanner(
                categoryName: "Health",
                categoryColorHex: "2DD881",
                categoryIcon: "heart.fill",
                onTap: {},
                onDismiss: {}
            )
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, 140)
        }
    }
}
