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
            fogOverlay
            VStack(spacing: 0) {
                exploreHeader
                Spacer()
                bottomOverlay
            }
            loadingOverlay
            errorOverlay
        }
        .background(PawColors.background)
        .sheet(isPresented: $showParkDetail) {
            if let park = previewPark {
                ParkDetailView(park: park)
            }
        }
        .task {
            await loadInitialParks()
        }
    }

    private func loadInitialParks() async {
        await appState.loadParksNearUser()
        updateCamera()
        if previewPark == nil {
            previewPark = appState.parks.first
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
                Annotation(park.name, coordinate: park.coordinate, anchor: .bottom) {
                    ParkPinView(
                        isVisited: appState.isVisited(park),
                        isSelected: previewPark?.id == park.id
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            previewPark = park
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: park.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                                )
                            )
                        }
                    }
                }
                .tag(park)
            }

            ForEach(visitedParks) { park in
                MapCircle(center: park.coordinate, radius: 900)
                    .foregroundStyle(PawColors.goldGlow)
                    .stroke(PawColors.gold.opacity(0.3), lineWidth: 1)
            }
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
        .mapControlVisibility(.hidden)
        .colorScheme(.dark)
        .ignoresSafeArea()
    }

    private var visitedParks: [DogPark] {
        appState.parks.filter { appState.isVisited($0) }
    }

    private var fogOverlay: some View {
        FogOfWarOverlay(
            parks: appState.parks,
            visitedParkIds: appState.visitedParkIds,
            mapCenter: appState.mapCenter,
            mapSpan: appState.mapSpan
        )
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private var exploreHeader: some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    await appState.loadParksNearUser()
                    updateCamera()
                    previewPark = appState.parks.first
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(PawColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(PawColors.surface.opacity(0.92))
                    .clipShape(Circle())
            }
            .disabled(appState.isLoadingParks)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(PawColors.gold)
                Text(appState.selectedCity)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(PawColors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(PawColors.surface.opacity(0.92))
            .clipShape(Capsule())

            Spacer()

            Text("\(Int(appState.searchRadiusMiles)) mi")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(PawColors.textSecondary)
                .frame(width: 44, height: 44)
                .background(PawColors.surface.opacity(0.92))
                .clipShape(Circle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if appState.isLoadingParks {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(PawColors.gold)
                Text("Finding dog parks near you...")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
            }
            .padding(20)
            .background(PawColors.surface.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    @ViewBuilder
    private var errorOverlay: some View {
        if let message = appState.parksErrorMessage, !appState.isLoadingParks {
            VStack(spacing: 12) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 24))
                    .foregroundStyle(PawColors.gold)
                Text(message)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
                    .multilineTextAlignment(.center)
                Button("Try Again") {
                    Task { await loadInitialParks() }
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(PawColors.gold)
            }
            .padding(20)
            .frame(maxWidth: 300)
            .background(PawColors.surface.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var bottomOverlay: some View {
        VStack(spacing: 12) {
            if let park = previewPark {
                ParkPreviewCard(
                    park: park,
                    isVisited: appState.isVisited(park),
                    onTap: { showParkDetail = true },
                    onCheckIn: { appState.beginCheckIn(for: park) }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if !appState.parks.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(PawColors.gold)
                    Text("\(appState.unvisitedNearbyCount) more parks to explore in this area!")
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
    let isVisited: Bool
    let isSelected: Bool

    var body: some View {
        ZStack {
            if isVisited {
                Circle()
                    .fill(PawColors.goldGlow)
                    .frame(width: isSelected ? 44 : 32, height: isSelected ? 44 : 32)
            }

            Image(systemName: "pawprint.fill")
                .font(.system(size: isSelected ? 22 : 16, weight: .semibold))
                .foregroundStyle(pinColor)
                .padding(isSelected ? 10 : 7)
                .background(
                    Circle()
                        .fill(PawColors.surface)
                        .shadow(color: pinColor.opacity(0.4), radius: isSelected ? 8 : 4)
                )
                .overlay {
                    Circle()
                        .stroke(pinColor.opacity(isVisited ? 0.8 : 0.3), lineWidth: isSelected ? 2 : 1)
                }
        }
        .scaleEffect(isSelected ? 1.1 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    private var pinColor: Color {
        if isVisited { return PawColors.gold }
        return PawColors.unvisitedPin
    }
}

struct ParkPreviewCard: View {
    let park: DogPark
    let isVisited: Bool
    let onTap: () -> Void
    let onCheckIn: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ParkThumbnail(seed: park.imageSeed, size: 64)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(park.name)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(PawColors.textPrimary)
                            .lineLimit(1)

                        if isVisited {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(PawColors.gold)
                        }
                    }

                    Text(park.distanceLabel ?? park.neighborhood)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(PawColors.textSecondary)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 11))
                        Text(park.featureSummary)
                            .lineLimit(1)
                    }
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textTertiary)
                }

                Spacer(minLength: 0)

                Button(action: onCheckIn) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(PawColors.gold)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(PawColors.surface.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(PawColors.surfaceBorder, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.35), radius: 20, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExploreMapView()
        .environment(AppState())
}
