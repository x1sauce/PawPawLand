import SwiftUI
import CoreLocation
import MapKit

struct FogOfWarOverlay: View {
    let parks: [DogPark]
    let visitedParkIds: Set<UUID>
    let mapCenter: CLLocationCoordinate2D
    let mapSpan: MKCoordinateSpan

    var body: some View {
        Canvas { context, size in
            let fogRect = CGRect(origin: .zero, size: size)
            context.fill(
                Path(fogRect),
                with: .color(PawColors.fogOverlay)
            )

            for park in parks where visitedParkIds.contains(park.id) {
                let point = normalizedPoint(for: park.coordinate, in: size)
                let radius = clearedRadius(for: park, in: size)

                var clearedPath = Path()
                clearedPath.addEllipse(in: CGRect(
                    x: point.x - radius,
                    y: point.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))

                context.blendMode = .destinationOut
                context.fill(
                    clearedPath,
                    with: .radialGradient(
                        Gradient(stops: [
                            .init(color: .white, location: 0),
                            .init(color: .white.opacity(0.6), location: 0.55),
                            .init(color: .clear, location: 1)
                        ]),
                        center: point,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                context.blendMode = .normal
            }

            for park in parks where visitedParkIds.contains(park.id) {
                let point = normalizedPoint(for: park.coordinate, in: size)
                let radius = clearedRadius(for: park, in: size) * 0.85

                var glowPath = Path()
                glowPath.addEllipse(in: CGRect(
                    x: point.x - radius,
                    y: point.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))

                context.fill(
                    glowPath,
                    with: .radialGradient(
                        Gradient(colors: [
                            PawColors.gold.opacity(0.12),
                            PawColors.gold.opacity(0.04),
                            .clear
                        ]),
                        center: point,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
        }
        .compositingGroup()
    }

    private func normalizedPoint(for coordinate: CLLocationCoordinate2D, in size: CGSize) -> CGPoint {
        let region = MKCoordinateRegion(center: mapCenter, span: mapSpan)

        let latFraction = (coordinate.latitude - region.center.latitude + region.span.latitudeDelta / 2) / region.span.latitudeDelta
        let lngFraction = (coordinate.longitude - region.center.longitude + region.span.longitudeDelta / 2) / region.span.longitudeDelta

        return CGPoint(
            x: CGFloat(lngFraction) * size.width,
            y: CGFloat(1 - latFraction) * size.height
        )
    }

    private func clearedRadius(for park: DogPark, in size: CGSize) -> CGFloat {
        let base: CGFloat = min(size.width, size.height) * 0.14
        return base
    }
}

#Preview {
    ZStack {
        Color.gray
        FogOfWarOverlay(
            parks: MockData.parks,
            visitedParkIds: Set(MockData.parks.prefix(3).map(\.id)),
            mapCenter: MockData.laCenter,
            mapSpan: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
        )
    }
}
