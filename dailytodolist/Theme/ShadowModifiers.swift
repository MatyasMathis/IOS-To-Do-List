//
//  ShadowModifiers.swift
//  dailytodolist
//
//  Purpose: Shadow view modifiers for depth/elevation
//

import SwiftUI

extension View {
    /// Level 1 shadow for cards
    /// Subtle elevation for list items and cards
    func shadowLevel1() -> some View {
        self.shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
    }

    /// Level 2 shadow for FAB
    /// Colored shadow for floating action button
    func shadowLevel2() -> some View {
        self.shadow(color: Color.recoveryGreen.opacity(0.4), radius: 16, x: 0, y: 6)
    }

    /// Level 3 shadow for sheets
    /// Strong shadow for modal presentations
    func shadowLevel3() -> some View {
        self.shadow(color: Color.black.opacity(0.4), radius: 24, x: 0, y: 8)
    }
}

// MARK: - Card Style Modifier

struct CardStyle: ViewModifier {
    var backgroundColor: Color = .darkGray2
    var cornerRadius: CGFloat = CornerRadius.standard
    var hasShadow: Bool = true

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .if(hasShadow) { view in
                view.shadowLevel1()
            }
    }
}

struct StatsCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.xl)
            .background(
                LinearGradient(
                    colors: [Color.darkGray1, Color.darkGray2.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadowLevel1()
    }
}

extension View {
    func cardStyle(
        backgroundColor: Color = .darkGray2,
        cornerRadius: CGFloat = CornerRadius.standard,
        hasShadow: Bool = true
    ) -> some View {
        modifier(CardStyle(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            hasShadow: hasShadow
        ))
    }

    func statsCardStyle() -> some View {
        modifier(StatsCardStyle())
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
