//
//  MainTabView.swift
//  dailytodolist
//
//  Purpose: Root view with notebook-style bookmark tab navigation
//  Design: Bookmark tabs sticking up from notebook, paper texture
//

import SwiftUI
import SwiftData

/// Root view with notebook bookmark-style tab navigation
struct MainTabView: View {

    // MARK: - State

    @State private var selectedTab: Tab = .today

    // MARK: - Tab Enum

    enum Tab: CaseIterable {
        case today
        case history

        var label: String {
            switch self {
            case .today: return "Today"
            case .history: return "History"
            }
        }

        var icon: String {
            switch self {
            case .today: return "checkmark.circle"
            case .history: return "clock.arrow.circlepath"
            }
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            TabView(selection: $selectedTab) {
                TaskListView()
                    .toolbar(.hidden, for: .tabBar)
                    .tag(Tab.today)

                HistoryView()
                    .toolbar(.hidden, for: .tabBar)
                    .tag(Tab.history)
            }

            // Bookmark-style tab bar
            bookmarkTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Bookmark Tab Bar

    private var bookmarkTabBar: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(Tab.allCases, id: \.self) { tab in
                bookmarkTab(tab: tab)
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.xxl)
        .background(
            ZStack {
                // Base color (darker paper)
                Color.paperCream.opacity(0.95)

                // Stitching line at top
                VStack {
                    HStack(spacing: Spacing.sm) {
                        ForEach(0..<30, id: \.self) { _ in
                            Circle()
                                .fill(Color.leatherBrown)
                                .frame(width: 2, height: 2)
                        }
                    }
                    Spacer()
                }
                .padding(.top, Spacing.xs)
            }
        )
        .overlay(
            Rectangle()
                .fill(Color.leatherBrown)
                .frame(height: 2),
            alignment: .top
        )
    }

    // MARK: - Bookmark Tab

    private func bookmarkTab(tab: Tab) -> some View {
        Button {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: Spacing.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .medium))

                Text(tab.label)
                    .font(.handwrittenLabel)
                    .fixedSize()
            }
            .foregroundStyle(selectedTab == tab ? Color.inkBlack : Color.pencilGray)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: CornerRadius.card,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: CornerRadius.card
                )
                .fill(selectedTab == tab ? Color.paperCream : Color.leatherBrown.opacity(0.2))
            )
            .offset(y: selectedTab == tab ? -Spacing.xs : 0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .modelContainer(for: [TodoTask.self, TaskCompletion.self], inMemory: true)
}
