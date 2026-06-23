import SwiftUI

enum PawTypography {
    static func largeTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(PawColors.textPrimary)
    }

    static func title(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundStyle(PawColors.textPrimary)
    }

    static func headline(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(PawColors.textPrimary)
    }

    static func body(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(PawColors.textSecondary)
    }

    static func caption(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(PawColors.textTertiary)
    }

    static func statNumber(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(PawColors.textPrimary)
    }
}
