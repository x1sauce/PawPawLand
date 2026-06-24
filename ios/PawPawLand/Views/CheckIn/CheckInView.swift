import SwiftUI
import PhotosUI

struct CheckInView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedMood: VisitMood?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var caption = ""
    @State private var showParkPicker = false

    private var park: DogPark? {
        appState.checkInPark ?? appState.parks.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    if let park {
                        parkChip(park)
                    }
                    photoMomentSection
                    captionSection
                    moodSection
                    PawButton(title: "Share this moment", icon: "sparkles") {
                        appState.completeCheckIn(mood: selectedMood, caption: caption.isEmpty ? nil : caption)
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .background(PawColors.heroGradient)
            .navigationTitle("Paw Moment")
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

    private var headerSection: some View {
        VStack(spacing: 12) {
            DogAvatarView(profile: appState.dogProfile, size: 96)
            Text("What did \(appState.dogProfile.name) think?")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(PawColors.textPrimary)
            Text("Drop a photo or a cozy note from today's adventure")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(PawColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private func parkChip(_ park: DogPark) -> some View {
        PawCard {
            HStack(spacing: 12) {
                ParkThumbnail(seed: park.imageSeed, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(park.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(PawColors.textPrimary)
                    Text(appState.discoveryLevel(for: park).label)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(PawColors.mint)
                }
                Spacer()
                Button("Change") { showParkPicker = true }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(PawColors.gold)
            }
        }
    }

    private var photoMomentSection: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(PawColors.surface)
                    .frame(height: 200)
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(PawColors.gold.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [8]))
                    }

                VStack(spacing: 10) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(PawColors.gold)
                    Text("Add a walk photo")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(PawColors.textPrimary)
                    Text("BeReal vibes — capture the moment")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(PawColors.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Park thoughts")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(PawColors.textPrimary)
            TextField("Lucky loved the mud puddle near...", text: $caption, axis: .vertical)
                .lineLimit(3 ... 6)
                .padding(14)
                .background(PawColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(PawColors.surfaceBorder, lineWidth: 1)
                }
        }
    }

    private var moodSection: some View {
        VStack(spacing: 14) {
            Text("How's \(appState.dogProfile.name) feeling?")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(PawColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(VisitMood.allCases, id: \.self) { mood in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedMood = mood
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Text(mood.emoji)
                                    .font(.system(size: selectedMood == mood ? 34 : 28))
                                Text(mood.label)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(selectedMood == mood ? PawColors.gold : PawColors.textTertiary)
                            }
                            .frame(width: 88)
                            .padding(.vertical, 12)
                            .background(selectedMood == mood ? PawColors.gold.opacity(0.14) : PawColors.surface)
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
                            Text(appState.discoveryLevel(for: park).label)
                                .font(.caption)
                                .foregroundStyle(PawColors.textSecondary)
                        }
                    }
                }
                .listRowBackground(PawColors.surface)
            }
            .scrollContentBackground(.hidden)
            .background(PawColors.background)
            .navigationTitle("Pick a park")
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
