//
//  SplashView.swift
//  Reps
//
//  Purpose: Launch screen with animated logo
//  Design: Athletic, premium aesthetic matching app branding
//

import SwiftUI

/// Animated splash screen shown on app launch
struct SplashView: View {

    // MARK: - State

    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var glowOpacity: Double = 0

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color.brandBlack
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Logo container
                ZStack {
                    // Glow effect behind logo
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.recoveryGreen.opacity(0.3),
                                    Color.recoveryGreen.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .opacity(glowOpacity)

                    // Logo
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                // App name
                VStack(spacing: 8) {
                    Text("REPS")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .tracking(4)
                        .foregroundStyle(Color.pureWhite)

                    Text("Get shit done.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.mediumGray)
                }
                .opacity(textOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            animateSplash()
        }
    }

    // MARK: - Animation

    private func animateSplash() {
        // Logo entrance
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Glow pulse
        withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
            glowOpacity = 1.0
        }

        // Text fade in
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            textOpacity = 1.0
        }

        // Subtle haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
}

// MARK: - Preview

#Preview("Splash Screen") {
    SplashView()
}
