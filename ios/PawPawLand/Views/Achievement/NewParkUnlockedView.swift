import SwiftUI
import UIKit

struct NewParkUnlockedView: View {
    @Environment(AppState.self) private var appState
    let park: DogPark
    @State private var animateGlow = false
    @State private var animateScale = false

    var body: some View {
        ZStack {
            PawColors.heroGradient.ignoresSafeArea()

            RadialGradient(
                colors: [PawColors.mint.opacity(0.2), PawColors.background.opacity(0.1)],
                center: .center,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("New sniff spot discovered!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(PawColors.textPrimary)

                Text("\(appState.dogProfile.name) is doing zoomies!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)

                ZStack {
                    Circle()
                        .fill(PawColors.goldGlow)
                        .frame(width: animateGlow ? 230 : 190, height: animateGlow ? 230 : 190)
                        .blur(radius: 22)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateGlow)

                    if let pin = appState.newlyUnlockedPin ?? appState.pin(for: park) {
                        ParkPinBadge(pin: pin, size: animateScale ? 140 : 90)
                            .scaleEffect(animateScale ? 1 : 0.5)
                            .opacity(animateScale ? 1 : 0)
                    } else {
                        ParkThumbnail(seed: park.imageSeed, size: 150)
                            .clipShape(Circle())
                            .scaleEffect(animateScale ? 1 : 0.6)
                    }
                }

                VStack(spacing: 8) {
                    Text(park.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(PawColors.textPrimary)
                        .multilineTextAlignment(.center)

                    if let pin = appState.newlyUnlockedPin {
                        Text("Earned pin: \(pin.title)")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(PawColors.gold)
                    }

                    Text("+\(80) XP for \(appState.dogProfile.name)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(PawColors.mint)
                }
                .padding(.horizontal, 32)

                VStack(spacing: 12) {
                    PawButton(title: "Woohoo!", icon: "sparkles") {
                        appState.dismissUnlockCelebration()
                    }

                    Button("Keep sniffin'") {
                        appState.dismissUnlockCelebration()
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
                }
                .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            animateGlow = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                animateScale = true
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NewParkUnlockedView(park: MockData.parks[3])
        .environment(AppState())
}
