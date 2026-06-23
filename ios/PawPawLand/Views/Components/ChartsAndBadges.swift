import SwiftUI

struct PeakTimesChart: View {
    let data: [PeakTimeData]
    var highlightRange: ClosedRange<Int> = 17...19

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                PawTypography.caption("Activity by hour")
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(PawColors.gold)
                    Text("Most popular: \(MockData.mostPopularHourLabel)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(PawColors.textSecondary)
                }
            }

            HStack(alignment: .bottom, spacing: 3) {
                ForEach(data) { point in
                    let isPeak = highlightRange.contains(point.hour)
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(isPeak ? PawColors.chartBar : PawColors.chartBarDim)
                        .frame(height: max(4, CGFloat(point.activity) * 64))
                        .opacity(isPeak ? 1 : 0.7)
                }
            }
            .frame(height: 68)

            HStack {
                Text("6 AM")
                Spacer()
                Text("12 PM")
                Spacer()
                Text("6 PM")
                Spacer()
                Text("12 AM")
            }
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(PawColors.textTertiary)
        }
    }
}

struct WeekdayChips: View {
    @Binding var selectedWeekday: Int
    private let symbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    let isSelected = selectedWeekday == index
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedWeekday = index
                        }
                    } label: {
                        Text(symbols[index])
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(isSelected ? Color(red: 0.12, green: 0.08, blue: 0.02) : PawColors.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isSelected ? PawColors.gold : PawColors.surfaceElevated)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct BadgeIconView: View {
    let badge: Badge
    var size: CGFloat = 64

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(badge.isEarned ? PawColors.gold.opacity(0.15) : PawColors.surfaceElevated)
                    .frame(width: size, height: size)

                Circle()
                    .stroke(badge.isEarned ? PawColors.gold.opacity(0.5) : PawColors.surfaceBorder, lineWidth: 1.5)
                    .frame(width: size, height: size)

                Image(systemName: badge.iconName)
                    .font(.system(size: size * 0.32, weight: .semibold))
                    .foregroundStyle(badge.tint)
            }
            .opacity(badge.isEarned ? 1 : 0.45)

            Text(badge.title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(badge.isEarned ? PawColors.textSecondary : PawColors.textTertiary)
                .lineLimit(1)
                .frame(width: size + 12)
        }
    }
}

struct ExplorationProgressBar: View {
    let stats: ExplorationStats

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(stats.city)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(PawColors.textPrimary)
                    Text("Visited: \(stats.progressLabel)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(PawColors.textSecondary)
                }
                Spacer()
                Text(stats.completionLabel)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(PawColors.gold)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(PawColors.surfaceElevated)
                        .frame(height: 8)

                    Capsule()
                        .fill(PawColors.goldButtonGradient)
                        .frame(width: geo.size.width * CGFloat(stats.completionPercentage / 100), height: 8)
                        .glowRing(color: PawColors.gold, radius: 4)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(PawColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
