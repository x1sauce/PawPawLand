import SwiftUI

enum PawColors {
    static let background = Color(red: 0.05, green: 0.05, blue: 0.06)
    static let surface = Color(red: 0.10, green: 0.10, blue: 0.12)
    static let surfaceElevated = Color(red: 0.14, green: 0.14, blue: 0.16)
    static let surfaceBorder = Color.white.opacity(0.08)

    static let gold = Color(red: 0.96, green: 0.77, blue: 0.26)
    static let goldDim = Color(red: 0.72, green: 0.55, blue: 0.18)
    static let goldGlow = Color(red: 0.96, green: 0.77, blue: 0.26).opacity(0.35)

    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.62)
    static let textTertiary = Color(white: 0.42)

    static let visitedGreen = Color(red: 0.35, green: 0.78, blue: 0.52)
    static let unvisitedPin = Color(white: 0.85)

    static let fogOverlay = Color(red: 0.03, green: 0.03, blue: 0.05).opacity(0.82)
    static let fogCleared = Color.clear

    static let chartBar = gold.opacity(0.85)
    static let chartBarDim = Color(white: 0.22)

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.15, green: 0.10, blue: 0.05),
            background
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let goldButtonGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.84, blue: 0.35),
            Color(red: 0.92, green: 0.68, blue: 0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
