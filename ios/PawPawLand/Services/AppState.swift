import Foundation
import SwiftUI
import UIKit
import CoreLocation
import MapKit

enum ParksLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed
}

@MainActor
@Observable
final class AppState {
    let locationManager = LocationManager()

    var parks: [DogPark] = []
    var parksLoadState: ParksLoadState = .idle
    var parksErrorMessage: String?
    var totalParksInArea = 0
    var searchRadiusMiles = DogParkAPI.defaultRadiusMiles
    var mapCenter = MockData.laCenter
    var mapSpan = MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)

    var visitedParkIds: Set<UUID> = []
    var checkIns: [CheckIn] = []
    var badges: [Badge] = MockData.badges
    var selectedPark: DogPark?
    var selectedTab: AppTab = .explore
    var showCheckInSheet = false
    var checkInPark: DogPark?
    var newlyUnlockedPark: DogPark?
    var showUnlockCelebration = false
    var favoriteParkIds: Set<UUID> = []
    var selectedCity = "Your Area"

    var explorationStats: ExplorationStats {
        ExplorationStats(
            city: selectedCity,
            totalParks: max(totalParksInArea, parks.count),
            visitedParks: visitedParkIds.count,
            totalCheckIns: checkIns.count,
            badgesEarned: badges.filter(\.isEarned).count
        )
    }

    var explorerRank: ExplorerRank {
        ExplorerRank.forParksVisited(visitedParkIds.count)
    }

    var unvisitedNearbyCount: Int {
        parks.filter { !visitedParkIds.contains($0.id) }.count
    }

    var isLoadingParks: Bool {
        parksLoadState == .loading
    }

    func isVisited(_ park: DogPark) -> Bool {
        visitedParkIds.contains(park.id)
    }

    func isFavorite(_ park: DogPark) -> Bool {
        favoriteParkIds.contains(park.id)
    }

    func toggleFavorite(_ park: DogPark) {
        if favoriteParkIds.contains(park.id) {
            favoriteParkIds.remove(park.id)
        } else {
            favoriteParkIds.insert(park.id)
        }
    }

    func park(by id: UUID) -> DogPark? {
        parks.first { $0.id == id }
    }

    func checkIns(for date: Date) -> [CheckIn] {
        let calendar = Calendar.current
        return checkIns.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
    }

    func datesWithCheckIns(in month: Date) -> Set<Int> {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        var days = Set<Int>()
        for checkIn in checkIns {
            let checkInComponents = calendar.dateComponents([.year, .month, .day], from: checkIn.timestamp)
            if checkInComponents.year == components.year && checkInComponents.month == components.month {
                days.insert(checkInComponents.day ?? 0)
            }
        }
        return days
    }

    /// GPS → import OSM data → load nearby parks for the map.
    func loadParksNearUser() async {
        parksLoadState = .loading
        parksErrorMessage = nil

        guard let coordinate = await locationManager.requestLocation() else {
            parksLoadState = .failed
            parksErrorMessage = locationManager.lastError ?? "Could not determine your location."
            return
        }

        mapCenter = coordinate
        selectedCity = locationManager.areaLabel
        await refreshParks(around: coordinate)
    }

    func refreshParks(around coordinate: CLLocationCoordinate2D) async {
        parksLoadState = .loading
        parksErrorMessage = nil
        mapCenter = coordinate

        do {
            let nearby = try await DogParkAPI.syncAndFetchNearby(
                lat: coordinate.latitude,
                lng: coordinate.longitude,
                radiusMiles: searchRadiusMiles
            )
            parks = nearby
            totalParksInArea = nearby.count
            parksLoadState = .loaded
            selectedCity = locationManager.areaLabel
            mapSpan = spanForParkCount(nearby.count)
        } catch {
            parksLoadState = .failed
            parksErrorMessage = error.localizedDescription
        }
    }

    func beginCheckIn(for park: DogPark) {
        checkInPark = park
        showCheckInSheet = true
    }

    func completeCheckIn(mood: VisitMood?) {
        guard let park = checkInPark else { return }

        let wasFirstVisit = !visitedParkIds.contains(park.id)
        visitedParkIds.insert(park.id)

        let checkIn = CheckIn(
            id: UUID(),
            parkId: park.id,
            parkName: park.name,
            timestamp: Date(),
            mood: mood,
            photoIdentifier: nil
        )
        checkIns.insert(checkIn, at: 0)

        showCheckInSheet = false
        checkInPark = nil

        if wasFirstVisit {
            newlyUnlockedPark = park
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.showUnlockCelebration = true
            }
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func dismissUnlockCelebration() {
        showUnlockCelebration = false
        newlyUnlockedPark = nil
    }

    func clearedFogRadius(for park: DogPark) -> Double {
        isVisited(park) ? 1200 : 0
    }

    private func spanForParkCount(_ count: Int) -> MKCoordinateSpan {
        switch count {
        case 0 ... 5:
            return MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        case 6 ... 20:
            return MKCoordinateSpan(latitudeDelta: 0.14, longitudeDelta: 0.14)
        default:
            return MKCoordinateSpan(latitudeDelta: 0.22, longitudeDelta: 0.22)
        }
    }
}

enum AppTab: Int, CaseIterable, Identifiable {
    case explore, checkIn, journal, profile

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .explore: return "Explore"
        case .checkIn: return "Check-in"
        case .journal: return "Calendar"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .explore: return "map.fill"
        case .checkIn: return "location.fill"
        case .journal: return "calendar"
        case .profile: return "person.fill"
        }
    }
}
