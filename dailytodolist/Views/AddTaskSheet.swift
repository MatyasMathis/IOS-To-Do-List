//
//  AddTaskSheet.swift
//  dailytodolist
//
//  Purpose: Sheet view for creating and editing tasks with Whoop-inspired design
//  Design: Dark theme with icon-based category selector and styled inputs
//

import SwiftUI
import SwiftData

/// Sheet view for adding or editing a task with Whoop-inspired styling
///
/// Features:
/// - Dark theme with gradient backgrounds
/// - Icon-based category grid selector
/// - Radio button frequency selector
/// - Animated primary button
/// - Edit mode with delete option
struct AddTaskSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties

    /// Task to edit (nil for add mode)
    var taskToEdit: TodoTask?

    /// Callback when task is deleted (edit mode only)
    var onDelete: (() -> Void)?

    // MARK: - State

    @State private var title: String = ""
    @State private var category: String = ""
    @State private var isRecurring: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @FocusState private var isTitleFocused: Bool

    // MARK: - Computed Properties

    private var isEditMode: Bool {
        taskToEdit != nil
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var navigationTitle: String {
        isEditMode ? "Edit Task" : "Add New Task"
    }

    private var buttonTitle: String {
        isEditMode ? "Save Changes" : "Create Task"
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

                        // Save/Create Button
                        Button(buttonTitle) {
                            saveTask()
                        }
                        .buttonStyle(.primary)
                        .disabled(!isFormValid)
                        .padding(.top, Spacing.sm)

                        // Delete Button (edit mode only)
                        if isEditMode {
                            Button("Delete Task") {
                                showDeleteConfirmation = true
                            }
                            .buttonStyle(.destructive)
                            .padding(.top, Spacing.xs)
                        }
                    }
                    .padding(Spacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(navigationTitle)
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
                isTitleFocused = true
            }
            .alert("Delete Task", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteTask()
                }
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

    private func loadTaskData() {
        guard let task = taskToEdit else { return }
        title = task.title
        category = task.category ?? ""
        isRecurring = task.isRecurring
    }

    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let taskCategory: String? = category.isEmpty ? nil : category

        if let task = taskToEdit {
            // Edit mode - update existing task
            task.title = trimmedTitle
            task.category = taskCategory
            task.isRecurring = isRecurring

            try? modelContext.save()
        } else {
            // Add mode - create new task
            let taskService = TaskService(modelContext: modelContext)
            taskService.createTask(
                title: trimmedTitle,
                category: taskCategory,
                isRecurring: isRecurring
            )
        }

        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }

    private func deleteTask() {
        guard let task = taskToEdit else { return }

        // Soft delete - set isActive to false
        task.isActive = false
        try? modelContext.save()

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)

        onDelete?()
        dismiss()
    }
}

// MARK: - Preview

#Preview("Add Mode") {
    AddTaskSheet()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}

#Preview("Edit Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, configurations: config)

    let task = TodoTask(title: "Morning Exercise", category: "Health", isRecurring: true)
    container.mainContext.insert(task)

    return AddTaskSheet(taskToEdit: task)
        .modelContainer(container)
}
