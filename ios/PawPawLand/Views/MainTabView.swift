import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        ZStack {
            TabView(selection: $state.selectedTab) {
                ExploreMapView()
                    .tag(AppTab.explore)
                    .tabItem {
                        Label(AppTab.explore.title, systemImage: AppTab.explore.icon)
                    }

                CheckInView()
                    .tag(AppTab.checkIn)
                    .tabItem {
                        Label(AppTab.checkIn.title, systemImage: AppTab.checkIn.icon)
                    }

                AdventureJournalView()
                    .tag(AppTab.journal)
                    .tabItem {
                        Label(AppTab.journal.title, systemImage: AppTab.journal.icon)
                    }

                ProfileView()
                    .tag(AppTab.profile)
                    .tabItem {
                        Label(AppTab.profile.title, systemImage: AppTab.profile.icon)
                    }
            }
            .tint(PawColors.gold)

            if appState.showUnlockCelebration, let park = appState.newlyUnlockedPark {
                NewParkUnlockedView(park: park)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(100)
            }
        }
        .sheet(isPresented: $state.showCheckInSheet) {
            CheckInSheet()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
