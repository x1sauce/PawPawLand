import Foundation
import SwiftUI

struct Badge: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let iconName: String
    let isEarned: Bool
    let earnedDate: Date?

    var tint: Color {
        isEarned ? PawColors.gold : PawColors.textTertiary
    }
}

enum ExplorerRank: String, CaseIterable {
    case newcomer = "Newcomer"
    case explorer = "Explorer"
    case adventurer = "Adventurer"
    case trailblazer = "Trailblazer"
    case cityMaster = "City Master"

    static func forParksVisited(_ count: Int) -> ExplorerRank {
        switch count {
        case 0..<3: return .newcomer
        case 3..<10: return .explorer
        case 10..<25: return .adventurer
        case 25..<50: return .trailblazer
        default: return .cityMaster
        }
    }
}
