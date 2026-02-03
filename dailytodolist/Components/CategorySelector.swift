//
//  CategorySelector.swift
//  dailytodolist
//
//  Purpose: Category selection grid component for AddTaskSheet
//

import SwiftUI

// MARK: - Category Selector

/// Grid-based category selector with icons
struct CategorySelector: View {
    @Binding var selectedCategory: String

    private let categories: [(id: String, icon: String, label: String, color: Color)] = [
        ("Work", "briefcase.fill", "Work", .workBlue),
        ("Personal", "house.fill", "Personal", .personalOrange),
        ("Health", "heart.fill", "Health", .healthGreen),
        ("Shopping", "cart.fill", "Shopping", .shoppingMagenta),
        ("Other", "circle.fill", "Other", .otherGray)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("CATEGORY")
                .font(.system(size: Typography.labelSize, weight: .semibold))
                .foregroundStyle(Color.mediumGray)

            HStack(spacing: Spacing.sm) {
                ForEach(categories, id: \.id) { category in
                    CategoryButton(
                        icon: category.icon,
                        label: category.label,
                        color: category.color,
                        isSelected: selectedCategory == category.id
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if selectedCategory == category.id {
                                selectedCategory = ""
                            } else {
                                selectedCategory = category.id
                            }
                        }
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
            }
        }
    }
}

// MARK: - Category Button

/// Individual category selection button
struct CategoryButton: View {
    let icon: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.standard)
                        .fill(isSelected ? color.opacity(0.3) : Color.darkGray2)
                        .frame(width: ComponentSize.categoryButton, height: ComponentSize.categoryButton)

                    RoundedRectangle(cornerRadius: CornerRadius.standard)
                        .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                        .frame(width: ComponentSize.categoryButton, height: ComponentSize.categoryButton)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(isSelected ? color : Color.mediumGray)
                }

                Text(label)
                    .font(.system(size: Typography.captionSize, weight: .medium))
                    .foregroundStyle(isSelected ? color : Color.mediumGray)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Frequency Selector

/// Radio button selector for task frequency
struct FrequencySelector: View {
    @Binding var isRecurring: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("FREQUENCY")
                .font(.system(size: Typography.labelSize, weight: .semibold))
                .foregroundStyle(Color.mediumGray)

            VStack(spacing: 0) {
                FrequencyOption(
                    title: "One Time",
                    subtitle: "Task disappears after completion",
                    isSelected: !isRecurring
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isRecurring = false
                    }
                }

                Divider()
                    .background(Color.darkGray1)

                FrequencyOption(
                    title: "Daily Recurring",
                    subtitle: "Task reappears every day",
                    icon: "repeat",
                    isSelected: isRecurring
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isRecurring = true
                    }
                }
            }
            .background(Color.darkGray2)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
        }
    }
}

// MARK: - Frequency Option

/// Individual frequency selection option (radio style)
struct FrequencyOption: View {
    let title: String
    let subtitle: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }) {
            HStack(spacing: Spacing.md) {
                // Radio button
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.recoveryGreen : Color.mediumGray, lineWidth: 2)
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(Color.recoveryGreen)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Spacing.xs) {
                        Text(title)
                            .font(.system(size: Typography.bodySize, weight: .medium))
                            .foregroundStyle(Color.pureWhite)

                        if let icon = icon {
                            Image(systemName: icon)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.performancePurple)
                        }
                    }

                    Text(subtitle)
                        .font(.system(size: Typography.captionSize, weight: .regular))
                        .foregroundStyle(Color.mediumGray)
                }

                Spacer()
            }
            .padding(Spacing.lg)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Selectors") {
    struct PreviewWrapper: View {
        @State private var category = "Work"
        @State private var isRecurring = false

        var body: some View {
            ZStack {
                Color.brandBlack.ignoresSafeArea()
                VStack(spacing: Spacing.section) {
                    CategorySelector(selectedCategory: $category)
                    FrequencySelector(isRecurring: $isRecurring)
                }
                .padding(Spacing.xl)
            }
        }
    }

    return PreviewWrapper()
}
