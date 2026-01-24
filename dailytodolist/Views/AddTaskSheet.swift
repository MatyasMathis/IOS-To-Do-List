//
//  AddTaskSheet.swift
//  dailytodolist
//
//  Purpose: Sheet view for creating new tasks with Whoop-inspired design
//  Design: Dark theme with icon-based category selector and styled inputs
//

import SwiftUI
import SwiftData

/// Sheet view for adding a new task with Whoop-inspired styling
///
/// Features:
/// - Dark theme with gradient backgrounds
/// - Icon-based category grid selector
/// - Radio button frequency selector
/// - Animated primary button
struct AddTaskSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var title: String = ""
    @State private var category: String = ""
    @State private var isRecurring: Bool = false
    @FocusState private var isTitleFocused: Bool

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.darkGray1.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.section) {
                        // Task Name Input
                        taskNameSection

                        // Category Selector
                        CategorySelector(selectedCategory: $category)

                        // Frequency Selector
                        FrequencySelector(isRecurring: $isRecurring)

                        // Create Button
                        Button("Create Task") {
                            saveTask()
                        }
                        .buttonStyle(.primary)
                        .disabled(!isFormValid)
                        .padding(.top, Spacing.sm)
                    }
                    .padding(Spacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add New Task")
                        .font(.system(size: Typography.h3Size, weight: .bold))
                        .foregroundStyle(Color.pureWhite)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.mediumGray)
                            .frame(width: 30, height: 30)
                            .background(Color.darkGray2)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(Color.darkGray1, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                isTitleFocused = true
            }
        }
        .presentationBackground(Color.darkGray1)
    }

    // MARK: - Subviews

    /// Task name input section
    private var taskNameSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("TASK NAME")
                .font(.system(size: Typography.labelSize, weight: .semibold))
                .foregroundStyle(Color.mediumGray)

            TextField("", text: $title, prompt: Text("Enter task name...")
                .foregroundStyle(Color.mediumGray))
                .font(.system(size: Typography.h4Size, weight: .medium))
                .foregroundStyle(Color.pureWhite)
                .padding(Spacing.lg)
                .background(Color.darkGray2)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.standard)
                        .stroke(isTitleFocused ? Color.recoveryGreen : Color.clear, lineWidth: 2)
                )
                .focused($isTitleFocused)
        }
    }

    // MARK: - Methods

    private func saveTask() {
        let taskService = TaskService(modelContext: modelContext)

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let taskCategory: String? = category.isEmpty ? nil : category

        taskService.createTask(
            title: trimmedTitle,
            category: taskCategory,
            isRecurring: isRecurring
        )

        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }
}

// MARK: - Preview

#Preview {
    AddTaskSheet()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
