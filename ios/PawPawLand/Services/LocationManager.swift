import CoreLocation
import Foundation

@MainActor
@Observable
final class LocationManager: NSObject {
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var currentLocation: CLLocationCoordinate2D?
    var areaLabel = "Your Area"
    var lastError: String?

    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermissionIfNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    func requestLocation() async -> CLLocationCoordinate2D? {
        lastError = nil
        requestPermissionIfNeeded()

        guard CLLocationManager.locationServicesEnabled() else {
            lastError = "Location services are disabled."
            return nil
        }

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return await withCheckedContinuation { continuation in
                locationContinuation = continuation
                manager.requestLocation()
            }
        case .denied, .restricted:
            lastError = "Location permission denied. Enable it in Settings to find nearby parks."
            return nil
        case .notDetermined:
            requestPermissionIfNeeded()
            lastError = "Waiting for location permission."
            return nil
        @unknown default:
            lastError = "Unknown location authorization status."
            return nil
        }
    }

    private func resolveAreaLabel(for location: CLLocation) async {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                areaLabel = placemark.locality
                    ?? placemark.subAdministrativeArea
                    ?? placemark.administrativeArea
                    ?? "Your Area"
            }
        } catch {
            areaLabel = "Your Area"
        }
    }

    private func finishLocationRequest(with coordinate: CLLocationCoordinate2D?) {
        locationContinuation?.resume(returning: coordinate)
        locationContinuation = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            currentLocation = location.coordinate
            await resolveAreaLabel(for: location)
            finishLocationRequest(with: location.coordinate)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            lastError = error.localizedDescription
            finishLocationRequest(with: currentLocation)
        }
    }
}
