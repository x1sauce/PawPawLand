import SwiftUI

struct PawButton: View {
    let title: String
    var icon: String? = nil
    var style: Style = .primary
    let action: () -> Void

    enum Style {
        case primary, secondary, ghost
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(foregroundColor)
            .background(background)
            .clipShape(Capsule())
            .overlay {
                if style == .secondary {
                    Capsule()
                        .stroke(PawColors.surfaceBorder, lineWidth: 1)
                }
            }
        }
        .buttonStyle(PawPressStyle())
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return Color(red: 0.12, green: 0.08, blue: 0.02)
        case .secondary, .ghost: return PawColors.textPrimary
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            PawColors.goldButtonGradient
        case .secondary:
            PawColors.surfaceElevated
        case .ghost:
            Color.clear
        }
    }
}

struct PawPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            PawTypography.statNumber(value)
            PawTypography.caption(label)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            PawTypography.headline(title)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(PawColors.gold)
                }
            }
        }
    }
}

struct PawCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .background(PawColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(PawColors.surfaceBorder, lineWidth: 1)
            }
    }
}

struct ParkThumbnail: View {
    let seed: String
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: "tree.fill")
                .font(.system(size: size * 0.35))
                .foregroundStyle(PawColors.gold.opacity(0.7))
                .offset(y: size * 0.08)

            Image(systemName: "pawprint.fill")
                .font(.system(size: size * 0.22))
                .foregroundStyle(.white.opacity(0.85))
                .offset(x: size * 0.15, y: size * 0.2)
        }
        .frame(width: size, height: size)
    }

    private var gradientColors: [Color] {
        let hash = abs(seed.hashValue)
        let hue = Double(hash % 360) / 360.0
        return [
            Color(hue: hue, saturation: 0.35, brightness: 0.25),
            Color(hue: hue, saturation: 0.25, brightness: 0.12)
        ]
    }
}

struct GlowRing: ViewModifier {
    var color: Color = PawColors.gold
    var radius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.25), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    func glowRing(color: Color = PawColors.gold, radius: CGFloat = 8) -> some View {
        modifier(GlowRing(color: color, radius: radius))
    }
}
