//
//  OnboardingService.swift
//  Reps
//
//  Purpose: Manages first-launch onboarding with starter tasks
//  Design: Teaches by doing, not by explaining
//

import Foundation
import SwiftData

/// Manages first-launch experience with contextual onboarding
@MainActor
class OnboardingService {

    // MARK: - UserDefaults Keys

    private static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private static let hasSeenFirstStreakKey = "hasSeenFirstStreak"

    // MARK: - Properties

    /// Whether the user has already been onboarded
    static var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey) }
    }

    /// Whether the user has seen the first streak celebration (2-day)
    static var hasSeenFirstStreak: Bool {
        get { UserDefaults.standard.bool(forKey: hasSeenFirstStreakKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasSeenFirstStreakKey) }
    }

    // MARK: - Starter Tasks

    /// Creates starter tasks on first launch that teach the user by doing
    static func createStarterTasksIfNeeded(modelContext: ModelContext) {
        guard !hasCompletedOnboarding else { return }

        let taskService = TaskService(modelContext: modelContext)

        // Task 1: A simple one-time task — teaches tapping to complete
        taskService.createTask(
            title: "Tap here to complete your first task",
            category: "Personal",
            recurrenceType: .none
        )

        // Task 2: A daily recurring task — shows recurrence concept
        taskService.createTask(
            title: "This one comes back every day",
            category: "Health",
            recurrenceType: .daily
        )

        // Task 3: Teaches editing — a task they'll want to customize
        taskService.createTask(
            title: "Long press me to edit or delete",
            category: "Work",
            recurrenceType: .none
        )

        hasCompletedOnboarding = true
    }
}
