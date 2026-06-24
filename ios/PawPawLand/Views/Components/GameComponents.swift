import SwiftUI

struct DogAvatarView: View {
    let profile: DogProfile
    var size: CGFloat = 88
    var showLevel: Bool = true

    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [PawColors.backgroundGlow, PawColors.surface],
                        center: .center,
                        startRadius: 4,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)
                .overlay {
                    Text(profile.mood.emoji)
                        .font(.system(size: size * 0.42))
                }
                .overlay {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [PawColors.gold, PawColors.coral, PawColors.mint, PawColors.gold],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                }
                .glowRing(color: PawColors.gold, radius: 6)

            if showLevel {
                Text("Lv.\(profile.level)")
                    .font(.system(size: size * 0.13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.08, blue: 0.02))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(PawColors.goldButtonGradient)
                    .clipShape(Capsule())
                    .offset(y: size * 0.12)
            }
        }
    }
}

struct ActivityRingsView: View {
    let goals: ActivityGoals
    var size: CGFloat = 180

    private let lineWidth: CGFloat = 14

    var body: some View {
        ZStack {
            ring(progress: goals.walksProgress, color: PawColors.ringColor(for: 0), scale: 1.0)
            ring(progress: goals.exploreProgress, color: PawColors.ringColor(for: 1), scale: 0.74)
            ring(progress: goals.socialProgress, color: PawColors.ringColor(for: 2), scale: 0.48)

            VStack(spacing: 4) {
                Text("This week")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
                Text("\(goals.walksThisWeek)/\(goals.walksGoal)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(PawColors.textPrimary)
                Text("walks")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textTertiary)
            }
        }
        .frame(width: size, height: size)
    }

    private func ring(progress: Double, color: Color, scale: CGFloat) -> some View {
        let ringSize = size * scale
        return ZStack {
            Circle()
                .stroke(color.opacity(0.18), lineWidth: lineWidth)
                .frame(width: ringSize, height: ringSize)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: ringSize, height: ringSize)
                .glowRing(color: color, radius: 3)
        }
    }
}

struct ActivityRingLegend: View {
    let goals: ActivityGoals

    var body: some View {
        VStack(spacing: 10) {
            legendRow(color: PawColors.coral, title: "Walks", value: "\(goals.walksThisWeek)/\(goals.walksGoal)")
            legendRow(color: PawColors.mint, title: "New parks", value: "\(goals.newParksThisWeek)/\(goals.newParksGoal)")
            legendRow(color: PawColors.sky, title: "Moments", value: "\(goals.momentsSharedThisWeek)/\(goals.momentsGoal)")
        }
    }

    private func legendRow(color: Color, title: String, value: String) -> some View {
        HStack {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(PawColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(PawColors.textPrimary)
        }
    }
}

struct ParkPinBadge: View {
    let pin: ParkPin
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: pin.tintHex).opacity(0.22))
                .frame(width: size, height: size)
            Image(systemName: pin.iconName)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(Color(hex: pin.tintHex))
        }
        .overlay {
            Circle()
                .stroke(Color(hex: pin.tintHex).opacity(pin.isUnlocked ? 0.8 : 0.25), lineWidth: 2)
        }
        .opacity(pin.isUnlocked ? 1 : 0.45)
    }
}

struct ParkEventBanner: View {
    let event: ParkEvent

    var body: some View {
        HStack(spacing: 10) {
            Text("🎉")
            VStack(alignment: .leading, spacing: 2) {
                Text("\(event.dogName) the \(event.breed) is here!")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(PawColors.textPrimary)
                Text(event.vibe)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
            }
            Spacer()
            Text("LIVE")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(PawColors.coral)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(PawColors.coral.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(12)
        .background(PawColors.surfaceElevated.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PawColors.coral.opacity(0.35), lineWidth: 1)
        }
    }
}

struct ComingSoonBanner: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(PawColors.lavender)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(PawColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
            }
            Spacer()
            Text("SOON")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(PawColors.lavender)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(PawColors.lavender.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(PawColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(PawColors.lavender.opacity(0.25), lineWidth: 1)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 214, 102)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
