import Foundation
import CoreLocation

struct DogPark: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let description: String
    let address: String
    let latitude: Double
    let longitude: Double
    let isFenced: Bool
    let isOffLeash: Bool
    let hasWater: Bool
    let hasLighting: Bool
    let hours: String?
    let neighborhood: String
    let imageSeed: String
    var distanceMiles: Double?
    var distanceKm: Double?
    let phone: String?
    let website: String?

    init(
        id: UUID,
        name: String,
        description: String,
        address: String,
        latitude: Double,
        longitude: Double,
        isFenced: Bool,
        isOffLeash: Bool,
        hasWater: Bool,
        hasLighting: Bool,
        hours: String?,
        neighborhood: String,
        imageSeed: String,
        distanceMiles: Double? = nil,
        distanceKm: Double? = nil,
        phone: String? = nil,
        website: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.isFenced = isFenced
        self.isOffLeash = isOffLeash
        self.hasWater = hasWater
        self.hasLighting = hasLighting
        self.hours = hours
        self.neighborhood = neighborhood
        self.imageSeed = imageSeed
        self.distanceMiles = distanceMiles
        self.distanceKm = distanceKm
        self.phone = phone
        self.website = website
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var distanceLabel: String? {
        if let miles = distanceMiles {
            return String(format: "%.1f mi away", miles)
        }
        if let km = distanceKm {
            return String(format: "%.1f km away", km)
        }
        return nil
    }

    var featureSummary: String {
        var parts: [String] = []
        if isFenced { parts.append("Fenced") }
        if isOffLeash { parts.append("Off-leash") }
        if hasWater { parts.append("Water") }
        if hasLighting { parts.append("Lighting") }
        return parts.joined(separator: " · ")
    }
}

struct PeakTimeData: Identifiable {
    let id = UUID()
    let hour: Int
    let activity: Double
}

enum VisitMood: String, CaseIterable, Codable {
    case sad, neutral, happy, loved

    var emoji: String {
        switch self {
        case .sad: return "😢"
        case .neutral: return "😐"
        case .happy: return "😊"
        case .loved: return "🥰"
        }
    }

    var label: String {
        switch self {
        case .sad: return "Rough"
        case .neutral: return "Okay"
        case .happy: return "Great"
        case .loved: return "Amazing"
        }
    }
}
