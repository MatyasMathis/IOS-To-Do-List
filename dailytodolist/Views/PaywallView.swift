//
//  PaywallView.swift
//  Reps
//
//  Purpose: Premium purchase screen shown when accessing gated features
//

import SwiftUI

struct PaywallView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(StoreService.self) private var storeService

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.section) {
                        heroSection
                        featureList
                        purchaseSection
                        restoreButton
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.mediumGray)
                            .frame(width: 30, height: 30)
                            .background(Color.darkGray2)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(Color.brandBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationBackground(Color.brandBlack)
        .onChange(of: storeService.isPremium) { _, isPremium in
            if isPremium {
                dismiss()
            }
        }
    }

    // MARK: - Subviews

    private var heroSection: some View {
        VStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.recoveryGreen.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.recoveryGreen)
            }

            Text("Unlock Reps Pro")
                .font(.system(size: Typography.h1Size, weight: .bold))
                .foregroundStyle(Color.pureWhite)

            Text("One-time purchase. Yours forever.")
                .font(.system(size: Typography.bodySize, weight: .regular))
                .foregroundStyle(Color.mediumGray)
        }
    }

    private var featureList: some View {
        VStack(spacing: Spacing.lg) {
            featureRow(
                icon: "folder.fill.badge.plus",
                title: "Custom Categories",
                subtitle: "Create categories with custom icons and colors"
            )
            featureRow(
                icon: "chart.bar.fill",
                title: "Statistics",
                subtitle: "Completion rates, streaks, and weekly rhythms"
            )
            featureRow(
                icon: "square.grid.3x3.fill",
                title: "Year in Pixels",
                subtitle: "Beautiful annual heatmap of your progress"
            )
        }
        .padding(Spacing.xl)
        .background(Color.darkGray1)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(Color.recoveryGreen)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: Typography.h4Size, weight: .semibold))
                    .foregroundStyle(Color.pureWhite)
                Text(subtitle)
                    .font(.system(size: Typography.captionSize, weight: .regular))
                    .foregroundStyle(Color.mediumGray)
            }

            Spacer()
        }
    }

    private var purchaseSection: some View {
        VStack(spacing: Spacing.md) {
            if let product = storeService.premiumProduct {
                Button {
                    Task { await storeService.purchase() }
                } label: {
                    HStack {
                        if storeService.isPurchasing {
                            ProgressView()
                                .tint(Color.pureWhite)
                        } else {
                            Text("Get Pro — \(product.displayPrice)")
                        }
                    }
                }
                .buttonStyle(.primary)
                .disabled(storeService.isPurchasing)
            } else {
                ProgressView()
                    .tint(Color.mediumGray)
            }

            if let error = storeService.errorMessage {
                Text(error)
                    .font(.system(size: Typography.captionSize, weight: .medium))
                    .foregroundStyle(Color.strainRed)
            }
        }
    }

    private var restoreButton: some View {
        Button {
            Task { await storeService.restorePurchases() }
        } label: {
            Text("Restore Purchase")
        }
        .buttonStyle(GhostButtonStyle(color: .mediumGray))
    }
}
