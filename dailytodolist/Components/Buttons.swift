//
//  Buttons.swift
//  dailytodolist
//
//  Purpose: Reusable button styles with Whoop styling
//

import SwiftUI

// MARK: - Primary Button Style

/// Primary CTA button style - Recovery Green with white text
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: Typography.h4Size, weight: .semibold))
            .foregroundStyle(Color.pureWhite)
            .frame(maxWidth: .infinity)
            .frame(height: ComponentSize.buttonHeight)
            .background(isEnabled ? Color.recoveryGreen : Color.mediumGray)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
            .shadow(
                color: isEnabled ? Color.recoveryGreen.opacity(0.4) : .clear,
                radius: 12,
                x: 0,
                y: 4
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

/// Secondary button style - Dark gray with white text
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: Typography.h4Size, weight: .semibold))
            .foregroundStyle(Color.pureWhite)
            .frame(maxWidth: .infinity)
            .frame(height: ComponentSize.buttonHeight)
            .background(Color.darkGray2)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Destructive Button Style

/// Destructive button style - Strain Red with white text
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: Typography.h4Size, weight: .semibold))
            .foregroundStyle(Color.pureWhite)
            .frame(maxWidth: .infinity)
            .frame(height: ComponentSize.buttonHeight)
            .background(Color.strainRed)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Ghost Button Style

/// Ghost button style - Transparent with colored text
struct GhostButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color = .recoveryGreen) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: Typography.h4Size, weight: .medium))
            .foregroundStyle(configuration.isPressed ? color.opacity(0.7) : color)
            .frame(height: 44)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Floating Action Button

/// Floating action button for primary actions
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    @State private var isPressed = false

    init(icon: String = "plus", action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.recoveryGreen, Color.recoveryGreen.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: ComponentSize.fab, height: ComponentSize.fab)
                    .shadowLevel2()

                Image(systemName: icon)
                    .font(.system(size: ComponentSize.fabIcon, weight: .bold))
                    .foregroundStyle(Color.pureWhite)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

// MARK: - Checkbox Button

/// Custom checkbox for task completion
struct CheckboxButton: View {
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .stroke(isChecked ? Color.recoveryGreen : Color.pureWhite, lineWidth: 2)
                    .frame(width: ComponentSize.checkbox, height: ComponentSize.checkbox)

                if isChecked {
                    Circle()
                        .fill(Color.recoveryGreen)
                        .frame(width: ComponentSize.checkbox, height: ComponentSize.checkbox)

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isChecked)
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == DestructiveButtonStyle {
    static var destructive: DestructiveButtonStyle { DestructiveButtonStyle() }
}

// MARK: - Preview

#Preview("Buttons") {
    ZStack {
        Color.brandBlack.ignoresSafeArea()
        VStack(spacing: Spacing.lg) {
            Button("Create Task") {}
                .buttonStyle(.primary)

            Button("Cancel") {}
                .buttonStyle(.secondary)

            Button("Delete") {}
                .buttonStyle(.destructive)

            Button("Learn More") {}
                .buttonStyle(GhostButtonStyle())

            HStack(spacing: Spacing.xxl) {
                CheckboxButton(isChecked: false) {}
                CheckboxButton(isChecked: true) {}
            }

            FloatingActionButton {}
        }
        .padding(Spacing.xl)
    }
}
