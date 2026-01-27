//
//  AddTaskSheet.swift
//  dailytodolist
//
//  Purpose: Sheet view for creating new tasks
//  Key responsibilities:
//  - Provide form for entering task details
//  - Handle title validation (non-empty)
//  - Toggle between regular and recurring tasks
//  - Category selection
//

import SwiftUI
import SwiftData

/// Sheet view for adding a new task
///
/// Presents a form with fields for:
/// - Task title (required)
/// - Category (optional)
/// - Recurring toggle (daily repeat)
///
/// The sheet validates that the title is not empty before allowing
/// the user to save the task.
struct AddTaskSheet: View {

    // MARK: - Environment

    /// Used to dismiss the sheet after saving
    @Environment(\.dismiss) private var dismiss

    /// SwiftData model context for database operations
    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    /// The title entered by the user
    @State private var title: String = ""

    /// The category selected by the user
    @State private var category: String = ""

    /// Whether this task should repeat daily
    @State private var isRecurring: Bool = false

    /// Controls focus on the title field
    @FocusState private var isTitleFocused: Bool

    // MARK: - Constants

    /// Available categories for tasks
    /// These provide quick organization options for users
    private let categories = ["", "Work", "Personal", "Health", "Shopping", "Other"]

    // MARK: - Computed Properties

    /// Validates that the form can be submitted
    /// Currently only checks that title is not empty after trimming whitespace
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Task Details Section
                Section {
                    TextField("Task title", text: $title)
                        .focused($isTitleFocused)

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.isEmpty ? "None" : category)
                                .tag(category)
                        }
                    }
                } header: {
                    Text("Task Details")
                }

                // MARK: Recurring Section
                Section {
                    Toggle("Recurring Daily", isOn: $isRecurring)
                } header: {
                    Text("Schedule")
                } footer: {
                    Text(isRecurring
                         ? "This task will reappear every day, even after completion."
                         : "This task will disappear after you complete it.")
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // MARK: Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                // MARK: Save Button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveTask()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                // Auto-focus the title field when sheet appears
                isTitleFocused = true
            }
        }
    }

    // MARK: - Methods

    /// Saves the new task to the database and dismisses the sheet
    ///
    /// Creates a new TodoTask with the entered values using TaskService.
    /// The category is set to nil if empty string was selected.
    private func saveTask() {
        let taskService = TaskService(modelContext: modelContext)

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let taskCategory: String? = category.isEmpty ? nil : category

        taskService.createTask(
            title: trimmedTitle,
            category: taskCategory,
            isRecurring: isRecurring
        )

        dismiss()
    }
}

// MARK: - Preview

#Preview {
    AddTaskSheet()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
