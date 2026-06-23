import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    profileHeader
                    statsSection
                    achievementsSection
                    recentPhotosSection
                    ExplorationProgressBar(stats: appState.explorationStats)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(PawColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18))
                            .foregroundStyle(PawColors.textSecondary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PawColors.surfaceElevated)
                    .frame(width: 100, height: 100)
                    .overlay {
                        Image(systemName: "dog.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(PawColors.gold)
                    }
                    .overlay {
                        Circle()
                            .stroke(PawColors.gold.opacity(0.4), lineWidth: 2)
                    }

                Text(appState.explorerRank.rawValue)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.08, blue: 0.02))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(PawColors.gold)
                    .clipShape(Capsule())
                    .offset(y: 58)
            }
            .padding(.bottom, 8)

            Text(MockData.userDisplayName)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(PawColors.textPrimary)

            Text("Adventuring with \(MockData.userDogName)")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(PawColors.textSecondary)
        }
        .padding(.top, 12)
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            StatPill(value: "\(appState.explorationStats.visitedParks)", label: "Parks")
            Divider().frame(height: 40).background(PawColors.surfaceBorder)
            StatPill(value: "\(appState.explorationStats.totalCheckIns)", label: "Check-ins")
            Divider().frame(height: 40).background(PawColors.surfaceBorder)
            StatPill(value: "\(appState.explorationStats.badgesEarned)", label: "Badges")
        }
        .padding(.vertical, 16)
        .background(PawColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(PawColors.surfaceBorder, lineWidth: 1)
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Achievements", actionTitle: "View All") {}

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(appState.badges) { badge in
                        BadgeIconView(badge: badge)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var recentPhotosSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Recent Photos", actionTitle: "View All") {}

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    let parks = appState.parks.isEmpty ? MockData.parks : appState.parks
                    ForEach(0..<min(5, parks.count), id: \.self) { index in
                        ParkThumbnail(seed: parks[index].imageSeed, size: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
