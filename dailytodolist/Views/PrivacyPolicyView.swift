//
//  PrivacyPolicyView.swift
//  Reps
//
//  Purpose: In-app privacy policy for App Store compliance
//  Design: Dark scrollable text matching Whoop aesthetic
//

import SwiftUI

/// Privacy Policy displayed as a navigation destination from Settings
struct PrivacyPolicyView: View {

    @Environment(\.dismiss) private var dismiss

    private let effectiveDate = "February 17, 2026"

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBlack.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        Text("Effective: \(effectiveDate)")
                            .font(.system(size: Typography.captionSize, weight: .medium))
                            .foregroundStyle(Color.mediumGray)

                        section("Overview", body:
                            """
                            REPS ("we", "our", or "the app") is a task management and habit tracking \
                            application. Your privacy is important to us. This policy explains what \
                            information the app accesses, how it is used, and your rights.
                            """
                        )

                        section("Data Storage", body:
                            """
                            All your data — tasks, completions, categories, streaks, and preferences — \
                            is stored locally on your device. We do not operate servers and do not \
                            transmit your data over the internet. Your data never leaves your device.
                            """
                        )

                        section("Data We Do NOT Collect", body:
                            """
                            We do not collect, store, or share any personal information including but \
                            not limited to: your name, email address, location, device identifiers, \
                            usage analytics, crash reports, or any other personally identifiable information.
                            """
                        )

                        section("Local Storage", body:
                            """
                            The app uses on-device storage to save your tasks and preferences:\n\n\
                            • SwiftData database — stores your tasks, completions, and custom categories \
                            in a local SQLite database within the app's sandboxed container.\n\n\
                            • UserDefaults — stores lightweight preferences such as onboarding status, \
                            sound and haptic settings, and share prompt deduplication flags.\n\n\
                            • App Group — a shared container (group.com.mathis.reps) allows the main \
                            app and the Today's Tasks widget to access the same database. This data \
                            remains on your device.
                            """
                        )

                        section("Third-Party Services", body:
                            """
                            REPS does not integrate any third-party analytics, advertising, tracking, \
                            or crash reporting SDKs. The app does not make any network requests.
                            """
                        )

                        section("In-App Purchases", body:
                            """
                            REPS may offer optional in-app purchases processed by Apple. Purchase \
                            transactions are handled entirely by Apple's App Store and are subject to \
                            Apple's privacy policy. We do not have access to your payment information.
                            """
                        )

                        section("Children's Privacy", body:
                            """
                            REPS does not knowingly collect information from children. The app stores \
                            all data locally and does not require an account or any personal information \
                            to use.
                            """
                        )

                        section("Your Rights", body:
                            """
                            Since all data is stored locally on your device, you have full control:\n\n\
                            • Delete your data — uninstalling the app removes all stored data.\n\n\
                            • Export — iOS allows you to back up your device, which includes app data.\n\n\
                            • No account required — the app works entirely offline with no sign-up.
                            """
                        )

                        section("Changes to This Policy", body:
                            """
                            We may update this Privacy Policy from time to time. Any changes will be \
                            reflected in the app with an updated effective date. Continued use of the \
                            app after changes constitutes acceptance of the updated policy.
                            """
                        )

                        section("Contact", body:
                            """
                            If you have questions about this Privacy Policy, please reach out via the \
                            Contact / Feedback option in the app's Settings.
                            """
                        )
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Privacy Policy")
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

    // MARK: - Section Helper

    private func section(_ title: String, body text: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.system(size: Typography.h4Size, weight: .bold))
                .foregroundStyle(Color.pureWhite)

            Text(text)
                .font(.system(size: Typography.bodySize, weight: .regular))
                .foregroundStyle(Color.mediumGray)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#Preview {
    PrivacyPolicyView()
}
