import Foundation

struct CheckIn: Identifiable, Codable, Hashable {
    let id: UUID
    let parkId: UUID
    let parkName: String
    let timestamp: Date
    let mood: VisitMood?
    let photoIdentifier: String?

    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: timestamp)
    }
}
