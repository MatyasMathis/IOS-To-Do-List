//
//  NotebookButtons.swift
//  dailytodolist
//
//  Purpose: Custom button styles for notebook theme
//  Design: Sticky note style buttons, washi tape selectors
//

import SwiftUI

/// Primary button styled as a sticky note
struct StickyNoteButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.handwrittenBody)
            }
            .foregroundStyle(Color.inkBlack)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.stickyNote)
                    .fill(
                        LinearGradient(
                            colors: [Color.highlightYellow, Color.highlightYellow.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .stickyNoteShadow()
        }
        .buttonStyle(.plain)
    }
}

/// Category selector button styled as washi tape
struct WashiTapeCategoryButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void

    private var categoryColor: Color {
        Color.forCategory(category)
    }

    private var emoji: String {
        Color.emojiForCategory(category)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text(emoji)
                    .font(.system(size: 24))
                Text(category.isEmpty ? "None" : category)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.inkBlack)
            }
            .frame(width: 60, height: 55)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.washiTape)
                    .fill(category.isEmpty ? Color.pencilGray.opacity(0.2) : categoryColor.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.washiTape)
                    .stroke(isSelected ? Color.inkBlack : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(color: isSelected ? Color.black.opacity(0.1) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

/// Floating pen button for adding tasks
struct FloatingPenButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.bluePen)
                    .frame(width: 64, height: 64)

                Image(systemName: "pencil")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.white)
                    .rotationEffect(.degrees(-45))
            }
            .floatingPaperShadow()
        }
        .buttonStyle(.plain)
    }
}

/// Hand-drawn style checkbox
struct HandDrawnCheckbox: View {
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Checkbox square with slight imperfection
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.inkBlack, lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .rotationEffect(.degrees(isChecked ? 0 : -1))

                // Checkmark when checked
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.greenCheckmark)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

/// Hand-drawn radio button
struct HandDrawnRadio: View {
    let isSelected: Bool
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .stroke(Color.inkBlack, lineWidth: 2)
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(Color.bluePen)
                            .frame(width: 10, height: 10)
                    }
                }

                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.inkBlack)

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        StickyNoteButton(title: "Add to Today's List") { }

        HStack(spacing: 8) {
            WashiTapeCategoryButton(category: "Work", isSelected: true) { }
            WashiTapeCategoryButton(category: "Personal", isSelected: false) { }
            WashiTapeCategoryButton(category: "Health", isSelected: false) { }
        }

        HStack {
            HandDrawnCheckbox(isChecked: false) { }
            Text("Unchecked task")

            Spacer()

            HandDrawnCheckbox(isChecked: true) { }
            Text("Checked task")
        }

        HandDrawnRadio(isSelected: false, label: "One-time task") { }
        HandDrawnRadio(isSelected: true, label: "Every day (recurring)") { }

        Spacer()

        HStack {
            Spacer()
            FloatingPenButton { }
        }
    }
    .padding()
    .background(Color.paperCream)
}
