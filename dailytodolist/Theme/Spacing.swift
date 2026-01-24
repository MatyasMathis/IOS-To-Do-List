//
//  Spacing.swift
//  dailytodolist
//
//  Purpose: Spacing constants for consistent layout
//  Design: 4pt grid with organic variance options
//

import SwiftUI

/// Spacing constants based on 4pt grid
enum Spacing {
    /// Extra small spacing (4pt)
    static let xs: CGFloat = 4

    /// Small spacing (8pt)
    static let sm: CGFloat = 8

    /// Medium spacing (12pt)
    static let md: CGFloat = 12

    /// Large spacing (16pt)
    static let lg: CGFloat = 16

    /// Extra large spacing (20pt)
    static let xl: CGFloat = 20

    /// Extra extra large spacing (24pt)
    static let xxl: CGFloat = 24

    /// Extra extra extra large spacing (32pt)
    static let xxxl: CGFloat = 32

    // MARK: - Component-Specific Spacing

    /// Margin line distance from left edge
    static let marginLineOffset: CGFloat = 40

    /// Binding holes size
    static let bindingHoleSize: CGFloat = 8

    /// Binding holes spacing
    static let bindingHoleSpacing: CGFloat = 12

    /// Task row vertical padding
    static let taskRowPadding: CGFloat = 12

    /// Card padding
    static let cardPadding: CGFloat = 16

    /// Badge horizontal padding
    static let badgeHorizontalPadding: CGFloat = 8

    /// Badge vertical padding
    static let badgeVerticalPadding: CGFloat = 4
}

// MARK: - Corner Radius Constants

enum CornerRadius {
    /// Cards and buttons (8pt - softer, more organic)
    static let card: CGFloat = 8

    /// Sticky notes (2pt - slight rounding)
    static let stickyNote: CGFloat = 2

    /// Washi tape (4pt)
    static let washiTape: CGFloat = 4

    /// Notebook pages (0pt - sharp corners)
    static let page: CGFloat = 0

    /// Capsule badges
    static let capsule: CGFloat = 100
}
