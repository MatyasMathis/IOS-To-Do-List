//
//  ShadowModifiers.swift
//  dailytodolist
//
//  Purpose: Shadow view modifiers for paper-like depth effects
//  Design: Warm shadows that mimic paper layers
//

import SwiftUI

extension View {
    /// Paper on notebook shadow - subtle lift effect
    func paperShadow() -> some View {
        self.shadow(
            color: Color(red: 44/255, green: 36/255, blue: 22/255, opacity: 0.15),
            radius: 6,
            x: 0,
            y: 2
        )
    }

    /// Floating paper shadow - more prominent lift
    func floatingPaperShadow() -> some View {
        self.shadow(
            color: Color(red: 44/255, green: 36/255, blue: 22/255, opacity: 0.2),
            radius: 12,
            x: 0,
            y: 4
        )
    }

    /// Sticky note shadow - soft, subtle
    func stickyNoteShadow() -> some View {
        self.shadow(
            color: Color(red: 44/255, green: 36/255, blue: 22/255, opacity: 0.1),
            radius: 8,
            x: 0,
            y: 3
        )
    }

    /// Index card shadow - medium depth
    func indexCardShadow() -> some View {
        self.shadow(
            color: Color(red: 44/255, green: 36/255, blue: 22/255, opacity: 0.12),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}
