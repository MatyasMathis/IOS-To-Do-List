import SwiftUI

/// Progress Ring Logo - The official app logo
/// A circular progress ring with a centered checkmark representing daily task completion
struct AppLogo: View {
    /// Size of the logo (width and height)
    var size: CGFloat = 200

    /// Progress value from 0.0 to 1.0 (default 0.75 for static display)
    var progress: CGFloat = 0.75

    /// Whether to animate the ring drawing
    var animated: Bool = false

    /// Whether to show the background
    var showBackground: Bool = true

    @State private var animatedProgress: CGFloat = 0

    private var ringWidth: CGFloat { size * 0.0625 } // 64/1024 ratio
    private var ringRadius: CGFloat { size * 0.332 } // 340/1024 ratio

    var body: some View {
        ZStack {
            // Background
            if showBackground {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.darkGray1, Color.brandBlack]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size / 2
                        )
                    )
            }

            // Ring Track (background)
            Circle()
                .stroke(Color.darkGray2, lineWidth: ringWidth)
                .frame(width: ringRadius * 2, height: ringRadius * 2)

            // Progress Ring with gradient
            Circle()
                .trim(from: 0, to: animated ? animatedProgress : progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.performancePurple,
                            Color(hex: "#4ECDC4"),
                            Color.recoveryGreen
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .frame(width: ringRadius * 2, height: ringRadius * 2)
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.recoveryGreen.opacity(0.4), radius: size * 0.015, x: 0, y: 0)

            // Checkmark
            CheckmarkShape()
                .stroke(Color.white, style: StrokeStyle(lineWidth: size * 0.055, lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.3, height: size * 0.22)
                .offset(y: size * 0.01)
        }
        .frame(width: size, height: size)
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 1.0)) {
                    animatedProgress = progress
                }
            }
        }
    }
}

/// Custom checkmark shape for the logo
struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Checkmark points (normalized from SVG: 380,520 -> 470,610 -> 644,420)
        // Translated to rect coordinates
        let startX = rect.width * 0.0
        let startY = rect.height * 0.526

        let midX = rect.width * 0.341
        let midY = rect.height * 1.0

        let endX = rect.width * 1.0
        let endY = rect.height * 0.0

        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: midX, y: midY))
        path.addLine(to: CGPoint(x: endX, y: endY))

        return path
    }
}

/// Compact logo version for small spaces (tab bar, etc.)
struct AppLogoCompact: View {
    var size: CGFloat = 28
    var tintColor: Color = .recoveryGreen

    var body: some View {
        ZStack {
            // Simple ring
            Circle()
                .stroke(tintColor.opacity(0.3), lineWidth: size * 0.1)

            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(tintColor, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(tintColor)
        }
        .frame(width: size, height: size)
    }
}

/// Logo with wordmark for splash screens and about pages
struct AppLogoWithWordmark: View {
    var logoSize: CGFloat = 120
    var animated: Bool = true

    var body: some View {
        VStack(spacing: logoSize * 0.2) {
            AppLogo(size: logoSize, animated: animated)

            Text("DAILY")
                .font(.system(size: logoSize * 0.25, weight: .black, design: .default))
                .tracking(logoSize * 0.05)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview

#Preview("App Logo") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()

        VStack(spacing: 40) {
            AppLogo(size: 200, animated: true)

            AppLogoWithWordmark(logoSize: 100)

            HStack(spacing: 20) {
                AppLogoCompact(size: 32)
                AppLogoCompact(size: 24, tintColor: .performancePurple)
                AppLogoCompact(size: 20, tintColor: .white)
            }
        }
    }
}

#Preview("Logo Sizes") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()

        HStack(spacing: 30) {
            VStack {
                AppLogo(size: 60)
                Text("60pt").font(.caption).foregroundColor(.gray)
            }
            VStack {
                AppLogo(size: 100)
                Text("100pt").font(.caption).foregroundColor(.gray)
            }
            VStack {
                AppLogo(size: 150)
                Text("150pt").font(.caption).foregroundColor(.gray)
            }
        }
    }
}
