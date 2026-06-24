import Foundation
import SwiftUI
import UIKit
import CoreLocation
import MapKit

enum ExperienceMode: String {
    case showcase
    case live
}

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

    var experienceMode: ExperienceMode = .showcase
    var parks: [DogPark] = []
    var parksLoadState: ParksLoadState = .idle
    var parksErrorMessage: String?
    var totalParksInArea = 0
    var searchRadiusMiles = DogParkAPI.defaultRadiusMiles
    var mapCenter = MockData.laCenter
    var mapSpan = MKCoordinateSpan(latitudeDelta: 0.22, longitudeDelta: 0.22)

    var dogProfile = MockData.dogProfile
    var activityGoals = MockData.activityGoals
    var parkPins: [ParkPin] = []
    var parkEvents: [ParkEvent] = []
    var socialPosts: [SocialPost] = []
    var visitCountByParkId: [UUID: Int] = [:]
    var isProfilePublic = true

    var visitedParkIds: Set<UUID> = []
    var checkIns: [CheckIn] = []
    var badges: [Badge] = MockData.badges
    var selectedPark: DogPark?
    var selectedTab: AppTab = .explore
    var showCheckInSheet = false
    var checkInPark: DogPark?
    var newlyUnlockedPark: DogPark?
    var newlyUnlockedPin: ParkPin?
    var showUnlockCelebration = false
    var favoriteParkIds: Set<UUID> = []
    var selectedCity = MockData.city
    var humanDisplayName = MockData.userDisplayName

    init() {
        seedShowcaseExperience()
    }

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
        parks.filter { visitCount(for: $0) == 0 }.count
    }

    var mapExploredPercentage: Double {
        guard !parks.isEmpty else { return 0 }
        let explored = parks.filter { visitCount(for: $0) > 0 }.count
        return Double(explored) / Double(parks.count) * 100
    }

    var isLoadingParks: Bool {
        parksLoadState == .loading
    }

    func visitCount(for park: DogPark) -> Int {
        visitCountByParkId[park.id, default: 0]
    }

    func discoveryLevel(for park: DogPark) -> DiscoveryLevel {
        DiscoveryLevel.from(visitCount: visitCount(for: park))
    }

    func pin(for park: DogPark) -> ParkPin? {
        parkPins.first { $0.parkId == park.id }
    }

    func event(for park: DogPark) -> ParkEvent? {
        parkEvents.first { $0.parkId == park.id && $0.isActive }
    }

    func isVisited(_ park: DogPark) -> Bool {
        visitCount(for: park) > 0
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

    func loadParksNearUser() async {
        if experienceMode == .showcase {
            loadShowcaseParks()
            return
        }
        await loadLiveParks()
    }

    func loadShowcaseParks() {
        parksLoadState = .loading
        parksErrorMessage = nil
        mapCenter = MockData.laCenter
        selectedCity = MockData.city
        parks = MockData.parks
        totalParksInArea = MockData.parks.count
        mapSpan = MKCoordinateSpan(latitudeDelta: 0.22, longitudeDelta: 0.22)
        parksLoadState = .loaded
    }

    func loadLiveParks() async {
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

    func completeCheckIn(mood: VisitMood?, caption: String?) {
        guard let park = checkInPark else { return }

        let previousVisits = visitCount(for: park)
        let wasFirstVisit = previousVisits == 0
        visitCountByParkId[park.id, default: 0] += 1
        visitedParkIds.insert(park.id)

        if let mood {
            dogProfile.mood = mood.dogMood
        }
        dogProfile.xp += wasFirstVisit ? 80 : 35
        while dogProfile.xp >= dogProfile.xpToNextLevel {
            dogProfile.xp -= dogProfile.xpToNextLevel
            dogProfile.level += 1
        }

        activityGoals.walksThisWeek += 1
        activityGoals.momentsSharedThisWeek += 1
        if wasFirstVisit {
            activityGoals.newParksThisWeek += 1
        }

        let checkIn = CheckIn(
            id: UUID(),
            parkId: park.id,
            parkName: park.name,
            timestamp: Date(),
            mood: mood,
            photoIdentifier: nil,
            caption: caption,
            imageSeed: park.imageSeed
        )
        checkIns.insert(checkIn, at: 0)

        if let caption, !caption.isEmpty {
            socialPosts.insert(
                SocialPost(
                    id: UUID(),
                    parkName: park.name,
                    imageSeed: park.imageSeed,
                    caption: caption,
                    timestamp: Date()
                ),
                at: 0
            )
        }

        unlockPinIfNeeded(for: park)

        showCheckInSheet = false
        checkInPark = nil

        if wasFirstVisit {
            newlyUnlockedPark = park
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.showUnlockCelebration = true
            }
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func dismissUnlockCelebration() {
        showUnlockCelebration = false
        newlyUnlockedPark = nil
        newlyUnlockedPin = nil
    }

    private func unlockPinIfNeeded(for park: DogPark) {
        guard let index = parkPins.firstIndex(where: { $0.parkId == park.id && !$0.isUnlocked }) else {
            return
        }
        parkPins[index].isUnlocked = true
        parkPins[index].unlockedAt = Date()
        newlyUnlockedPin = parkPins[index]
    }

    private func seedShowcaseExperience() {
        parks = MockData.parks
        totalParksInArea = MockData.parks.count
        parkPins = MockData.parkPins
        parkEvents = MockData.parkEvents
        socialPosts = MockData.socialPosts
        visitCountByParkId = MockData.demoVisitCounts
        visitedParkIds = Set(visitCountByParkId.filter { $0.value > 0 }.map(\.key))

        let calendar = Calendar.current
        let now = Date()
        checkIns = MockData.demoCheckIns

        favoriteParkIds.insert(MockData.parks[0].id)
        favoriteParkIds.insert(MockData.parks[2].id)
        parksLoadState = .loaded
        _ = calendar
        _ = now
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
        case .checkIn: return "Moment"
        case .journal: return "Rings"
        case .profile: return "Lucky"
        }
    }

    var icon: String {
        switch self {
        case .explore: return "map.fill"
        case .checkIn: return "camera.fill"
        case .journal: return "circle.circle"
        case .profile: return "dog.fill"
        }
    }
}
