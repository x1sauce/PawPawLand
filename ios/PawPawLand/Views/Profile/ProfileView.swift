import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    private let gridColumns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    profileHeader
                    statsRow
                    mapProgressCard
                    pinsSection
                    instagramGrid
                    ComingSoonBanner(
                        title: "Public Leaderboards",
                        subtitle: "City-wide park legends — your pack's ranking drops soon"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(PawColors.heroGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("@\(appState.dogProfile.name.lowercased())_adventures")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle(isOn: Binding(
                        get: { appState.isProfilePublic },
                        set: { appState.isProfilePublic = $0 }
                    )) {
                        Image(systemName: appState.isProfilePublic ? "eye.fill" : "eye.slash.fill")
                    }
                    .toggleStyle(.button)
                    .foregroundStyle(PawColors.gold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            DogAvatarView(profile: appState.dogProfile, size: 88)

            VStack(alignment: .leading, spacing: 6) {
                Text(appState.dogProfile.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(PawColors.textPrimary)
                Text(appState.dogProfile.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(PawColors.gold)
                Text("with \(appState.humanDisplayName)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
                Text(appState.isProfilePublic ? "Public profile — friends can see your map" : "Private profile")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textTertiary)
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            instagramStat(value: "\(appState.socialPosts.count)", label: "moments")
            Divider().frame(height: 36).background(PawColors.surfaceBorder)
            instagramStat(value: "\(appState.parkPins.filter(\.isUnlocked).count)", label: "pins")
            Divider().frame(height: 36).background(PawColors.surfaceBorder)
            instagramStat(value: "\(appState.explorationStats.visitedParks)", label: "parks")
        }
        .padding(.vertical, 12)
    }

    private func instagramStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(PawColors.textPrimary)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(PawColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var mapProgressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Map unlocked")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Spacer()
                Text(String(format: "%.0f%%", appState.mapExploredPercentage))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(PawColors.mint)
            }
            Text("Friends see glowing areas you've explored in \(appState.selectedCity)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(PawColors.textSecondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(PawColors.surfaceElevated).frame(height: 8)
                    Capsule()
                        .fill(PawColors.goldButtonGradient)
                        .frame(
                            width: geo.size.width * CGFloat(appState.mapExploredPercentage / 100),
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            Text(appState.explorationStats.progressLabel)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(PawColors.textTertiary)
        }
        .padding(16)
        .background(PawColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(PawColors.surfaceBorder, lineWidth: 1)
        }
    }

    private var pinsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Collectible park pins")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(appState.parkPins) { pin in
                        VStack(spacing: 6) {
                            ParkPinBadge(pin: pin, size: 56)
                            Text(pin.title)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(pin.isUnlocked ? PawColors.textSecondary : PawColors.textTertiary)
                                .lineLimit(1)
                                .frame(width: 72)
                        }
                    }
                }
            }
        }
    }

    private var instagramGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Moments grid")

            if appState.socialPosts.isEmpty {
                Text("Share a paw moment to fill your grid!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
            } else {
                LazyVGrid(columns: gridColumns, spacing: 2) {
                    ForEach(appState.socialPosts) { post in
                        ZStack(alignment: .bottomLeading) {
                            ParkThumbnail(seed: post.imageSeed, size: 400)
                                .frame(height: 120)
                                .clipped()
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.55)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            Text(post.parkName)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(6)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}
