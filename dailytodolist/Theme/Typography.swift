//
//  Typography.swift
//  dailytodolist
//
//  Purpose: Typography system for consistent text styling
//  Design: SF Pro Display for headings, SF Pro Text for body
//

import SwiftUI

/// Typography constants and text styles for the app
enum Typography {

    // MARK: - Font Sizes

    /// H1 - Screen titles (34pt)
    static let h1Size: CGFloat = 34

    /// H2 - Stats, numbers (28pt)
    static let h2Size: CGFloat = 28

    /// H3 - Sheet headers (20pt)
    static let h3Size: CGFloat = 20

    /// H4 - Task titles (17pt)
    static let h4Size: CGFloat = 17

    /// Body text (16pt)
    static let bodySize: CGFloat = 16

    /// Labels, uppercase (12pt)
    static let labelSize: CGFloat = 12

    /// Captions, badges (11pt)
    static let captionSize: CGFloat = 11

    /// Time display (14pt)
    static let timeSize: CGFloat = 14
}

// MARK: - Text Style ViewModifier

struct TextStyle: ViewModifier {
    enum Style {
        case h1, h2, h3, h4, body, label, caption, time
    }

    let style: Style
    let color: Color

    func body(content: Content) -> some View {
        switch style {
        case .h1:
            content
                .font(.system(size: Typography.h1Size, weight: .bold, design: .default))
                .foregroundStyle(color)
        case .h2:
            content
                .font(.system(size: Typography.h2Size, weight: .bold, design: .default))
                .foregroundStyle(color)
        case .h3:
            content
                .font(.system(size: Typography.h3Size, weight: .bold, design: .default))
                .foregroundStyle(color)
        case .h4:
            content
                .font(.system(size: Typography.h4Size, weight: .medium, design: .default))
                .foregroundStyle(color)
        case .body:
            content
                .font(.system(size: Typography.bodySize, weight: .regular, design: .default))
                .foregroundStyle(color)
        case .label:
            content
                .font(.system(size: Typography.labelSize, weight: .semibold, design: .default))
                .foregroundStyle(color)
                .textCase(.uppercase)
        case .caption:
            content
                .font(.system(size: Typography.captionSize, weight: .medium, design: .default))
                .foregroundStyle(color)
        case .time:
            content
                .font(.system(size: Typography.timeSize, weight: .medium, design: .monospaced))
                .foregroundStyle(color)
        }
    }
}

extension View {
    func textStyle(_ style: TextStyle.Style, color: Color = .pureWhite) -> some View {
        modifier(TextStyle(style: style, color: color))
    }
}
