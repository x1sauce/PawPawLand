import SwiftUI

struct ParkDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let park: DogPark
    @State private var selectedWeekday = Calendar.current.component(.weekday, from: Date()) - 1

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection
                    contentSection
                }
            }
            .background(PawColors.background)
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(PawColors.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(PawColors.surface.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(PawColors.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(PawColors.surface.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            ParkThumbnail(seed: park.imageSeed, size: 400)
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .clipped()

            LinearGradient(
                colors: [.clear, PawColors.background.opacity(0.3), PawColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 260)

            VStack(alignment: .leading, spacing: 4) {
                Text(park.neighborhood)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.gold)
            }
            .padding(20)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(park.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(PawColors.textPrimary)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                        Text(park.address)
                            .lineLimit(2)
                    }
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
                }

                Spacer()

                Button {
                    appState.toggleFavorite(park)
                } label: {
                    Image(systemName: appState.isFavorite(park) ? "star.fill" : "star")
                        .font(.system(size: 22))
                        .foregroundStyle(appState.isFavorite(park) ? PawColors.gold : PawColors.textTertiary)
                }
            }

            if appState.isVisited(park) {
                visitedBadge
            }

            PawCard {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "Peak Times")

                    WeekdayChips(selectedWeekday: $selectedWeekday)

                    PeakTimesChart(data: MockData.peakTimes(for: selectedWeekday))
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "About")
                Text(park.description)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
                    .lineSpacing(4)

                if let hours = park.hours {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundStyle(PawColors.gold)
                        Text(hours)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(PawColors.textSecondary)
                    }
                    .padding(.top, 4)
                }

                if let phone = park.phone, !phone.isEmpty {
                    Link(destination: URL(string: "tel:\(phone)")!) {
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(PawColors.gold)
                            Text(phone)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                    }
                    .foregroundStyle(PawColors.textSecondary)
                    .padding(.top, 4)
                }

                if let website = park.website, let url = URL(string: website) {
                    Link(destination: url) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .foregroundStyle(PawColors.gold)
                            Text("Website")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                    }
                    .foregroundStyle(PawColors.textSecondary)
                    .padding(.top, 4)
                }
            }

            ExplorationProgressBar(stats: appState.explorationStats)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }

    private var visitedBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(PawColors.gold)
            Text("You've explored this park")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(PawColors.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(PawColors.gold.opacity(0.12))
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(PawColors.gold.opacity(0.3), lineWidth: 1)
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().background(PawColors.surfaceBorder)
            PawButton(title: "Check In", icon: "location.fill") {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    appState.beginCheckIn(for: park)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(PawColors.background.opacity(0.95))
        }
    }
}

#Preview {
    ParkDetailView(park: MockData.parks[0])
        .environment(AppState())
}
