//
//  CelebrationOverlay.swift
//  Reps
//
//  Purpose: Encouraging messages displayed when tasks are completed
//  Design: Creates positive reinforcement with varied, motivating messages
//

import SwiftUI

/// Collection of encouraging messages shown after task completion
enum EncouragingMessages {

    /// Variety of motivating messages to keep users engaged
    static let messages: [String] = [
        // Achievement focused
        "Crushed it! 💪",
        "You're on fire!",
        "Unstoppable!",
        "Beast mode!",
        "Champion move!",

        // Progress focused
        "One step closer!",
        "Progress made!",
        "Momentum building!",
        "Stacking wins.",
        "Another rep done.",

        // Encouragement
        "You've got this!",
        "Way to go!",
        "Nailed it!",
        "Boom! Done!",
        "That's the spirit!",

        // Celebration
        "Victory!",
        "Yes! Another one!",
        "Look at you go!",
        "Winning!",
        "Smooth!",

        // Motivational
        "Discipline pays off!",
        "Future you says thanks.",
        "Building greatness!",
        "Stay relentless!",
        "Consistency is key!",

        // Identity-focused (powerful)
        "This is who you are now.",
        "Consistency looks good on you.",
        "Yesterday's you would be proud.",

        // Fun & Playful
        "Rep! ✓",
        "Done and dusted!",
        "Mic drop!",
        "Easy money!",
        "Like a boss!",

        // Simple satisfaction
        "Done.",
        "Handled.",
        "Next.",

        // Energy boosters
        "Let's gooo!",
        "Keep that energy!",
        "Fired up!",
        "No stopping you!",
        "Absolute legend!"
    ]

    /// Streak milestone messages (for special celebrations)
    static let streakMilestones: [Int: String] = [
        2: "2 days in a row. That's how it starts.",
        3: "3 days. You're building something.",
        5: "5 days. This is becoming a habit.",
        7: "One week locked in. 🔥",
        14: "Two weeks. This isn't luck.",
        21: "Three weeks. Habits forming.",
        30: "30 days. You're different now.",
        50: "50 days. Unstoppable.",
        75: "75 days. Elite consistency.",
        100: "100 days. Legendary. 👑"
    ]

    /// Returns a random encouraging message
    static func random() -> String {
        messages.randomElement() ?? "Great job!"
    }

    /// Returns a milestone message if applicable
    static func milestoneMessage(for streak: Int) -> String? {
        streakMilestones[streak]
    }
}

/// Animated overlay that displays an encouraging message after task completion
struct CelebrationOverlay: View {

    // MARK: - Properties

    /// The message to display
    let message: String

    /// Binding to control visibility
    @Binding var isShowing: Bool

    // MARK: - State

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 20

    // MARK: - Body

    var body: some View {
        if isShowing {
            VStack {
                Spacer()

                Text(message)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.pureWhite)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.recoveryGreen)
                            .shadow(color: Color.recoveryGreen.opacity(0.4), radius: 12, x: 0, y: 4)
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .offset(y: yOffset)

                Spacer()
                    .frame(height: 180)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
            .onAppear {
                showAnimation()
            }
        }
    }

    // MARK: - Animation

    private func showAnimation() {
        // Satisfying haptic pattern
        HapticService.mediumImpact()

        // Entrance animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
            yOffset = 0
        }

        // Second subtle haptic at peak
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            HapticService.softImpact()
        }

        // Auto-dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
                yOffset = -10
                scale = 0.9
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isShowing = false
                // Reset for next time
                scale = 0.5
                yOffset = 20
            }
        }
    }
}

// MARK: - View Modifier

/// View modifier to easily add celebration overlay to any view
struct CelebrationModifier: ViewModifier {
    @Binding var isShowing: Bool
    @Binding var message: String

    func body(content: Content) -> some View {
        ZStack {
            content
            CelebrationOverlay(message: message, isShowing: $isShowing)
        }
    }
}

extension View {
    /// Adds a celebration overlay that shows encouraging messages
    func celebrationOverlay(isShowing: Binding<Bool>, message: Binding<String>) -> some View {
        modifier(CelebrationModifier(isShowing: isShowing, message: message))
    }
}

// MARK: - Preview

#Preview("Celebration Overlay") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()

        CelebrationOverlay(
            message: "Crushed it! 💪",
            isShowing: .constant(true)
        )
    }
}
