import SwiftUI

/// Warm dark-mode palette — cozy adventure, not corporate charcoal.
enum PawColors {
    // Warm night sky backgrounds
    static let background = Color(red: 0.09, green: 0.08, blue: 0.14)
    static let backgroundGlow = Color(red: 0.14, green: 0.10, blue: 0.22)
    static let surface = Color(red: 0.14, green: 0.12, blue: 0.20)
    static let surfaceElevated = Color(red: 0.18, green: 0.15, blue: 0.26)
    static let surfaceBorder = Color.white.opacity(0.10)

    // Playful accents
    static let gold = Color(red: 1.0, green: 0.78, blue: 0.35)
    static let goldDim = Color(red: 0.85, green: 0.62, blue: 0.22)
    static let goldGlow = Color(red: 1.0, green: 0.78, blue: 0.35).opacity(0.40)

    static let coral = Color(red: 1.0, green: 0.52, blue: 0.45)
    static let mint = Color(red: 0.45, green: 0.88, blue: 0.72)
    static let sky = Color(red: 0.45, green: 0.72, blue: 1.0)
    static let lavender = Color(red: 0.72, green: 0.58, blue: 1.0)

    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.72)
    static let textTertiary = Color(white: 0.48)

    static let visitedGreen = Color(red: 0.40, green: 0.88, blue: 0.62)
    static let unvisitedPin = Color(red: 0.75, green: 0.72, blue: 0.85)

    // Map discovery fog — warm purple tint, not cold black
    static let fogOverlay = Color(red: 0.06, green: 0.05, blue: 0.12).opacity(0.78)
    static let undiscoveredTint = Color(red: 0.12, green: 0.10, blue: 0.18).opacity(0.55)

    static let chartBar = gold.opacity(0.90)
    static let chartBarDim = Color(white: 0.22)

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.22, green: 0.14, blue: 0.32),
            background,
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let goldButtonGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.86, blue: 0.45),
            Color(red: 0.95, green: 0.65, blue: 0.20),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mapIllustrationGradient = LinearGradient(
        colors: [
            Color(red: 0.18, green: 0.14, blue: 0.28).opacity(0.35),
            Color(red: 0.10, green: 0.08, blue: 0.16).opacity(0.15),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func discoveryGlow(for level: DiscoveryLevel) -> Color {
        switch level {
        case .unknown: return .clear
        case .discovered: return mint.opacity(0.35)
        case .familiar: return sky.opacity(0.40)
        case .regular: return gold.opacity(0.45)
        case .homeTurf: return coral.opacity(0.50)
        }
    }

    static func ringColor(for index: Int) -> Color {
        switch index {
        case 0: return coral
        case 1: return mint
        default: return sky
        }
    }
}
