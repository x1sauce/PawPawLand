import SwiftUI
import CoreLocation
import MapKit

/// Illustrated discovery overlay — undiscovered areas stay dim; visited parks glow by frequency.
struct IllustratedDiscoveryOverlay: View {
    let parks: [DogPark]
    let visitCount: (DogPark) -> Int
    let mapCenter: CLLocationCoordinate2D
    let mapSpan: MKCoordinateSpan

    var body: some View {
        ZStack {
            PawColors.mapIllustrationGradient
                .ignoresSafeArea()

            Canvas { context, size in
                let fogRect = CGRect(origin: .zero, size: size)
                context.fill(Path(fogRect), with: .color(PawColors.fogOverlay))

                for park in parks {
                    let visits = visitCount(park)
                    let level = DiscoveryLevel.from(visitCount: visits)
                    guard level != .unknown else { continue }

                    let point = normalizedPoint(for: park.coordinate, in: size)
                    let radius = clearedRadius(for: level, in: size)

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
                                .init(color: .white.opacity(0.65), location: 0.5),
                                .init(color: .clear, location: 1),
                            ]),
                            center: point,
                            startRadius: 0,
                            endRadius: radius
                        )
                    )
                    context.blendMode = .normal
                }

                for park in parks {
                    let visits = visitCount(park)
                    let level = DiscoveryLevel.from(visitCount: visits)
                    guard level != .unknown else { continue }

                    let point = normalizedPoint(for: park.coordinate, in: size)
                    let radius = clearedRadius(for: level, in: size) * 0.9
                    let glowColor = PawColors.discoveryGlow(for: level)

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
                                glowColor.opacity(level.glowOpacity),
                                glowColor.opacity(level.glowOpacity * 0.35),
                                .clear,
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

    private func clearedRadius(for level: DiscoveryLevel, in size: CGSize) -> CGFloat {
        let base = min(size.width, size.height) * 0.11
        return base * level.pinScale
    }
}

#Preview {
    ZStack {
        Color.gray
        IllustratedDiscoveryOverlay(
            parks: MockData.parks,
            visitCount: { park in MockData.demoVisitCounts[park.id, default: 0] },
            mapCenter: MockData.laCenter,
            mapSpan: MKCoordinateSpan(latitudeDelta: 0.22, longitudeDelta: 0.22)
        )
    }
}
