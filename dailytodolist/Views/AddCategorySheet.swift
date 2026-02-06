//
//  AddCategorySheet.swift
//  dailytodolist
//
//  Purpose: Sheet view for creating or editing custom categories
//  Features: Name input, SF Symbol icon picker, color picker, live preview
//

import SwiftUI
import SwiftData

/// Sheet for creating or editing a custom category
struct AddCategorySheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Query

    @Query(sort: \CustomCategory.sortOrder)
    private var existingCustomCategories: [CustomCategory]

    // MARK: - Properties

    /// Category being edited (nil = create mode)
    var editingCategory: CustomCategory?

    // MARK: - State

    @State private var name: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColorHex: String = "FF6B6B"

    // MARK: - Constants

    /// Built-in category names that cannot be reused
    private let reservedNames = ["work", "personal", "health", "shopping", "other"]

    /// Curated SF Symbol icons grouped by section
    private let iconSections: [(title: String, icons: [String])] = [
        ("Common", [
            "star.fill", "heart.fill", "bolt.fill", "flame.fill",
            "tag.fill", "bookmark.fill", "flag.fill", "bell.fill"
        ]),
        ("Activities", [
            "figure.run", "dumbbell.fill", "sportscourt.fill", "bicycle",
            "music.note", "book.fill", "paintbrush.fill", "camera.fill"
        ]),
        ("Places", [
            "house.fill", "building.2.fill", "car.fill", "airplane",
            "cart.fill", "cup.and.saucer.fill", "fork.knife", "bed.double.fill"
        ]),
        ("Tech", [
            "desktopcomputer", "laptopcomputer", "phone.fill", "gamecontroller.fill",
            "wifi", "envelope.fill", "globe", "link"
        ]),
        ("Nature", [
            "leaf.fill", "drop.fill", "sun.max.fill", "moon.fill",
            "cloud.fill", "snowflake", "pawprint.fill", "fish.fill"
        ]),
        ("People", [
            "person.fill", "person.2.fill", "figure.wave", "hands.sparkles.fill",
            "brain.head.profile", "eyes", "hand.thumbsup.fill", "graduationcap.fill"
        ])
    ]

    /// Preset color swatches
    private let colorSwatches: [(hex: String, name: String)] = [
        ("FF6B6B", "Red"),
        ("FF8E53", "Orange"),
        ("FFC857", "Yellow"),
        ("2DD881", "Green"),
        ("4ECDC4", "Teal"),
        ("4A90E2", "Blue"),
        ("7B61FF", "Purple"),
        ("BD10E0", "Magenta"),
        ("FF69B4", "Pink"),
        ("A0522D", "Brown"),
        ("20B2AA", "Sea Green"),
        ("FFD700", "Gold")
    ]

    // MARK: - Computed Properties

    private var isEditing: Bool {
        editingCategory != nil
    }

    private var isFormValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }

        // Check reserved names
        if reservedNames.contains(trimmedName.lowercased()) { return false }

        // Check uniqueness among custom categories (excluding self when editing)
        let isDuplicate = existingCustomCategories.contains { cat in
            cat.name.lowercased() == trimmedName.lowercased() && cat.id != editingCategory?.id
        }
        return !isDuplicate
    }

    private var selectedColor: Color {
        Color(hex: selectedColorHex)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkGray1.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.section) {
                        // Live preview
                        previewSection

                        // Name input
                        nameSection

                        // Icon picker
                        iconPickerSection

                        // Color picker
                        colorPickerSection

                        // Save button
                        Button(isEditing ? "Save Changes" : "Create Category") {
                            saveCategory()
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
                    Text(isEditing ? "Edit Category" : "New Category")
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
                if let cat = editingCategory {
                    name = cat.name
                    selectedIcon = cat.iconName
                    selectedColorHex = cat.colorHex
                }
            }
        }
        .presentationBackground(Color.darkGray1)
    }

    // MARK: - Subviews

    /// Live preview of the category as it will appear
    private var previewSection: some View {
        VStack(spacing: Spacing.md) {
            Text("PREVIEW")
                .font(.system(size: Typography.labelSize, weight: .semibold))
                .foregroundStyle(Color.mediumGray)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: Spacing.lg) {
                // As category button
                VStack(spacing: Spacing.xs) {
                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.standard)
                            .fill(selectedColor.opacity(0.3))
                            .frame(width: ComponentSize.categoryButton, height: ComponentSize.categoryButton)

                        RoundedRectangle(cornerRadius: CornerRadius.standard)
                            .stroke(selectedColor, lineWidth: 2)
                            .frame(width: ComponentSize.categoryButton, height: ComponentSize.categoryButton)

                        Image(systemName: selectedIcon)
                            .font(.system(size: 24))
                            .foregroundStyle(selectedColor)
                    }

                    Text(name.isEmpty ? "Name" : name)
                        .font(.system(size: Typography.captionSize, weight: .medium))
                        .foregroundStyle(selectedColor)
                        .lineLimit(1)
                }

                // As badge
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Badge:")
                        .font(.system(size: Typography.captionSize, weight: .medium))
                        .foregroundStyle(Color.mediumGray)

                    Text((name.isEmpty ? "NAME" : name).uppercased())
                        .font(.system(size: Typography.captionSize, weight: .semibold))
                        .foregroundStyle(selectedColor)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(selectedColor.opacity(0.2))
                        .clipShape(Capsule())
                }

                Spacer()
            }
            .padding(Spacing.lg)
            .background(Color.darkGray2)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
        }
    }

    /// Name text field
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("CATEGORY NAME")
                .font(.system(size: Typography.labelSize, weight: .semibold))
                .foregroundStyle(Color.mediumGray)

            TextField("", text: $name, prompt: Text("Enter category name...")
                .foregroundStyle(Color.mediumGray))
                .font(.system(size: Typography.h4Size, weight: .medium))
                .foregroundStyle(Color.pureWhite)
                .padding(Spacing.lg)
                .background(Color.darkGray2)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
                .autocorrectionDisabled()

            if !name.isEmpty && reservedNames.contains(name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) {
                Text("This name is reserved for built-in categories")
                    .font(.system(size: Typography.captionSize, weight: .medium))
                    .foregroundStyle(Color.strainRed)
            }
        }
    }

    /// Icon selection grid
    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("ICON")
                .font(.system(size: Typography.labelSize, weight: .semibold))
                .foregroundStyle(Color.mediumGray)

            VStack(spacing: Spacing.lg) {
                ForEach(iconSections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text(section.title)
                            .font(.system(size: Typography.captionSize, weight: .semibold))
                            .foregroundStyle(Color.mediumGray.opacity(0.7))

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 8), spacing: Spacing.sm) {
                            ForEach(section.icons, id: \.self) { icon in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedIcon = icon
                                    }
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedIcon == icon ? selectedColor.opacity(0.3) : Color.darkGray2)
                                            .frame(height: 40)

                                        if selectedIcon == icon {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedColor, lineWidth: 2)
                                                .frame(height: 40)
                                        }

                                        Image(systemName: icon)
                                            .font(.system(size: 18))
                                            .foregroundStyle(selectedIcon == icon ? selectedColor : Color.mediumGray)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(Spacing.lg)
            .background(Color.darkGray2)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
        }
    }

    /// Color selection grid
    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("COLOR")
                .font(.system(size: Typography.labelSize, weight: .semibold))
                .foregroundStyle(Color.mediumGray)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 6), spacing: Spacing.md) {
                ForEach(colorSwatches, id: \.hex) { swatch in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedColorHex = swatch.hex
                        }
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: swatch.hex))
                                .frame(width: 40, height: 40)

                            if selectedColorHex == swatch.hex {
                                Circle()
                                    .stroke(Color.pureWhite, lineWidth: 3)
                                    .frame(width: 40, height: 40)

                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color.pureWhite)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Spacing.lg)
            .background(Color.darkGray2)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.standard))
        }
    }

    // MARK: - Methods

    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existing = editingCategory {
            // Update existing
            existing.name = trimmedName
            existing.iconName = selectedIcon
            existing.colorHex = selectedColorHex
        } else {
            // Determine next sort order
            let maxOrder = existingCustomCategories.map(\.sortOrder).max() ?? -1
            let category = CustomCategory(
                name: trimmedName,
                iconName: selectedIcon,
                colorHex: selectedColorHex,
                sortOrder: maxOrder + 1
            )
            modelContext.insert(category)
        }

        try? modelContext.save()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }
}

// MARK: - Preview

#Preview {
    AddCategorySheet()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self, CustomCategory.self], inMemory: true)
}
