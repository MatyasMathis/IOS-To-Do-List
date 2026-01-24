//
//  ColorPalette.swift
//  dailytodolist
//
//  Purpose: Notebook-inspired color palette
//  Design: Warm paper textures, ink colors, and organic tones
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors

    /// Warm off-white background, like aged paper
    static let paperCream = Color(red: 255/255, green: 248/255, blue: 231/255)

    /// Deep brown-black for text, like fountain pen ink
    static let inkBlack = Color(red: 44/255, green: 36/255, blue: 22/255)

    /// Accents, borders, notebook binding
    static let leatherBrown = Color(red: 139/255, green: 111/255, blue: 71/255)

    /// Highlights, important tasks, errors
    static let redPen = Color(red: 211/255, green: 47/255, blue: 47/255)

    /// Links, recurring tasks, secondary actions
    static let bluePen = Color(red: 25/255, green: 118/255, blue: 210/255)

    // MARK: - Supporting Colors

    /// Subtle notebook lines
    static let ruledLines = Color(red: 232/255, green: 220/255, blue: 200/255)

    /// Faint red margin line
    static let marginRed = Color(red: 255/255, green: 201/255, blue: 201/255)

    /// Text highlighting, like marker
    static let highlightYellow = Color(red: 255/255, green: 245/255, blue: 157/255)

    /// Completion, success
    static let greenCheckmark = Color(red: 67/255, green: 160/255, blue: 71/255)

    /// Secondary text, notes
    static let pencilGray = Color(red: 117/255, green: 117/255, blue: 117/255)

    // MARK: - Category Colors (Muted, Pen-like)

    /// Work category - Blue ink
    static let workBlue = Color(red: 25/255, green: 118/255, blue: 210/255)

    /// Personal category - Orange highlighter
    static let personalOrange = Color(red: 245/255, green: 124/255, blue: 0/255)

    /// Health category - Green pen
    static let healthGreen = Color(red: 67/255, green: 160/255, blue: 71/255)

    /// Shopping category - Purple ink
    static let shoppingPurple = Color(red: 142/255, green: 36/255, blue: 170/255)

    // MARK: - Dark Mode Colors (Night Notebook)

    /// Dark brown background for dark mode
    static let nightBrown = Color(red: 62/255, green: 39/255, blue: 35/255)

    /// Darker cream for dark mode text
    static let nightCream = Color(red: 240/255, green: 230/255, blue: 210/255)

    // MARK: - Helper Methods

    /// Returns the color for a given category name
    static func forCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "work": return .workBlue
        case "personal": return .personalOrange
        case "health": return .healthGreen
        case "shopping": return .shoppingPurple
        default: return .pencilGray
        }
    }

    /// Returns emoji icon for a given category
    static func emojiForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "work": return "💼"
        case "personal": return "🏠"
        case "health": return "💚"
        case "shopping": return "🛒"
        default: return "⚪"
        }
    }
}
