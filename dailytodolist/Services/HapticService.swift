//
//  HapticService.swift
//  Reps
//
//  Purpose: Centralized haptic feedback helper that respects user preferences
//  Design: Static methods matching UIKit haptic patterns, gated by UserDefaults
//

import SwiftUI

/// Centralized haptic feedback service that respects user preferences
///
/// Usage: Replace direct UIImpactFeedbackGenerator/UINotificationFeedbackGenerator
/// calls with HapticService methods for preference-aware haptics.
enum HapticService {

    /// UserDefaults key for haptic preference
    static let preferenceKey = "hapticFeedbackEnabled"

    /// Whether haptics are enabled (reads directly from UserDefaults)
    private static var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: preferenceKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: preferenceKey)
    }

    // MARK: - Impact Feedback

    /// Fires impact haptic if enabled
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func lightImpact() {
        impact(style: .light)
    }

    static func mediumImpact() {
        impact(style: .medium)
    }

    static func softImpact() {
        impact(style: .soft)
    }

    // MARK: - Notification Feedback

    /// Fires notification haptic if enabled
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func success() {
        notification(type: .success)
    }

    static func warning() {
        notification(type: .warning)
    }

    // MARK: - Selection Feedback

    /// Fires selection changed haptic if enabled
    static func selectionChanged() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
