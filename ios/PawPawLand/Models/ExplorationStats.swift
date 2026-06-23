import Foundation

struct ExplorationStats {
    let city: String
    let totalParks: Int
    let visitedParks: Int
    let totalCheckIns: Int
    let badgesEarned: Int

    var remainingParks: Int {
        max(totalParks - visitedParks, 0)
    }

    var completionPercentage: Double {
        guard totalParks > 0 else { return 0 }
        return Double(visitedParks) / Double(totalParks) * 100
    }

    var completionLabel: String {
        String(format: "%.1f%%", completionPercentage)
    }

    var progressLabel: String {
        "\(visitedParks) / \(totalParks) parks"
    }
}
