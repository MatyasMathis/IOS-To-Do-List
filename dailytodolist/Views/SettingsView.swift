//
//  SettingsView.swift
//  Reps
//
//  Purpose: App settings screen with sound, haptic, and info controls
//  Design: Dark theme with grouped sections matching Whoop aesthetic
//

import SwiftUI

/// Settings screen presented as a sheet from the main task list
struct SettingsView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Persisted Preferences

    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled: Bool = true

    // MARK: - Sheet State

    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false

    // MARK: - Computed

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xxl) {
                        appInfoSection
                        proStatusSection
                        generalSection
                        dataSection
                        aboutSection
                        footerSection
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: Typography.h3Size, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                }

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
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        VStack(spacing: Spacing.sm) {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("REPS")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .tracking(3)
                .foregroundStyle(Color.pureWhite)

            Text("Lock in.")
                .font(.system(size: Typography.bodySize, weight: .medium))
                .foregroundStyle(Color.mediumGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }

    // MARK: - PRO Status Section

    private var proStatusSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionLabel("STATUS")

            HStack {
                Image(systemName: "crown")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.mediumGray)

                Text("Free Plan")
                    .font(.system(size: Typography.bodySize, weight: .medium))
                    .foregroundStyle(Color.pureWhite)

                Spacer()

                Text("FREE")
                    .font(.system(size: Typography.captionSize, weight: .bold))
                    .foregroundStyle(Color.mediumGray)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.darkGray2)
                    .clipShape(Capsule())
            }
            .padding(Spacing.lg)
            .background(Color.darkGray1)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
        }
    }

    // MARK: - General Section

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionLabel("GENERAL")

            VStack(spacing: 0) {
                settingsToggleRow(
                    icon: "speaker.wave.2",
                    title: "Completion Sound",
                    subtitle: "Play sound when completing tasks",
                    isOn: $soundEnabled
                )

                Divider()
                    .background(Color.darkGray2)

                settingsToggleRow(
                    icon: "hand.tap",
                    title: "Haptic Feedback",
                    subtitle: "Vibration on interactions",
                    isOn: $hapticFeedbackEnabled
                )
            }
            .background(Color.darkGray1)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionLabel("DATA")

            Button {
                // Placeholder: restore purchases
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.recoveryGreen)

                    Text("Restore Purchases")
                        .font(.system(size: Typography.bodySize, weight: .medium))
                        .foregroundStyle(Color.pureWhite)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.mediumGray)
                }
                .padding(Spacing.lg)
                .background(Color.darkGray1)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionLabel("ABOUT")

            VStack(spacing: 0) {
                aboutRow(icon: "star", title: "Rate on App Store") {
                    // Placeholder: open App Store review
                }
                Divider().background(Color.darkGray2)
                aboutRow(icon: "hand.raised", title: "Privacy Policy") {
                    showPrivacyPolicy = true
                }
                Divider().background(Color.darkGray2)
                aboutRow(icon: "doc.text", title: "Terms of Service") {
                    showTermsOfService = true
                }
                Divider().background(Color.darkGray2)
                aboutRow(icon: "envelope", title: "Contact / Feedback") {
                    // Placeholder: open mail or feedback form
                }
            }
            .background(Color.darkGray1)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: Spacing.xs) {
            Text("Made with dedication")
                .font(.system(size: Typography.captionSize, weight: .medium))
                .foregroundStyle(Color.mediumGray)

            Text(appVersion)
                .font(.system(size: Typography.captionSize, weight: .medium))
                .foregroundStyle(Color.mediumGray.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.lg)
    }

    // MARK: - Reusable Components

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: Typography.labelSize, weight: .semibold))
            .foregroundStyle(Color.mediumGray)
            .tracking(0.8)
    }

    private func settingsToggleRow(
        icon: String,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.recoveryGreen)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: Typography.bodySize, weight: .medium))
                    .foregroundStyle(Color.pureWhite)

                Text(subtitle)
                    .font(.system(size: Typography.captionSize, weight: .regular))
                    .foregroundStyle(Color.mediumGray)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.recoveryGreen)
        }
        .padding(Spacing.lg)
    }

    private func aboutRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.mediumGray)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: Typography.bodySize, weight: .medium))
                    .foregroundStyle(Color.pureWhite)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.mediumGray)
            }
            .padding(Spacing.lg)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
