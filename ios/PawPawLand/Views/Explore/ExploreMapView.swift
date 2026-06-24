import SwiftUI
import MapKit

struct ExploreMapView: View {
    @Environment(AppState.self) private var appState
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var previewPark: DogPark?
    @State private var showParkDetail = false

    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
            discoveryOverlay
            VStack(spacing: 0) {
                exploreHeader
                if let event = activeEventBanner {
                    ParkEventBanner(event: event)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }
                Spacer()
                bottomOverlay
            }
            loadingOverlay
            errorOverlay
        }
        .background(PawColors.heroGradient)
        .sheet(isPresented: $showParkDetail) {
            if let park = previewPark {
                ParkDetailView(park: park)
            }
        }
        .task {
            await loadInitialParks()
        }
    }

    private var activeEventBanner: ParkEvent? {
        guard let park = previewPark else { return appState.parkEvents.first(where: \.isActive) }
        return appState.event(for: park)
    }

    private func loadInitialParks() async {
        await appState.loadParksNearUser()
        updateCamera()
        if previewPark == nil {
            previewPark = appState.parks.first(where: { appState.visitCount(for: $0) > 0 })
                ?? appState.parks.first
        }
    }

    private func updateCamera() {
        cameraPosition = .region(
            MKCoordinateRegion(center: appState.mapCenter, span: appState.mapSpan)
        )
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition, selection: $previewPark) {
            UserAnnotation()

            ForEach(appState.parks) { park in
                let level = appState.discoveryLevel(for: park)
                Annotation(park.name, coordinate: park.coordinate, anchor: .bottom) {
                    ParkPinView(
                        level: level,
                        isSelected: previewPark?.id == park.id,
                        hasEvent: appState.event(for: park) != nil,
                        pin: appState.pin(for: park)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            previewPark = park
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: park.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                            )
                        }
                    }
                }
                .tag(park)

                if level != .unknown {
                    MapCircle(center: park.coordinate, radius: glowRadius(for: level))
                        .foregroundStyle(PawColors.discoveryGlow(for: level).opacity(level.glowOpacity))
                        .stroke(PawColors.discoveryGlow(for: level).opacity(0.5), lineWidth: 1)
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
        .mapControlVisibility(.hidden)
        .colorScheme(.dark)
        .saturation(0.55)
        .contrast(1.08)
        .ignoresSafeArea()
    }

    private func glowRadius(for level: DiscoveryLevel) -> Double {
        switch level {
        case .unknown: return 0
        case .discovered: return 500
        case .familiar: return 750
        case .regular: return 1000
        case .homeTurf: return 1300
        }
    }

    private var discoveryOverlay: some View {
        IllustratedDiscoveryOverlay(
            parks: appState.parks,
            visitCount: { appState.visitCount(for: $0) },
            mapCenter: appState.mapCenter,
            mapSpan: appState.mapSpan
        )
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private var exploreHeader: some View {
        HStack(spacing: 10) {
            DogAvatarView(profile: appState.dogProfile, size: 42, showLevel: false)

            VStack(alignment: .leading, spacing: 2) {
                Text(appState.dogProfile.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text("\(appState.selectedCity) · Lv.\(appState.dogProfile.level)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0f%%", appState.mapExploredPercentage))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(PawColors.mint)
                Text("map lit")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textTertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(PawColors.surface.opacity(0.92))
            .clipShape(Capsule())

            Button {
                Task {
                    await appState.loadParksNearUser()
                    updateCamera()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PawColors.gold)
                    .frame(width: 40, height: 40)
                    .background(PawColors.surface.opacity(0.92))
                    .clipShape(Circle())
            }
            .disabled(appState.isLoadingParks)
        }
        .foregroundStyle(PawColors.textPrimary)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if appState.isLoadingParks {
            VStack(spacing: 12) {
                Text(appState.dogProfile.mood.emoji)
                    .font(.system(size: 40))
                Text("Lucky is sniffing out parks...")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(PawColors.textPrimary)
                Text("Wagging tail in progress")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
            }
            .padding(24)
            .background(PawColors.surface.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    @ViewBuilder
    private var errorOverlay: some View {
        if let message = appState.parksErrorMessage, !appState.isLoadingParks {
            VStack(spacing: 12) {
                Text("🐾")
                    .font(.system(size: 32))
                Text("Lucky couldn't reach the park network")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(PawColors.textPrimary)
                Text(message)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
                    .multilineTextAlignment(.center)
                Button("Sniff again") {
                    Task { await loadInitialParks() }
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(PawColors.gold)
            }
            .padding(20)
            .frame(maxWidth: 300)
            .background(PawColors.surface.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var bottomOverlay: some View {
        VStack(spacing: 12) {
            if let park = previewPark {
                ParkPreviewCard(
                    park: park,
                    level: appState.discoveryLevel(for: park),
                    pin: appState.pin(for: park),
                    isVisited: appState.isVisited(park),
                    onTap: { showParkDetail = true },
                    onCheckIn: { appState.beginCheckIn(for: park) }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if appState.unvisitedNearbyCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundStyle(PawColors.lavender)
                    Text("\(appState.unvisitedNearbyCount) mystery sniff spots still hiding!")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(PawColors.textSecondary)
                }
                .padding(.bottom, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: previewPark?.id)
    }
}

struct ParkPinView: View {
    let level: DiscoveryLevel
    let isSelected: Bool
    var hasEvent: Bool = false
    var pin: ParkPin?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                if level != .unknown {
                    Circle()
                        .fill(PawColors.discoveryGlow(for: level).opacity(level.glowOpacity))
                        .frame(width: isSelected ? 48 : 36, height: isSelected ? 48 : 36)
                }

                Group {
                    if let pin, pin.isUnlocked {
                        ParkPinBadge(pin: pin, size: isSelected ? 40 : 32)
                    } else {
                        Image(systemName: level == .unknown ? "questionmark.circle.fill" : "pawprint.fill")
                            .font(.system(size: isSelected ? 20 : 15, weight: .bold))
                            .foregroundStyle(pinColor)
                            .padding(isSelected ? 10 : 8)
                            .background(Circle().fill(PawColors.surface))
                            .overlay {
                                Circle().stroke(pinColor.opacity(0.5), lineWidth: isSelected ? 2 : 1)
                            }
                    }
                }
            }
            .scaleEffect((isSelected ? 1.12 : 1) * level.pinScale)
            .opacity(level == .unknown ? 0.55 : 1)

            if hasEvent {
                Circle()
                    .fill(PawColors.coral)
                    .frame(width: 12, height: 12)
                    .overlay { Circle().stroke(PawColors.surface, lineWidth: 2) }
                    .offset(x: 4, y: -4)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    private var pinColor: Color {
        switch level {
        case .unknown: return PawColors.unvisitedPin
        case .discovered: return PawColors.mint
        case .familiar: return PawColors.sky
        case .regular: return PawColors.gold
        case .homeTurf: return PawColors.coral
        }
    }
}

struct ParkPreviewCard: View {
    let park: DogPark
    let level: DiscoveryLevel
    let pin: ParkPin?
    let isVisited: Bool
    let onTap: () -> Void
    let onCheckIn: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                if let pin, pin.isUnlocked {
                    ParkPinBadge(pin: pin, size: 58)
                } else {
                    ParkThumbnail(seed: park.imageSeed, size: 58)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(park.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(PawColors.textPrimary)
                        .lineLimit(1)

                    Text(level.label)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(PawColors.discoveryGlow(for: level))

                    Text(park.distanceLabel ?? park.neighborhood)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(PawColors.textSecondary)
                }

                Spacer(minLength: 0)

                Button(action: onCheckIn) {
                    VStack(spacing: 4) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Moment")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color(red: 0.12, green: 0.08, blue: 0.02))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(PawColors.goldButtonGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(PawColors.surface.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(PawColors.discoveryGlow(for: level).opacity(0.35), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.30), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExploreMapView()
        .environment(AppState())
}
