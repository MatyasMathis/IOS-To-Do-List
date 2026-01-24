//
//  NotebookBackground.swift
//  dailytodolist
//
//  Purpose: Notebook paper background with ruled lines, margin, and binding holes
//  Design: Skeuomorphic notebook paper effect
//

import SwiftUI

/// Notebook paper background with ruled lines and margin
struct NotebookBackground: View {
    var showBindingHoles: Bool = true
    var showMarginLine: Bool = true
    var lineSpacing: CGFloat = 28

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base paper color
                Color.paperCream

                // Ruled lines
                RuledLinesPattern(spacing: lineSpacing)

                // Margin line
                if showMarginLine {
                    MarginLine()
                }

                // Binding holes
                if showBindingHoles {
                    BindingHoles()
                }
            }
        }
    }
}

/// Horizontal ruled lines pattern
struct RuledLinesPattern: View {
    var spacing: CGFloat = 28

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                var y: CGFloat = spacing
                while y < geometry.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    y += spacing
                }
            }
            .stroke(Color.ruledLines, lineWidth: 1)
        }
    }
}

/// Vertical red margin line
struct MarginLine: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let x = Spacing.marginLineOffset
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: geometry.size.height))
            }
            .stroke(Color.marginRed, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
    }
}

/// Notebook binding holes on the left edge
struct BindingHoles: View {
    var body: some View {
        HStack {
            VStack(spacing: Spacing.bindingHoleSpacing) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color.leatherBrown.opacity(0.6))
                        .frame(width: Spacing.bindingHoleSize, height: Spacing.bindingHoleSize)
                }
            }
            .padding(.leading, Spacing.sm)
            .padding(.top, Spacing.lg)

            Spacer()
        }
    }
}

/// Progress card styled as an index card
struct IndexCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            content()
        }
        .padding(Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(Color.paperCream.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .stroke(Color.leatherBrown, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                )
        )
        .indexCardShadow()
    }
}

/// Date section header styled as a calendar page
struct CalendarPageHeader: View {
    let title: String

    var body: some View {
        HStack {
            // Spiral holes
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color.leatherBrown)
                        .frame(width: 6, height: 6)
                }
            }

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.inkBlack)

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .stroke(Color.leatherBrown, lineWidth: 2)
                )
        )
        .paperShadow()
    }
}

// MARK: - View Modifiers

/// Applies notebook paper background to a view
struct NotebookPaperModifier: ViewModifier {
    var showBindingHoles: Bool = false
    var showMarginLine: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                NotebookBackground(
                    showBindingHoles: showBindingHoles,
                    showMarginLine: showMarginLine
                )
            )
    }
}

extension View {
    /// Apply notebook paper background
    func notebookPaper(showBindingHoles: Bool = false, showMarginLine: Bool = false) -> some View {
        self.modifier(NotebookPaperModifier(showBindingHoles: showBindingHoles, showMarginLine: showMarginLine))
    }
}

// MARK: - Preview

#Preview {
    VStack {
        IndexCard {
            Text("Tasks Done: 4/8")
                .font(.handwrittenBody)
                .foregroundStyle(Color.inkBlack)

            ProgressView(value: 0.5)
                .tint(Color.greenCheckmark)
        }
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .notebookPaper(showBindingHoles: true, showMarginLine: true)
}
