import Foundation

struct DogProfile: Codable, Hashable {
    var name: String
    var level: Int
    var xp: Int
    var mood: DogMood

    var xpToNextLevel: Int { level * 120 }

    var levelProgress: Double {
        guard xpToNextLevel > 0 else { return 0 }
        return min(Double(xp) / Double(xpToNextLevel), 1)
    }

    var title: String {
        switch level {
        case 0 ... 2: return "Sniff Scout"
        case 3 ... 5: return "Trail Buddy"
        case 6 ... 9: return "Park Explorer"
        case 10 ... 14: return "Adventure Pup"
        default: return "Legendary Good Boy"
        }
    }
}

enum DogMood: String, CaseIterable, Codable {
    case sleepy, curious, happy, zoomies, proud

    var emoji: String {
        switch self {
        case .sleepy: return "😴"
        case .curious: return "👀"
        case .happy: return "🐕"
        case .zoomies: return "💨"
        case .proud: return "🏅"
        }
    }

    var label: String {
        switch self {
        case .sleepy: return "Cozy"
        case .curious: return "Sniffin'"
        case .happy: return "Happy tail"
        case .zoomies: return "Zoomies!"
        case .proud: return "So proud"
        }
    }
}

struct ParkPin: Identifiable, Hashable, Codable {
    let id: UUID
    let parkId: UUID
    let parkName: String
    let title: String
    let iconName: String
    let tintHex: String
    var isUnlocked: Bool
    var unlockedAt: Date?
}

struct ParkEvent: Identifiable, Hashable, Codable {
    let id: UUID
    let parkId: UUID
    let dogName: String
    let breed: String
    let vibe: String
    let expiresAt: Date

    var isActive: Bool { expiresAt > Date() }
}

struct ActivityGoals: Codable, Hashable {
    var walksThisWeek: Int
    var walksGoal: Int
    var newParksThisWeek: Int
    var newParksGoal: Int
    var momentsSharedThisWeek: Int
    var momentsGoal: Int

    var walksProgress: Double { min(Double(walksThisWeek) / Double(walksGoal), 1) }
    var exploreProgress: Double { min(Double(newParksThisWeek) / Double(newParksGoal), 1) }
    var socialProgress: Double { min(Double(momentsSharedThisWeek) / Double(momentsGoal), 1) }
}

struct SocialPost: Identifiable, Hashable {
    let id: UUID
    let parkName: String
    let imageSeed: String
    let caption: String
    let timestamp: Date
}

enum DiscoveryLevel: Int, CaseIterable {
    case unknown = 0
    case discovered = 1
    case familiar = 2
    case regular = 3
    case homeTurf = 4

    var label: String {
        switch self {
        case .unknown: return "Uncharted"
        case .discovered: return "Discovered"
        case .familiar: return "Familiar"
        case .regular: return "Regular spot"
        case .homeTurf: return "Home turf"
        }
    }

    static func from(visitCount: Int) -> DiscoveryLevel {
        switch visitCount {
        case 0: return .unknown
        case 1: return .discovered
        case 2 ... 3: return .familiar
        case 4 ... 6: return .regular
        default: return .homeTurf
        }
    }

    var glowOpacity: Double {
        switch self {
        case .unknown: return 0
        case .discovered: return 0.25
        case .familiar: return 0.45
        case .regular: return 0.65
        case .homeTurf: return 0.85
        }
    }

    var pinScale: CGFloat {
        switch self {
        case .unknown: return 0.85
        case .discovered: return 1.0
        case .familiar: return 1.05
        case .regular: return 1.1
        case .homeTurf: return 1.15
        }
    }
}
