//
//  Theme.swift/Users/crea/Desktop/Leevda/Leevda/Leevda/Utilities/Extensions/Color+Theme.swift
//  Leevda
//
//  Dark theme colors and styles for the app
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    static let background = Color.black
    static let secondaryBackground = Color(white: 0.1)
    static let tertiaryBackground = Color(white: 0.15)

    // Purple and pink accent colors inspired by m6.png
    static let accentPurple = Color(red: 0.6, green: 0.3, blue: 0.9)
    static let accentPink = Color(red: 0.9, green: 0.4, blue: 0.7)
    static let accentCyan = Color(red: 0.3, green: 0.8, blue: 0.9)

    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.7)
    static let textTertiary = Color(white: 0.5)

    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [accentPurple, accentPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let secondaryGradient = LinearGradient(
        colors: [accentPurple, accentCyan],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Shadows
    static let buttonShadow = Shadow(
        color: accentPurple.opacity(0.5),
        radius: 10,
        x: 0,
        y: 5
    )

    // MARK: - Corner Radius
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16

    // MARK: - Spacing
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
}

// Helper struct for shadow definition
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
