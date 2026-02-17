//
//  TermsOfServiceView.swift
//  Reps
//
//  Purpose: In-app terms of service for App Store compliance
//  Design: Dark scrollable text matching Whoop aesthetic
//

import SwiftUI

/// Terms of Service displayed as a navigation destination from Settings
struct TermsOfServiceView: View {

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

                        section("Acceptance of Terms") {
                            """
                            By downloading, installing, or using REPS ("the app"), you agree to be \
                            bound by these Terms of Service. If you do not agree to these terms, \
                            do not use the app.
                            """
                        }

                        section("Description of Service") {
                            """
                            REPS is a task management and habit tracking application designed for \
                            iOS. The app allows you to create, organize, and track daily tasks and \
                            recurring habits. All data is stored locally on your device.
                            """
                        }

                        section("License") {
                            """
                            We grant you a limited, non-exclusive, non-transferable, revocable \
                            license to use REPS for personal, non-commercial purposes on any Apple \
                            device you own or control, subject to Apple's Usage Rules set forth in \
                            the App Store Terms of Service.
                            """
                        }

                        section("In-App Purchases") {
                            """
                            REPS may offer premium features available through a one-time in-app \
                            purchase ("REPS Pro"). By completing a purchase:\n\n\
                            • You gain permanent access to all premium features included at the \
                            time of purchase.\n\n\
                            • All purchases are processed by Apple and are subject to Apple's \
                            refund policies.\n\n\
                            • You can restore previous purchases on any device signed in with \
                            the same Apple ID via Settings > Restore Purchases.\n\n\
                            • Prices are displayed in your local currency and may vary by region.
                            """
                        }

                        section("User Responsibilities") {
                            """
                            You are responsible for:\n\n\
                            • Maintaining the security of your device and any data stored within \
                            the app.\n\n\
                            • Ensuring that your use of the app complies with applicable laws \
                            and regulations.\n\n\
                            • Any content you create within the app (task names, categories, etc.).
                            """
                        }

                        section("Intellectual Property") {
                            """
                            The app, including its design, code, graphics, and branding, is owned \
                            by the developer and is protected by intellectual property laws. You \
                            may not copy, modify, distribute, or create derivative works based on \
                            the app.
                            """
                        }

                        section("Disclaimer of Warranties") {
                            """
                            REPS is provided "as is" and "as available" without warranties of any \
                            kind, whether express or implied. We do not warrant that the app will \
                            be uninterrupted, error-free, or free of harmful components. Use of \
                            the app is at your sole risk.
                            """
                        }

                        section("Limitation of Liability") {
                            """
                            To the maximum extent permitted by applicable law, we shall not be \
                            liable for any indirect, incidental, special, consequential, or \
                            punitive damages, including but not limited to loss of data, arising \
                            from your use of or inability to use the app.
                            """
                        }

                        section("Data and Backups") {
                            """
                            All task data is stored locally on your device. We are not responsible \
                            for data loss resulting from device failure, app deletion, or any other \
                            cause. We recommend using iCloud device backups to protect your data.
                            """
                        }

                        section("Termination") {
                            """
                            You may stop using the app at any time by deleting it from your device. \
                            We reserve the right to modify or discontinue the app at any time \
                            without prior notice.
                            """
                        }

                        section("Changes to These Terms") {
                            """
                            We may update these Terms of Service from time to time. Changes will \
                            be reflected in the app with an updated effective date. Continued use \
                            of the app after changes constitutes acceptance of the updated terms.
                            """
                        }

                        section("Governing Law") {
                            """
                            These terms shall be governed by and construed in accordance with the \
                            laws of the European Union and applicable local jurisdiction, without \
                            regard to conflict of law principles.
                            """
                        }

                        section("Contact") {
                            """
                            If you have questions about these Terms of Service, please reach out \
                            via the Contact / Feedback option in the app's Settings.
                            """
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Terms of Service")
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
    TermsOfServiceView()
}
