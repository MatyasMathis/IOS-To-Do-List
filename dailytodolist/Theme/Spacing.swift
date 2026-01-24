//
//  Spacing.swift
//  dailytodolist
//
//  Purpose: Spacing constants based on 4pt grid system
//

import SwiftUI

/// Spacing constants for consistent layout
enum Spacing {
    /// 4pt - Extra small
    static let xs: CGFloat = 4

    /// 8pt - Small
    static let sm: CGFloat = 8

    /// 12pt - Medium
    static let md: CGFloat = 12

    /// 16pt - Large
    static let lg: CGFloat = 16

    /// 20pt - Extra large
    static let xl: CGFloat = 20

    /// 24pt - Extra extra large
    static let xxl: CGFloat = 24

    /// 28pt - Section spacing
    static let section: CGFloat = 28
}

/// Corner radius constants
enum CornerRadius {
    /// 12pt - Cards, buttons, inputs
    static let standard: CGFloat = 12

    /// 16pt - Stats cards
    static let large: CGFloat = 16

    /// 20pt - Sheets (top only)
    static let sheet: CGFloat = 20
}

/// Component sizes
enum ComponentSize {
    /// Checkbox size
    static let checkbox: CGFloat = 24

    /// FAB (Floating Action Button) size
    static let fab: CGFloat = 56

    /// FAB icon size
    static let fabIcon: CGFloat = 24

    /// Primary button height
    static let buttonHeight: CGFloat = 54

    /// Tab bar height
    static let tabBarHeight: CGFloat = 60

    /// Navigation bar height
    static let navBarHeight: CGFloat = 60

    /// Category button size
    static let categoryButton: CGFloat = 60

    /// Category button height (including label)
    static let categoryButtonHeight: CGFloat = 70
}
