//
//  TaskSearchDropdown.swift
//  dailytodolist
//
//  Purpose: Searchable dropdown for selecting a task to view statistics
//

import SwiftUI
import SwiftData

/// Searchable dropdown for selecting a task
struct TaskSearchDropdown: View {

    // MARK: - Properties

    let tasks: [TodoTask]
    @Binding var selectedTask: TodoTask?
    @Binding var searchText: String
    @Binding var isExpanded: Bool

    // MARK: - Computed Properties

    private var filteredTasks: [TodoTask] {
        if searchText.isEmpty {
            return tasks.sorted { task1, task2 in
                // Sort by most recent completion first
                let date1 = task1.completions?.max(by: { $0.completedAt < $1.completedAt })?.completedAt ?? task1.createdAt
                let date2 = task2.completions?.max(by: { $0.completedAt < $1.completedAt })?.completedAt ?? task2.createdAt
                return date1 > date2
            }
        }
        return tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Body

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Search field / Selected task display
            if isExpanded {
                // Expanded state: show real TextField (not inside a Button)
                HStack(spacing: Spacing.md) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.mediumGray)

                    TextField("Search tasks...", text: $searchText)
                        .font(.system(size: Typography.bodySize, weight: .regular))
                        .foregroundStyle(Color.pureWhite)
                        .tint(Color.recoveryGreen)
                        .focused($isSearchFocused)

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded = false
                            searchText = ""
                            isSearchFocused = false
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.mediumGray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(Color.darkGray2)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
                .onAppear {
                    isSearchFocused = true
                }
            } else {
                // Collapsed state: tappable button to expand
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                } label: {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.mediumGray)

                        if let task = selectedTask {
                            Text(task.title)
                                .font(.system(size: Typography.bodySize, weight: .medium))
                                .foregroundStyle(Color.pureWhite)
                                .lineLimit(1)
                        } else {
                            Text("Select a task...")
                                .font(.system(size: Typography.bodySize, weight: .regular))
                                .foregroundStyle(Color.mediumGray)
                        }

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.mediumGray)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .background(Color.darkGray2)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
                }
                .buttonStyle(.plain)
            }

            // Dropdown list
            if isExpanded {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredTasks) { task in
                            TaskDropdownRow(task: task, isSelected: selectedTask?.id == task.id) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedTask = task
                                    isExpanded = false
                                    searchText = ""
                                }
                            }
                        }

                        if filteredTasks.isEmpty {
                            Text("No tasks found")
                                .font(.system(size: Typography.bodySize, weight: .regular))
                                .foregroundStyle(Color.mediumGray)
                                .padding(Spacing.lg)
                        }
                    }
                }
                .frame(maxHeight: 250)
                .background(Color.darkGray1)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
                .padding(.top, Spacing.xs)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Task Dropdown Row

struct TaskDropdownRow: View {
    let task: TodoTask
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.md) {
                // Task title
                Text(task.title)
                    .font(.system(size: Typography.bodySize, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.recoveryGreen : Color.pureWhite)
                    .lineLimit(1)

                Spacer()

                // Badges
                HStack(spacing: Spacing.sm) {
                    if task.recurrenceType != .none {
                        RecurringBadge(task: task)
                    } else if let category = task.category {
                        CategoryBadge(category: category)
                    }

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.recoveryGreen)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(isSelected ? Color.darkGray2 : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Task Search Dropdown") {
    struct PreviewWrapper: View {
        @State private var selectedTask: TodoTask?
        @State private var searchText = ""
        @State private var isExpanded = false

        var body: some View {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: TodoTask.self, TaskCompletion.self, CustomCategory.self, configurations: config)

            let task1 = TodoTask(title: "Morning Exercise", category: "Health", recurrenceType: .daily)
            let task2 = TodoTask(title: "Buy groceries", category: "Shopping")
            let task3 = TodoTask(title: "Team standup", category: "Work", recurrenceType: .weekly, selectedWeekdays: [2, 3, 4, 5, 6])
            let task4 = TodoTask(title: "Read for 30 minutes", category: "Personal")

            container.mainContext.insert(task1)
            container.mainContext.insert(task2)
            container.mainContext.insert(task3)
            container.mainContext.insert(task4)

            return ZStack {
                Color.brandBlack.ignoresSafeArea()
                VStack {
                    TaskSearchDropdown(
                        tasks: [task1, task2, task3, task4],
                        selectedTask: $selectedTask,
                        searchText: $searchText,
                        isExpanded: $isExpanded
                    )
                    .padding(Spacing.lg)

                    Spacer()
                }
            }
        }
    }

    return PreviewWrapper()
}
