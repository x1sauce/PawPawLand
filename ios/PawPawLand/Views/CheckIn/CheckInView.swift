import SwiftUI
import PhotosUI

struct CheckInView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedMood: VisitMood?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showParkPicker = false

    private var park: DogPark? {
        appState.checkInPark ?? appState.parks.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    if let park {
                        parkHeader(park)
                    }

                    dogPhotoSection

                    moodSection

                    if let park {
                        PawCard {
                            HStack(spacing: 12) {
                                ParkThumbnail(seed: park.imageSeed, size: 48)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(park.name)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(PawColors.textPrimary)
                                    Text(park.neighborhood)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(PawColors.textSecondary)
                                }
                                Spacer()
                                Button("Change") { showParkPicker = true }
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(PawColors.gold)
                            }
                        }
                    }

                    PawButton(title: "Check In", icon: "checkmark.circle.fill") {
                        appState.completeCheckIn(mood: selectedMood)
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(PawColors.background)
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if appState.checkInPark != nil {
                        Button("Cancel") {
                            appState.showCheckInSheet = false
                            appState.checkInPark = nil
                        }
                        .foregroundStyle(PawColors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showParkPicker) {
                ParkPickerSheet(selectedPark: Binding(
                    get: { appState.checkInPark },
                    set: { appState.checkInPark = $0 }
                ))
            }
        }
        .preferredColorScheme(.dark)
    }

    private func parkHeader(_ park: DogPark) -> some View {
        VStack(spacing: 6) {
            Text("Checking in at")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(PawColors.textTertiary)
            Text(park.name)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(PawColors.textPrimary)
                .multilineTextAlignment(.center)
        }
    }

    private var dogPhotoSection: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [PawColors.surfaceElevated, PawColors.surface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .overlay {
                        Image(systemName: "dog.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(PawColors.gold.opacity(0.8))
                    }
                    .overlay {
                        Circle()
                            .stroke(PawColors.gold, lineWidth: 3)
                            .glowRing(color: PawColors.gold, radius: 6)
                    }

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PawColors.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(PawColors.surfaceElevated)
                        .clipShape(Circle())
                        .overlay { Circle().stroke(PawColors.surfaceBorder, lineWidth: 1) }
                }
                .offset(x: 4, y: 4)
            }

            Text(MockData.userDogName)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(PawColors.textPrimary)
        }
    }

    private var moodSection: some View {
        VStack(spacing: 16) {
            Text("How was the visit today?")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(PawColors.textPrimary)

            HStack(spacing: 16) {
                ForEach(VisitMood.allCases, id: \.self) { mood in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedMood = mood
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(mood.emoji)
                                .font(.system(size: selectedMood == mood ? 36 : 30))
                            Text(mood.label)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(selectedMood == mood ? PawColors.gold : PawColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedMood == mood ? PawColors.gold.opacity(0.12) : PawColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selectedMood == mood ? PawColors.gold.opacity(0.5) : PawColors.surfaceBorder, lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ParkPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPark: DogPark?
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            List(appState.parks) { park in
                Button {
                    selectedPark = park
                    dismiss()
                } label: {
                    HStack {
                        ParkThumbnail(seed: park.imageSeed, size: 40)
                        VStack(alignment: .leading) {
                            Text(park.name)
                                .foregroundStyle(PawColors.textPrimary)
                            Text(park.neighborhood)
                                .font(.caption)
                                .foregroundStyle(PawColors.textSecondary)
                        }
                    }
                }
                .listRowBackground(PawColors.surface)
            }
            .scrollContentBackground(.hidden)
            .background(PawColors.background)
            .navigationTitle("Choose Park")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(PawColors.gold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct CheckInSheet: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        CheckInView()
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
    }
}

#Preview {
    CheckInView()
        .environment(AppState())
}
