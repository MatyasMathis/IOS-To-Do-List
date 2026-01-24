//
//  Typography.swift
//  dailytodolist
//
//  Purpose: Notebook-inspired typography system
//  Design: Handwritten fonts for headers, readable fonts for body text
//

import SwiftUI

/// Typography constants and font extensions for Notebook theme
enum Typography {
    // MARK: - Size Constants

    static let h1Size: CGFloat = 28
    static let h2Size: CGFloat = 22
    static let h3Size: CGFloat = 18
    static let bodySize: CGFloat = 17
    static let labelSize: CGFloat = 14
    static let captionSize: CGFloat = 11
    static let timeSize: CGFloat = 13
}

extension Font {
    // MARK: - Handwritten Fonts

    /// Main title - handwritten style (28pt)
    static let handwrittenTitle = Font.custom("Bradley Hand", size: Typography.h1Size)

    /// Sheet/section title - handwritten style (22pt)
    static let handwrittenHeader = Font.custom("Bradley Hand", size: Typography.h2Size)

    /// Smaller headers - handwritten style (18pt)
    static let handwrittenBody = Font.custom("Bradley Hand", size: Typography.h3Size)

    /// Labels and prompts - handwritten style (14pt)
    static let handwrittenLabel = Font.custom("Bradley Hand", size: Typography.labelSize)

    /// Script accent for special elements (16pt)
    static let scriptAccent = Font.custom("Marker Felt", size: 16)

    // MARK: - Readable Fonts (SF Pro fallbacks)

    /// Task title - readable (17pt)
    static let taskTitle = Font.system(size: Typography.bodySize, weight: .regular)

    /// Body text (16pt)
    static let bodyText = Font.system(size: 16, weight: .regular)

    /// Caption text (11pt)
    static let caption = Font.system(size: Typography.captionSize, weight: .regular)

    /// Time display - monospace (13pt)
    static let timeDisplay = Font.system(size: Typography.timeSize, weight: .regular, design: .monospaced)
}

// MARK: - Text Style Modifiers

extension View {
    /// Apply ink black text color (primary text)
    func inkText() -> some View {
        self.foregroundStyle(Color.inkBlack)
    }

    /// Apply pencil gray text color (secondary text)
    func pencilText() -> some View {
        self.foregroundStyle(Color.pencilGray)
    }

    /// Apply blue pen text color (links, actions)
    func bluePenText() -> some View {
        self.foregroundStyle(Color.bluePen)
    }

    /// Apply red pen text color (important, errors)
    func redPenText() -> some View {
        self.foregroundStyle(Color.redPen)
    }
}
