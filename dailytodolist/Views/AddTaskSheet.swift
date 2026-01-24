//
//  AddTaskSheet.swift
//  dailytodolist
//
//  Purpose: Sheet for creating new tasks with notebook styling
//  Design: Torn paper look, lined input, washi tape categories, sticky note button
//

import SwiftUI
import SwiftData

/// Sheet view for adding a new task with notebook styling
struct AddTaskSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var title: String = ""
    @State private var category: String = ""
    @State private var isRecurring: Bool = false
    @FocusState private var isTitleFocused: Bool

    // MARK: - Constants

    private let categories = ["", "Work", "Personal", "Health", "Shopping", "Other"]

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Paper background
                Color.paperCream.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        // Prompt
                        Text("What's on your mind?")
                            .font(.handwrittenLabel)
                            .foregroundStyle(Color.pencilGray)
                            .padding(.top, Spacing.lg)

                        // Lined text input
                        VStack(spacing: 0) {
                            TextField("", text: $title, axis: .vertical)
                                .font(.taskTitle)
                                .foregroundStyle(Color.inkBlack)
                                .focused($isTitleFocused)
                                .lineLimit(3...5)
                                .padding(.vertical, Spacing.sm)

                            // Ruled lines
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.ruledLines)
                                    .frame(height: 1)
                                    .padding(.vertical, Spacing.md)
                            }
                        }

                        // Category selector
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Tag it:")
                                .font(.handwrittenLabel)
                                .foregroundStyle(Color.pencilGray)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Spacing.sm) {
                                    ForEach(categories, id: \.self) { cat in
                                        WashiTapeCategoryButton(
                                            category: cat,
                                            isSelected: category == cat
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                category = cat
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Frequency selector
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("How often?")
                                .font(.handwrittenLabel)
                                .foregroundStyle(Color.pencilGray)

                            HandDrawnRadio(
                                isSelected: !isRecurring,
                                label: "One-time task"
                            ) {
                                isRecurring = false
                            }

                            HandDrawnRadio(
                                isSelected: isRecurring,
                                label: "Every day (recurring)"
                            ) {
                                isRecurring = true
                            }
                        }

                        Spacer(minLength: Spacing.xl)

                        // Add button (sticky note style)
                        StickyNoteButton(title: "Add to Today's List") {
                            saveTask()
                        }
                        .opacity(isFormValid ? 1.0 : 0.5)
                        .disabled(!isFormValid)
                    }
                    .padding(.horizontal, Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("New Task")
                            .font(.handwrittenHeader)
                            .foregroundStyle(Color.inkBlack)

                        // Double underline
                        VStack(spacing: 2) {
                            Rectangle()
                                .fill(Color.inkBlack)
                                .frame(width: 80, height: 1)
                            Rectangle()
                                .fill(Color.inkBlack)
                                .frame(width: 80, height: 1)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.inkBlack)
                            .padding(Spacing.sm)
                    }
                }
            }
            .toolbarBackground(Color.paperCream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                isTitleFocused = true
            }
        }
    }

    // MARK: - Methods

    private func saveTask() {
        guard isFormValid else { return }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

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
