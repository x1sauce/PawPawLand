import Foundation

/// Networking layer aligned with the NestJS `dog-parks` module.
enum DogParkAPI {
    static let defaultRadiusMiles = 15.0

    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case httpStatus(Int, String?)
        case decodingFailed(Error)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Could not build API URL."
            case .invalidResponse:
                return "The server returned an invalid response."
            case let .httpStatus(code, message):
                if let message, !message.isEmpty {
                    return "Server error (\(code)): \(message)"
                }
                return "Server error (\(code))."
            case let .decodingFailed(error):
                return "Could not read park data: \(error.localizedDescription)"
            }
        }
    }

    /// Mirrors `DogParkResponseDto` from the NestJS backend.
    private struct ParkResponse: Decodable {
        let id: String
        let name: String
        let description: String?
        let address: String?
        let latitude: Double?
        let longitude: Double?
        let isFenced: Bool
        let isOffLeash: Bool
        let hasWater: Bool
        let hasLighting: Bool
        let hours: String?
        let phone: String?
        let website: String?
        let distanceMiles: Double?
        let distanceKm: Double?
    }

    struct ImportResult: Decodable {
        let imported: Int
        let bbox: BoundingBox

        struct BoundingBox: Decodable {
            let south: Double
            let west: Double
            let north: Double
            let east: Double
        }
    }

    static var baseURL: URL {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           let url = URL(string: urlString) {
            return url
        }
        return URL(string: "http://localhost:3000")!
    }

    /// `POST /dog-parks/import` — seeds the DB from OpenStreetMap for the user's area.
    static func importFromLocation(
        lat: Double,
        lng: Double,
        radiusMiles: Double = defaultRadiusMiles
    ) async throws -> ImportResult {
        let url = try locationURL(
            path: "dog-parks/import",
            lat: lat,
            lng: lng,
            radiusMiles: radiusMiles
        )
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("PawPawLand-iOS/1.0", forHTTPHeaderField: "User-Agent")
        return try await performRequest(request, decode: ImportResult.self)
    }

    /// `GET /dog-parks/nearby` — parks within radius of the user, sorted by distance.
    static func fetchNearby(
        lat: Double,
        lng: Double,
        radiusMiles: Double = defaultRadiusMiles
    ) async throws -> [DogPark] {
        let url = try locationURL(
            path: "dog-parks/nearby",
            lat: lat,
            lng: lng,
            radiusMiles: radiusMiles
        )
        let responses = try await performRequest(url, decode: [ParkResponse].self)
        return responses.compactMap(mapPark)
    }

    /// `GET /dog-parks` — all parks currently cached in the database.
    static func fetchAll() async throws -> [DogPark] {
        let url = baseURL.appendingPathComponent("dog-parks")
        let responses = try await performRequest(url, decode: [ParkResponse].self)
        return responses.compactMap(mapPark)
    }

    /// Import from OSM, then return nearby parks for the same point.
    static func syncAndFetchNearby(
        lat: Double,
        lng: Double,
        radiusMiles: Double = defaultRadiusMiles
    ) async throws -> [DogPark] {
        _ = try await importFromLocation(lat: lat, lng: lng, radiusMiles: radiusMiles)
        return try await fetchNearby(lat: lat, lng: lng, radiusMiles: radiusMiles)
    }

    private static func locationURL(
        path: String,
        lat: Double,
        lng: Double,
        radiusMiles: Double
    ) throws -> URL {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lng", value: String(lng)),
            URLQueryItem(name: "radiusMiles", value: String(radiusMiles)),
        ]
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        return url
    }

    private static func performRequest<T: Decodable>(
        _ url: URL,
        decode type: T.Type
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("PawPawLand-iOS/1.0", forHTTPHeaderField: "User-Agent")
        return try await performRequest(request, decode: type)
    }

    private static func performRequest<T: Decodable>(
        _ request: URLRequest,
        decode type: T.Type
    ) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200 ... 299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            throw APIError.httpStatus(http.statusCode, message)
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    private static func mapPark(_ response: ParkResponse) -> DogPark? {
        guard let lat = response.latitude, let lng = response.longitude else {
            return nil
        }

        return DogPark(
            id: UUID(uuidString: response.id) ?? UUID(),
            name: response.name,
            description: response.description ?? "",
            address: response.address ?? "",
            latitude: lat,
            longitude: lng,
            isFenced: response.isFenced,
            isOffLeash: response.isOffLeash,
            hasWater: response.hasWater,
            hasLighting: response.hasLighting,
            hours: response.hours,
            neighborhood: neighborhood(from: response.address),
            imageSeed: response.name.lowercased().replacingOccurrences(of: " ", with: ""),
            distanceMiles: response.distanceMiles,
            distanceKm: response.distanceKm,
            phone: response.phone,
            website: response.website
        )
    }

    private static func neighborhood(from address: String?) -> String {
        guard let address, !address.isEmpty else { return "Nearby" }
        let parts = address
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        if parts.count >= 2 {
            return String(parts[parts.count - 2])
        }
        return String(parts[0])
    }
}
