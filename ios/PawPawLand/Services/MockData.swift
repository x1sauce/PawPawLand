import Foundation
import CoreLocation

enum MockData {
    static let city = "Los Angeles"
    static let totalCityParks = 143

    static let userDogName = "Lucky"
    static let userDisplayName = "Lucky's Dad"

    static let laCenter = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)

    static let parks: [DogPark] = [
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000001")!,
            name: "Silver Lake Dog Park",
            description: "A beloved neighborhood off-leash area with lake views, mature trees, and a friendly regular crowd. Fully fenced with separate areas for small and large dogs.",
            address: "1850 W Silver Lake Dr, Los Angeles, CA 90026",
            latitude: 34.0869,
            longitude: -118.2702,
            isFenced: true,
            isOffLeash: true,
            hasWater: true,
            hasLighting: true,
            hours: "6 AM – 10 PM",
            neighborhood: "Silver Lake",
            imageSeed: "silverlake"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000002")!,
            name: "Runyon Canyon Park",
            description: "Iconic hillside trails with sweeping city views. Dogs love the adventure — bring water and arrive early on weekends for cooler temps and fewer crowds.",
            address: "2000 N Fuller Ave, Los Angeles, CA 90046",
            latitude: 34.1105,
            longitude: -118.3493,
            isFenced: false,
            isOffLeash: true,
            hasWater: false,
            hasLighting: false,
            hours: "Sunrise – Sunset",
            neighborhood: "Hollywood Hills",
            imageSeed: "runyon"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000003")!,
            name: "Griffith Park Dog Park",
            description: "Spacious fenced area at the edge of LA's largest urban park. Plenty of room to run with shaded benches and a dedicated small-dog section.",
            address: "3201 Los Feliz Blvd, Los Angeles, CA 90027",
            latitude: 34.1365,
            longitude: -118.2942,
            isFenced: true,
            isOffLeash: true,
            hasWater: true,
            hasLighting: false,
            hours: "5 AM – 10 PM",
            neighborhood: "Los Feliz",
            imageSeed: "griffith"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000004")!,
            name: "Sepulveda Basin Off-Leash",
            description: "Expansive off-leash field along the LA River. A favorite for fetch and socializing — flat terrain makes it easy for dogs of all ages.",
            address: "17550 Victory Blvd, Van Nuys, CA 91406",
            latitude: 34.1862,
            longitude: -118.4728,
            isFenced: false,
            isOffLeash: true,
            hasWater: true,
            hasLighting: true,
            hours: "Dawn – Dusk",
            neighborhood: "Encino",
            imageSeed: "sepulveda"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000005")!,
            name: "Elysian Park Dog Area",
            description: "Quiet hillside spot with downtown skyline views. Less crowded than other parks — perfect for a peaceful morning adventure.",
            address: "929 Elysian Park Dr, Los Angeles, CA 90012",
            latitude: 34.0736,
            longitude: -118.2405,
            isFenced: true,
            isOffLeash: true,
            hasWater: false,
            hasLighting: false,
            hours: "6 AM – 9 PM",
            neighborhood: "Echo Park",
            imageSeed: "elysian"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000006")!,
            name: "Westminster Dog Park",
            description: "Well-maintained community park in the Westside. Artificial turf, agility equipment, and a water station keep pups happy year-round.",
            address: "1234 Pacific Ave, Venice, CA 90291",
            latitude: 33.9940,
            longitude: -118.4695,
            isFenced: true,
            isOffLeash: true,
            hasWater: true,
            hasLighting: true,
            hours: "7 AM – 9 PM",
            neighborhood: "Venice",
            imageSeed: "westminster"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000007")!,
            name: "Hermon Dog Park",
            description: "Cozy neighborhood gem in northeast LA. Shaded, friendly, and never overwhelming — a hidden favorite among local dog parents.",
            address: "4800 Via Marisol, Los Angeles, CA 90042",
            latitude: 34.1098,
            longitude: -118.1856,
            isFenced: true,
            isOffLeash: true,
            hasWater: true,
            hasLighting: false,
            hours: "6 AM – 8 PM",
            neighborhood: "Hermon",
            imageSeed: "hermon"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000008")!,
            name: "Lacy Park Dog Area",
            description: "Elegant San Marino park with a dedicated morning off-leash window. Lush lawns and towering trees create a postcard-worthy setting.",
            address: "148 Virginia Rd, San Marino, CA 91108",
            latitude: 34.1224,
            longitude: -118.1067,
            isFenced: false,
            isOffLeash: true,
            hasWater: true,
            hasLighting: false,
            hours: "6 – 10 AM off-leash",
            neighborhood: "San Marino",
            imageSeed: "lacy"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000009")!,
            name: "Lake Hollywood Park",
            description: "Stunning views of the Hollywood sign with a flat grassy area for off-leash play. A must-visit for out-of-town guests and their pups.",
            address: "3160 Canyon Lake Dr, Los Angeles, CA 90068",
            latitude: 34.1289,
            longitude: -118.3214,
            isFenced: false,
            isOffLeash: true,
            hasWater: false,
            hasLighting: false,
            hours: "Sunrise – Sunset",
            neighborhood: "Hollywood Hills",
            imageSeed: "lakehollywood"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000010")!,
            name: "South Park Doggie",
            description: "Downtown LA's go-to dog run. Compact but vibrant, with a loyal downtown crowd and easy access from the Arts District.",
            address: "1850 S San Pedro St, Los Angeles, CA 90015",
            latitude: 34.0289,
            longitude: -118.2622,
            isFenced: true,
            isOffLeash: true,
            hasWater: true,
            hasLighting: true,
            hours: "6 AM – 10 PM",
            neighborhood: "Downtown",
            imageSeed: "southpark"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000011")!,
            name: "Cheviot Hills Recreation",
            description: "Westside favorite with separate fenced areas. Well-groomed and family-friendly — a reliable spot for daily walks.",
            address: "2551 Motor Ave, Los Angeles, CA 90064",
            latitude: 34.0398,
            longitude: -118.4102,
            isFenced: true,
            isOffLeash: true,
            hasWater: true,
            hasLighting: true,
            hours: "5 AM – 10 PM",
            neighborhood: "Cheviot Hills",
            imageSeed: "cheviot"
        ),
        DogPark(
            id: UUID(uuidString: "A1000001-0000-0000-0000-000000000012")!,
            name: "Laurel Canyon Dog Park",
            description: "Intimate canyon hideaway beloved by creatives and their dogs. Rustic charm with a tight-knit community feel.",
            address: "8260 Kirkwood Dr, Los Angeles, CA 90046",
            latitude: 34.1082,
            longitude: -118.3847,
            isFenced: true,
            isOffLeash: true,
            hasWater: false,
            hasLighting: false,
            hours: "7 AM – 8 PM",
            neighborhood: "Laurel Canyon",
            imageSeed: "laurel"
        )
    ]

    static let badges: [Badge] = [
        Badge(id: UUID(), title: "First Steps", subtitle: "Your first adventure", iconName: "pawprint.fill", isEarned: true, earnedDate: Date().addingTimeInterval(-86400 * 30)),
        Badge(id: UUID(), title: "Early Bird", subtitle: "Check in before 8 AM", iconName: "sunrise.fill", isEarned: true, earnedDate: Date().addingTimeInterval(-86400 * 14)),
        Badge(id: UUID(), title: "Explorer", subtitle: "Visit 10 parks", iconName: "map.fill", isEarned: true, earnedDate: Date().addingTimeInterval(-86400 * 7)),
        Badge(id: UUID(), title: "Social Pup", subtitle: "5 parks in one week", iconName: "heart.fill", isEarned: true, earnedDate: Date().addingTimeInterval(-86400 * 3)),
        Badge(id: UUID(), title: "Weekend Warrior", subtitle: "Explore on Saturday & Sunday", iconName: "calendar", isEarned: false, earnedDate: nil),
        Badge(id: UUID(), title: "City Master", subtitle: "Visit 50 LA parks", iconName: "crown.fill", isEarned: false, earnedDate: nil)
    ]

    static func peakTimes(for weekday: Int) -> [PeakTimeData] {
        let patterns: [[Double]] = [
            [0.1, 0.1, 0.15, 0.2, 0.35, 0.55, 0.75, 0.9, 0.7, 0.5, 0.4, 0.45, 0.55, 0.6, 0.65, 0.7, 0.85, 0.95, 0.9, 0.7, 0.5, 0.35, 0.2, 0.1],
            [0.1, 0.1, 0.12, 0.18, 0.3, 0.5, 0.65, 0.75, 0.6, 0.45, 0.35, 0.4, 0.5, 0.55, 0.6, 0.65, 0.8, 0.85, 0.75, 0.55, 0.4, 0.25, 0.15, 0.1],
            [0.1, 0.1, 0.15, 0.22, 0.38, 0.58, 0.72, 0.82, 0.65, 0.48, 0.38, 0.42, 0.52, 0.58, 0.62, 0.68, 0.82, 0.92, 0.88, 0.68, 0.48, 0.3, 0.18, 0.1],
            [0.1, 0.1, 0.14, 0.2, 0.34, 0.52, 0.68, 0.78, 0.62, 0.46, 0.36, 0.4, 0.5, 0.56, 0.6, 0.66, 0.8, 0.88, 0.82, 0.62, 0.44, 0.28, 0.16, 0.1],
            [0.1, 0.1, 0.16, 0.24, 0.4, 0.6, 0.74, 0.84, 0.68, 0.5, 0.4, 0.44, 0.54, 0.6, 0.64, 0.7, 0.84, 0.94, 0.9, 0.7, 0.5, 0.32, 0.18, 0.1],
            [0.15, 0.12, 0.18, 0.28, 0.45, 0.65, 0.8, 0.88, 0.75, 0.58, 0.48, 0.52, 0.62, 0.68, 0.72, 0.78, 0.9, 0.98, 0.95, 0.78, 0.58, 0.38, 0.22, 0.12],
            [0.18, 0.14, 0.2, 0.3, 0.48, 0.68, 0.82, 0.9, 0.78, 0.62, 0.52, 0.56, 0.66, 0.72, 0.76, 0.82, 0.92, 1.0, 0.96, 0.8, 0.62, 0.42, 0.25, 0.14]
        ]
        let hours = patterns[weekday % 7]
        return hours.enumerated().map { PeakTimeData(hour: $0.offset, activity: $0.element) }
    }

    static var mostPopularHourLabel: String {
        "5–7 PM"
    }
}
