//
//  EditTaskSheet.swift
//  dailytodolist
//
//  Purpose: Sheet view for editing existing tasks
//  Features: Pre-filled form with current task values, save/cancel flow
//

import SwiftUI
import SwiftData

/// Sheet view for editing an existing task
///
/// Features:
/// - Pre-fills all fields with current task values
/// - Same UI as AddTaskSheet for consistency
/// - Save Changes button updates the task
/// - Delete option available
struct EditTaskSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties

    /// The task being edited
    let task: TodoTask

    /// Callback when task is deleted
    var onDelete: (() -> Void)?

    // MARK: - State

    @State private var title: String = ""
    @State private var category: String = ""
    @State private var recurrenceType: RecurrenceType = .none
    @State private var selectedWeekdays: [Int] = []
    @State private var selectedMonthDays: [Int] = []
    @State private var showDeleteConfirmation: Bool = false
    @FocusState private var isTitleFocused: Bool

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        // Validate recurrence-specific requirements
        switch recurrenceType {
        case .none, .daily:
            return hasTitle
        case .weekly:
            return hasTitle && !selectedWeekdays.isEmpty
        case .monthly:
            return hasTitle && !selectedMonthDays.isEmpty
        }
    }

    private var hasChanges: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentCategory = category.isEmpty ? nil : category

        return trimmedTitle != task.title ||
               currentCategory != task.category ||
               recurrenceType != task.recurrenceType ||
               selectedWeekdays != task.selectedWeekdays ||
               selectedMonthDays != task.selectedMonthDays
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

                        // Recurrence Selector
                        RecurrenceSelector(
                            recurrenceType: $recurrenceType,
                            selectedWeekdays: $selectedWeekdays,
                            selectedMonthDays: $selectedMonthDays
                        )

                        // Save Button
                        Button("Save Changes") {
                            saveTask()
                        }
                        .buttonStyle(.primary)
                        .disabled(!isFormValid || !hasChanges)
                        .padding(.top, Spacing.sm)

                        // Delete Button
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Task")
                            }
                            .font(.system(size: Typography.bodySize, weight: .medium))
                            .foregroundStyle(Color.strainRed)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                        }
                    }
                    .padding(Spacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Task")
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
                loadTaskData()
            }
            .confirmationDialog(
                "Delete Task",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteTask()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this task? This action cannot be undone.")
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

    /// Loads the current task data into the form fields
    private func loadTaskData() {
        title = task.title
        category = task.category ?? ""
        recurrenceType = task.recurrenceType
        selectedWeekdays = task.selectedWeekdays
        selectedMonthDays = task.selectedMonthDays
    }

    /// Saves the updated task
    private func saveTask() {
        let taskService = TaskService(modelContext: modelContext)

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let taskCategory: String? = category.isEmpty ? nil : category

        taskService.updateTask(
            task,
            title: trimmedTitle,
            category: taskCategory,
            recurrenceType: recurrenceType,
            selectedWeekdays: selectedWeekdays,
            selectedMonthDays: selectedMonthDays
        )

        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }

    /// Deletes the task
    private func deleteTask() {
        let taskService = TaskService(modelContext: modelContext)
        taskService.deleteTask(task)

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)

        onDelete?()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

    let task = TodoTask(
        title: "Morning Workout",
        category: "Health",
        recurrenceType: .weekly,
        selectedWeekdays: [2, 4, 6]
    )
    container.mainContext.insert(task)

    return EditTaskSheet(task: task)
        .modelContainer(container)
}
