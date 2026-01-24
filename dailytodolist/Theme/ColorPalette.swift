//
//  ColorPalette.swift
//  dailytodolist
//
//  Purpose: Whoop-inspired color palette for the app
//  Design: Athletic performance tracker aesthetic with bold, clean colors
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors

    /// Deep, rich black for backgrounds
    static let brandBlack = Color(hex: "0A0A0A")

    /// High contrast white for text
    static let pureWhite = Color(hex: "FFFFFF")

    /// Success, completion, positive actions
    static let recoveryGreen = Color(hex: "2DD881")

    /// Alerts, delete actions
    static let strainRed = Color(hex: "FF4444")

    /// Recurring tasks, premium feel
    static let performancePurple = Color(hex: "7B61FF")

    // MARK: - Supporting Colors

    /// Card backgrounds
    static let darkGray1 = Color(hex: "1A1A1A")

    /// Elevated surfaces
    static let darkGray2 = Color(hex: "2A2A2A")

    /// Secondary text
    static let mediumGray = Color(hex: "808080")

    /// Borders, dividers
    static let lightGray = Color(hex: "E0E0E0")

    // MARK: - Category Colors

    /// Work category - Electric Blue
    static let workBlue = Color(hex: "4A90E2")

    /// Personal category - Vibrant Orange
    static let personalOrange = Color(hex: "F5A623")

    /// Health category - Recovery Green (matches completion)
    static let healthGreen = Color(hex: "2DD881")

    /// Shopping category - Magenta
    static let shoppingMagenta = Color(hex: "BD10E0")

    /// Other category - Neutral Gray
    static let otherGray = Color(hex: "808080")

    // MARK: - Helper Methods

    /// Returns the appropriate color for a given category
    static func categoryColor(for category: String?) -> Color {
        guard let category = category else { return .otherGray }
        switch category.lowercased() {
        case "work": return .workBlue
        case "personal": return .personalOrange
        case "health": return .healthGreen
        case "shopping": return .shoppingMagenta
        default: return .otherGray
        }
    }

    /// Returns the emoji icon for a given category
    static func categoryIcon(for category: String?) -> String {
        guard let category = category else { return "circle.fill" }
        switch category.lowercased() {
        case "work": return "briefcase.fill"
        case "personal": return "house.fill"
        case "health": return "heart.fill"
        case "shopping": return "cart.fill"
        default: return "circle.fill"
        }
    }
}

// MARK: - Hex Color Initializer

extension Color {
    /// Creates a Color from a hex string
    /// - Parameter hex: A hex color string (with or without #)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
